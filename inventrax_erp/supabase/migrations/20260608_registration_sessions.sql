-- Pending registration sessions + email precheck + KULMIS ERP OTP branding.

-- ---------------------------------------------------------------------------
-- KULMIS ERP branded OTP templates (PRD format)
-- ---------------------------------------------------------------------------

update otp_apps set
  name = 'KULMIS ERP',
  sms_sender_name = 'KULMIS ERP',
  otp_template_en = E'KULMIS ERP:\nYour verification code is {{otp}}.\nDo not share this code.',
  otp_template_so = E'KULMIS ERP:\nKoodhka xaqiijintaagu waa {{otp}}.\nHa la wadaagin qof kale.',
  otp_template_ar = E'KULMIS ERP:\nرمز التحقق الخاص بك هو {{otp}}'
where id = 'kulmis-erp';

-- ---------------------------------------------------------------------------
-- Pending registration (OTP-first — no store until verified + finalized)
-- ---------------------------------------------------------------------------

create table if not exists registration_sessions (
  id uuid primary key default gen_random_uuid(),
  app_id text not null default 'kulmis-erp' references otp_apps (id),
  phone text not null,
  email text not null,
  email_status text not null default 'new'
    check (email_status in ('new', 'existing_no_store', 'has_store')),
  payload jsonb not null default '{}'::jsonb,
  otp_request_id uuid references otp_requests (id) on delete set null,
  status text not null default 'pending'
    check (status in ('pending', 'otp_sent', 'verified', 'completed', 'expired')),
  expires_at timestamptz not null default (now() + interval '30 minutes'),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_registration_sessions_phone
  on registration_sessions (phone, created_at desc);

create index if not exists idx_registration_sessions_email
  on registration_sessions (lower(email), created_at desc);

-- ---------------------------------------------------------------------------
-- Email precheck before OTP (no auth required)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_check_registration_email(p_email text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := lower(trim(p_email));
  v_uid uuid;
  v_has_profile boolean;
begin
  if v_email is null or v_email !~ '^[^@]+@[^@]+\.[^@]+$' then
    return jsonb_build_object(
      'status', 'invalid',
      'message', 'Enter a valid email address'
    );
  end if;

  select id into v_uid from auth.users where email = v_email limit 1;

  if v_uid is null then
    return jsonb_build_object('status', 'new');
  end if;

  select exists (select 1 from profiles where id = v_uid) into v_has_profile;

  if v_has_profile then
    return jsonb_build_object(
      'status', 'has_store',
      'message', 'This email already has a store. Please sign in.'
    );
  end if;

  return jsonb_build_object(
    'status', 'existing_no_store',
    'message', 'This email already has an account. Sign in with your password after OTP verification to finish store setup.'
  );
end;
$$;

grant execute on function public.inventrax_check_registration_email to anon;
grant execute on function public.inventrax_check_registration_email to authenticated;

-- RLS: registration_sessions service-role only
alter table registration_sessions enable row level security;
