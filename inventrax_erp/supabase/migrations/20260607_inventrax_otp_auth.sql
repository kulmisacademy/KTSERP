-- Central OTP infrastructure: multi-app branding, secure hashing, rate limits.

-- ---------------------------------------------------------------------------
-- App branding catalog (multi-SaaS)
-- ---------------------------------------------------------------------------

create table if not exists otp_apps (
  id text primary key,
  name text not null,
  sms_sender_name text not null,
  otp_template_en text not null default '{{app_name}} verification code: {{otp}}',
  otp_template_so text,
  otp_template_ar text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into otp_apps (id, name, sms_sender_name, otp_template_en, otp_template_so, otp_template_ar)
values (
  'kulmis-erp',
  'KULMIS ERP',
  'KULMIS ERP',
  '{{app_name}} verification code: {{otp}}',
  '{{app_name}} koodka xaqiijinta: {{otp}}',
  'رمز التحقق {{app_name}}: {{otp}}'
)
on conflict (id) do update set
  name = excluded.name,
  sms_sender_name = excluded.sms_sender_name,
  otp_template_en = excluded.otp_template_en,
  otp_template_so = excluded.otp_template_so,
  otp_template_ar = excluded.otp_template_ar;

-- ---------------------------------------------------------------------------
-- OTP requests (hashed codes only — never store raw OTP)
-- ---------------------------------------------------------------------------

create table if not exists otp_requests (
  id uuid primary key default gen_random_uuid(),
  app_id text not null references otp_apps (id),
  phone text not null,
  purpose text not null check (purpose in ('registration', 'password_reset', 'login', 'phone_verify')),
  code_hash text not null,
  salt text not null,
  status text not null default 'pending'
    check (status in ('pending', 'sent', 'verified', 'expired', 'failed')),
  attempts int not null default 0,
  max_attempts int not null default 5,
  resend_count int not null default 0,
  max_resends int not null default 3,
  provider text default 'hormuud',
  provider_message_id text,
  last_error text,
  locale_code text not null default 'en',
  metadata jsonb not null default '{}'::jsonb,
  expires_at timestamptz not null,
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_otp_requests_phone_purpose
  on otp_requests (phone, purpose, created_at desc);

create index if not exists idx_otp_requests_status
  on otp_requests (status, expires_at);

-- ---------------------------------------------------------------------------
-- Rate limit audit (per phone / IP)
-- ---------------------------------------------------------------------------

create table if not exists otp_rate_limits (
  id uuid primary key default gen_random_uuid(),
  phone text not null,
  window_start timestamptz not null default now(),
  request_count int not null default 1,
  unique (phone, window_start)
);

-- ---------------------------------------------------------------------------
-- Normalize phone helper
-- ---------------------------------------------------------------------------

create or replace function public.normalize_phone(p_phone text)
returns text
language sql
immutable
as $$
  select regexp_replace(coalesce(p_phone, ''), '[^0-9+]', '', 'g');
$$;

-- ---------------------------------------------------------------------------
-- Check recent verified OTP for registration gate
-- ---------------------------------------------------------------------------

create or replace function public.otp_is_phone_verified(
  p_phone text,
  p_purpose text default 'registration',
  p_within_minutes int default 15
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from otp_requests
    where phone = normalize_phone(p_phone)
      and purpose = p_purpose
      and status = 'verified'
      and verified_at > now() - (p_within_minutes || ' minutes')::interval
  );
$$;

grant execute on function public.otp_is_phone_verified to authenticated;
grant execute on function public.otp_is_phone_verified to service_role;

-- ---------------------------------------------------------------------------
-- Platform OTP stats (super admin)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_platform_otp_stats()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role text;
begin
  select role_id into v_role from profiles where id = auth.uid();
  if v_role is distinct from 'super_admin' then
    raise exception 'Not allowed';
  end if;

  return jsonb_build_object(
    'sent_today', (
      select count(*)::int from otp_requests
      where created_at > date_trunc('day', now())
        and status in ('sent', 'verified', 'pending')
    ),
    'verified_today', (
      select count(*)::int from otp_requests
      where verified_at > date_trunc('day', now())
    ),
    'failed_today', (
      select count(*)::int from otp_requests
      where created_at > date_trunc('day', now())
        and status = 'failed'
    ),
    'pending', (
      select count(*)::int from otp_requests
      where status = 'pending' and expires_at > now()
    )
  );
end;
$$;

grant execute on function public.inventrax_platform_otp_stats to authenticated;

-- ---------------------------------------------------------------------------
-- register_store: require phone OTP + write stores.phone
-- ---------------------------------------------------------------------------

create or replace function public.register_store(
  p_store_name text,
  p_business_type text,
  p_country text,
  p_currency text,
  p_address text default null,
  p_owner_name text default null,
  p_phone text default null,
  p_tax_number text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_email text;
  v_tenant_id text := gen_random_uuid()::text;
  v_store_id text := gen_random_uuid()::text;
  v_sub_id text := gen_random_uuid()::text;
  v_name text;
  v_phone text := normalize_phone(p_phone);
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if v_phone is null or length(v_phone) < 7 then
    raise exception 'Valid phone number is required';
  end if;

  if not otp_is_phone_verified(v_phone, 'registration', 15) then
    raise exception 'Phone not verified. Complete OTP verification first.';
  end if;

  if exists (select 1 from profiles where id = v_user_id) then
    raise exception 'Account already registered';
  end if;

  select email into v_email from auth.users where id = v_user_id;
  v_name := coalesce(nullif(trim(p_owner_name), ''), split_part(v_email, '@', 1));

  insert into tenants (id, name, country, currency_code)
  values (v_tenant_id, trim(p_store_name), coalesce(p_country, ''), coalesce(p_currency, 'USD'));

  insert into stores (
    id, tenant_id, name, business_type, address, country, currency_code, tax_number, phone
  ) values (
    v_store_id,
    v_tenant_id,
    trim(p_store_name),
    coalesce(nullif(trim(p_business_type), ''), 'Retail'),
    p_address,
    coalesce(p_country, ''),
    coalesce(p_currency, 'USD'),
    p_tax_number,
    v_phone
  );

  insert into profiles (id, tenant_id, store_id, role_id, full_name, email, phone)
  values (
    v_user_id,
    v_tenant_id,
    v_store_id,
    'store_owner',
    v_name,
    coalesce(v_email, ''),
    v_phone
  );

  insert into subscriptions (id, tenant_id, plan_name, status, trial_ends_at)
  values (
    v_sub_id,
    v_tenant_id,
    'Free Trial',
    'trialing',
    now() + interval '14 days'
  );

  return jsonb_build_object(
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'role_id', 'store_owner',
    'store_name', trim(p_store_name)
  );
end;
$$;

-- RLS: otp tables service-role only (edge functions)
alter table otp_apps enable row level security;
alter table otp_requests enable row level security;
alter table otp_rate_limits enable row level security;

create policy otp_apps_read on otp_apps for select to authenticated using (is_active = true);
