-- Registration: email + password only — no phone OTP or SMS wallet.

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
  v_country text := coalesce(nullif(trim(p_country), ''), 'Somalia');
  v_currency text := upper(coalesce(nullif(trim(p_currency), ''), 'USD'));
  v_store_name text := trim(p_store_name);
  v_trial_days int;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if v_store_name is null or v_store_name = '' then
    raise exception 'Store name is required';
  end if;

  if v_phone is null or length(v_phone) < 7 then
    raise exception 'Valid phone number is required';
  end if;

  if exists (select 1 from profiles where id = v_user_id) then
    raise exception 'Account already registered';
  end if;

  select email into v_email from auth.users where id = v_user_id;
  v_name := coalesce(nullif(trim(p_owner_name), ''), split_part(v_email, '@', 1));
  select coalesce(default_trial_days, 14) into v_trial_days
  from billing_settings where id = 'global';

  insert into tenants (id, name, country, currency_code)
  values (v_tenant_id, v_store_name, v_country, v_currency);

  insert into stores (
    id, tenant_id, name, business_type, address, country, currency_code, tax_number, phone, email
  ) values (
    v_store_id, v_tenant_id, v_store_name,
    coalesce(nullif(trim(p_business_type), ''), 'Retail'),
    nullif(trim(p_address), ''), v_country, v_currency,
    nullif(trim(p_tax_number), ''), v_phone, coalesce(v_email, '')
  );

  insert into profiles (id, tenant_id, store_id, role_id, full_name, email, phone)
  values (v_user_id, v_tenant_id, v_store_id, 'store_owner', v_name, coalesce(v_email, ''), v_phone);

  insert into subscriptions (
    id, tenant_id, store_id, plan_id, plan_name, status, trial_ends_at, billing_cycle
  ) values (
    v_sub_id, v_tenant_id, v_store_id, 'free_trial', 'Free Trial', 'trialing',
    now() + (v_trial_days || ' days')::interval, 'monthly'
  );

  return jsonb_build_object(
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'role_id', 'store_owner',
    'store_name', v_store_name,
    'country', v_country,
    'currency_code', v_currency,
    'email', coalesce(v_email, ''),
    'trial_days', v_trial_days
  );
end;
$$;

grant execute on function public.register_store to authenticated;
