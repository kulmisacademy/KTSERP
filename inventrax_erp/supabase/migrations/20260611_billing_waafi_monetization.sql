-- KULMIS ERP: SaaS billing, cloud SMS marketplace, Waafi payments.

-- ---------------------------------------------------------------------------
-- Extend subscription_plans
-- ---------------------------------------------------------------------------

alter table subscription_plans
  add column if not exists trial_days integer not null default 0,
  add column if not exists is_popular boolean not null default false,
  add column if not exists currency_code text not null default 'USD';

update subscription_plans set trial_days = 14, currency_code = 'USD' where id = 'free_trial';

update subscription_plans set
  name = 'Basic',
  description = 'Small stores — monthly billing',
  monthly_price_cents = 1000,
  yearly_price_cents = 10000,
  is_popular = false,
  currency_code = 'USD',
  features = '["pos","products","reports","sms","offline"]'::jsonb,
  updated_at = now()
where id = 'starter';

insert into subscription_plans (
  id, name, description, monthly_price_cents, yearly_price_cents,
  product_limit, user_limit, storage_limit_bytes, branch_limit,
  features, sort_order, trial_days, is_popular, currency_code
) values (
  'basic', 'Basic', 'Essential ERP for small stores',
  1000, 10000, 500, 5, 5368709120, 1,
  '["pos","products","reports","sms","offline"]'::jsonb, 15, 0, false, 'USD'
) on conflict (id) do update set
  name = excluded.name,
  monthly_price_cents = excluded.monthly_price_cents,
  yearly_price_cents = excluded.yearly_price_cents,
  features = excluded.features,
  updated_at = now();

update subscription_plans set
  name = 'Business',
  monthly_price_cents = 3000,
  yearly_price_cents = 30000,
  is_popular = true,
  currency_code = 'USD',
  features = '["pos","products","reports","accounting","sms","ai","realtime","offline"]'::jsonb,
  updated_at = now()
where id = 'business';

update subscription_plans set
  name = 'Enterprise',
  monthly_price_cents = 9900,
  yearly_price_cents = 99000,
  currency_code = 'USD',
  updated_at = now()
where id = 'enterprise';

-- ---------------------------------------------------------------------------
-- Platform billing settings (trial, grace, gateway flags)
-- ---------------------------------------------------------------------------

create table if not exists billing_settings (
  id text primary key default 'global',
  default_trial_days integer not null default 14,
  grace_period_days integer not null default 3,
  waafi_enabled boolean not null default true,
  waafi_sandbox boolean not null default true,
  currency_code text not null default 'USD',
  updated_at timestamptz not null default now()
);

insert into billing_settings (id) values ('global') on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Cloud SMS packages (marketplace catalog)
-- ---------------------------------------------------------------------------

create table if not exists sms_packages (
  id text primary key,
  name text not null,
  description text,
  sms_count integer not null check (sms_count > 0),
  price_cents integer not null check (price_cents >= 0),
  currency_code text not null default 'USD',
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into sms_packages (id, name, description, sms_count, price_cents, sort_order) values
  ('sms_starter', 'Starter', '500 SMS credits', 500, 500, 10),
  ('sms_business', 'Business', '5,000 SMS credits', 5000, 3500, 20),
  ('sms_enterprise', 'Enterprise', '50,000 SMS credits', 50000, 25000, 30)
on conflict (id) do update set
  name = excluded.name,
  sms_count = excluded.sms_count,
  price_cents = excluded.price_cents,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- Cloud store SMS wallets
-- ---------------------------------------------------------------------------

create table if not exists store_sms_wallets (
  store_id text primary key references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  balance_remaining integer not null default 0 check (balance_remaining >= 0),
  balance_purchased integer not null default 0,
  balance_used integer not null default 0,
  updated_at timestamptz not null default now()
);

create index if not exists idx_store_sms_wallets_tenant on store_sms_wallets (tenant_id);

-- ---------------------------------------------------------------------------
-- Payment transactions
-- ---------------------------------------------------------------------------

create table if not exists payment_transactions (
  id text primary key,
  tenant_id text not null references tenants (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  user_id uuid references auth.users (id) on delete set null,
  payment_type text not null check (
    payment_type in ('subscription', 'sms_package', 'renewal', 'upgrade')
  ),
  status text not null default 'pending' check (
    status in ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled')
  ),
  amount_cents integer not null check (amount_cents >= 0),
  currency_code text not null default 'USD',
  provider text not null default 'waafi',
  provider_reference_id text,
  provider_transaction_id text,
  plan_id text references subscription_plans (id),
  sms_package_id text references sms_packages (id),
  billing_cycle text,
  payer_phone text,
  metadata jsonb not null default '{}'::jsonb,
  error_message text,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  updated_at timestamptz not null default now()
);

create index if not exists idx_payment_tx_store on payment_transactions (store_id, created_at desc);
create index if not exists idx_payment_tx_status on payment_transactions (status);
create index if not exists idx_payment_tx_provider_ref on payment_transactions (provider_reference_id);

-- ---------------------------------------------------------------------------
-- Payment webhook audit log
-- ---------------------------------------------------------------------------

create table if not exists payment_webhook_events (
  id text primary key,
  provider text not null default 'waafi',
  event_type text,
  transaction_id text references payment_transactions (id) on delete set null,
  payload jsonb not null default '{}'::jsonb,
  processed boolean not null default false,
  error_message text,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Billing invoices (receipts for completed payments)
-- ---------------------------------------------------------------------------

create table if not exists billing_invoices (
  id text primary key,
  transaction_id text not null references payment_transactions (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  invoice_number text not null,
  amount_cents integer not null,
  currency_code text not null default 'USD',
  line_items jsonb not null default '[]'::jsonb,
  issued_at timestamptz not null default now(),
  unique (transaction_id)
);

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table billing_settings enable row level security;
alter table sms_packages enable row level security;
alter table store_sms_wallets enable row level security;
alter table payment_transactions enable row level security;
alter table payment_webhook_events enable row level security;
alter table billing_invoices enable row level security;

create policy billing_settings_super_admin on billing_settings
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

create policy billing_settings_read on billing_settings
  for select to authenticated using (true);

create policy sms_packages_read on sms_packages
  for select to authenticated using (is_active = true or public.inventrax_is_super_admin());

create policy sms_packages_admin on sms_packages
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

create policy store_sms_wallets_tenant on store_sms_wallets
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_is_super_admin()
  );

create policy store_sms_wallets_admin on store_sms_wallets
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

create policy payment_tx_tenant on payment_transactions
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_is_super_admin()
  );

create policy payment_tx_insert on payment_transactions
  for insert to authenticated
  with check (tenant_id = public.inventrax_tenant_id());

create policy payment_webhooks_admin on payment_webhook_events
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

create policy billing_invoices_tenant on billing_invoices
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_is_super_admin()
  );

-- ---------------------------------------------------------------------------
-- Ensure SMS wallet on store registration
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_ensure_sms_wallet(
  p_tenant_id text,
  p_store_id text,
  p_initial_balance integer default 50
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into store_sms_wallets (store_id, tenant_id, balance_remaining, balance_purchased)
  values (p_store_id, p_tenant_id, greatest(p_initial_balance, 0), 0)
  on conflict (store_id) do nothing;
end;
$$;

-- ---------------------------------------------------------------------------
-- Store billing snapshot (subscription + SMS wallet)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_store_billing_snapshot()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text;
  v_sub record;
  v_wallet record;
  v_settings record;
  v_days int;
begin
  if v_tenant is null then
    raise exception 'Not authenticated';
  end if;

  select store_id into v_store from profiles where id = auth.uid();
  if v_store is null then
    raise exception 'No store profile';
  end if;

  select * into v_settings from billing_settings where id = 'global';

  select s.*, sp.name as plan_name, sp.monthly_price_cents, sp.yearly_price_cents,
         sp.features, sp.trial_days as plan_trial_days
  into v_sub
  from subscriptions s
  left join subscription_plans sp on sp.id = s.plan_id
  where s.tenant_id = v_tenant
  order by s.created_at desc
  limit 1;

  select * into v_wallet from store_sms_wallets where store_id = v_store;

  if v_wallet is null then
    perform inventrax_ensure_sms_wallet(v_tenant, v_store, 50);
    select * into v_wallet from store_sms_wallets where store_id = v_store;
  end if;

  v_days := null;
  if v_sub.trial_ends_at is not null and v_sub.status = 'trialing' then
    v_days := greatest(0, extract(day from (v_sub.trial_ends_at - now()))::int);
  elsif v_sub.current_period_end is not null then
    v_days := greatest(0, extract(day from (v_sub.current_period_end - now()))::int);
  end if;

  return jsonb_build_object(
    'store_id', v_store,
    'tenant_id', v_tenant,
    'subscription', jsonb_build_object(
      'id', v_sub.id,
      'plan_id', v_sub.plan_id,
      'plan_name', v_sub.plan_name,
      'status', v_sub.status,
      'billing_cycle', v_sub.billing_cycle,
      'trial_ends_at', v_sub.trial_ends_at,
      'current_period_end', v_sub.current_period_end,
      'days_remaining', v_days,
      'monthly_price_cents', v_sub.monthly_price_cents,
      'yearly_price_cents', v_sub.yearly_price_cents,
      'features', v_sub.features
    ),
    'sms_wallet', jsonb_build_object(
      'balance_remaining', coalesce(v_wallet.balance_remaining, 0),
      'balance_purchased', coalesce(v_wallet.balance_purchased, 0),
      'balance_used', coalesce(v_wallet.balance_used, 0)
    ),
    'billing_settings', jsonb_build_object(
      'default_trial_days', coalesce(v_settings.default_trial_days, 14),
      'grace_period_days', coalesce(v_settings.grace_period_days, 3),
      'waafi_enabled', coalesce(v_settings.waafi_enabled, true)
    )
  );
end;
$$;

grant execute on function public.inventrax_store_billing_snapshot to authenticated;

-- ---------------------------------------------------------------------------
-- Create pending payment (store owner)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_billing_create_payment(
  p_payment_type text,
  p_plan_id text default null,
  p_sms_package_id text default null,
  p_billing_cycle text default 'monthly',
  p_payer_phone text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text;
  v_user uuid := auth.uid();
  v_tx_id text := gen_random_uuid()::text;
  v_amount int;
  v_currency text := 'USD';
  v_ref text;
  v_phone text;
begin
  if v_tenant is null or v_user is null then
    raise exception 'Not authenticated';
  end if;

  select store_id into v_store from profiles where id = v_user;
  if v_store is null then raise exception 'No store'; end if;

  v_phone := normalize_phone(p_payer_phone);
  if v_phone is null or length(v_phone) < 7 then
    raise exception 'Valid payer phone required for Waafi payment';
  end if;

  if p_payment_type in ('subscription', 'renewal', 'upgrade') then
    if p_plan_id is null then raise exception 'plan_id required'; end if;
    select
      case when p_billing_cycle = 'yearly' then yearly_price_cents else monthly_price_cents end,
      currency_code
    into v_amount, v_currency
    from subscription_plans where id = p_plan_id and is_active;
    if v_amount is null then raise exception 'Invalid plan'; end if;
    if p_payment_type = 'upgrade' then
      -- proration simplified: full plan price for now
      null;
    end if;
  elsif p_payment_type = 'sms_package' then
    if p_sms_package_id is null then raise exception 'sms_package_id required'; end if;
    select price_cents, currency_code into v_amount, v_currency
    from sms_packages where id = p_sms_package_id and is_active;
    if v_amount is null then raise exception 'Invalid SMS package'; end if;
  else
    raise exception 'Invalid payment_type';
  end if;

  v_ref := 'KULMIS-' || left(replace(v_tx_id, '-', ''), 12);

  insert into payment_transactions (
    id, tenant_id, store_id, user_id, payment_type, status,
    amount_cents, currency_code, provider, provider_reference_id,
    plan_id, sms_package_id, billing_cycle, payer_phone
  ) values (
    v_tx_id, v_tenant, v_store, v_user, p_payment_type, 'pending',
    v_amount, v_currency, 'waafi', v_ref,
    p_plan_id, p_sms_package_id, p_billing_cycle, v_phone
  );

  return jsonb_build_object(
    'transaction_id', v_tx_id,
    'reference_id', v_ref,
    'amount_cents', v_amount,
    'currency_code', v_currency,
    'payment_type', p_payment_type,
    'payer_phone', v_phone
  );
end;
$$;

grant execute on function public.inventrax_billing_create_payment to authenticated;

-- ---------------------------------------------------------------------------
-- Fulfill payment (service role / edge function only)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_billing_fulfill_payment(
  p_transaction_id text,
  p_provider_transaction_id text default null,
  p_status text default 'completed'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
  v_pkg sms_packages%rowtype;
  v_period interval;
  v_invoice_id text;
  v_invoice_no text;
begin
  select * into v_tx from payment_transactions where id = p_transaction_id for update;
  if not found then raise exception 'Transaction not found'; end if;
  if v_tx.status = 'completed' then
    return jsonb_build_object('success', true, 'already_fulfilled', true);
  end if;

  if p_status != 'completed' then
    update payment_transactions set
      status = p_status,
      provider_transaction_id = coalesce(p_provider_transaction_id, provider_transaction_id),
      updated_at = now()
    where id = p_transaction_id;
    return jsonb_build_object('success', false, 'status', p_status);
  end if;

  update payment_transactions set
    status = 'completed',
    provider_transaction_id = coalesce(p_provider_transaction_id, provider_transaction_id),
    completed_at = now(),
    updated_at = now()
  where id = p_transaction_id;

  if v_tx.payment_type in ('subscription', 'renewal', 'upgrade') and v_tx.plan_id is not null then
    v_period := case when v_tx.billing_cycle = 'yearly'
      then interval '1 year' else interval '1 month' end;

    update subscriptions set
      plan_id = v_tx.plan_id,
      plan_name = (select name from subscription_plans where id = v_tx.plan_id),
      status = 'active',
      billing_cycle = coalesce(v_tx.billing_cycle, 'monthly'),
      current_period_end = now() + v_period,
      trial_ends_at = null,
      updated_at = now()
    where tenant_id = v_tx.tenant_id;

    if not found then
      insert into subscriptions (
        id, tenant_id, store_id, plan_id, plan_name, status,
        billing_cycle, current_period_end
      ) values (
        gen_random_uuid()::text, v_tx.tenant_id, v_tx.store_id, v_tx.plan_id,
        (select name from subscription_plans where id = v_tx.plan_id),
        'active', coalesce(v_tx.billing_cycle, 'monthly'), now() + v_period
      );
    end if;
  end if;

  if v_tx.payment_type = 'sms_package' and v_tx.sms_package_id is not null then
    select * into v_pkg from sms_packages where id = v_tx.sms_package_id;
    perform inventrax_ensure_sms_wallet(v_tx.tenant_id, v_tx.store_id, 0);
    update store_sms_wallets set
      balance_remaining = balance_remaining + v_pkg.sms_count,
      balance_purchased = balance_purchased + v_pkg.sms_count,
      updated_at = now()
    where store_id = v_tx.store_id;
  end if;

  v_invoice_id := gen_random_uuid()::text;
  v_invoice_no := 'INV-' || to_char(now(), 'YYYYMMDD') || '-' || left(p_transaction_id, 8);

  insert into billing_invoices (
    id, transaction_id, tenant_id, store_id, invoice_number,
    amount_cents, currency_code, line_items
  ) values (
    v_invoice_id, p_transaction_id, v_tx.tenant_id, v_tx.store_id, v_invoice_no,
    v_tx.amount_cents, v_tx.currency_code,
    jsonb_build_array(jsonb_build_object(
      'type', v_tx.payment_type,
      'plan_id', v_tx.plan_id,
      'sms_package_id', v_tx.sms_package_id,
      'amount_cents', v_tx.amount_cents
    ))
  ) on conflict (transaction_id) do nothing;

  return jsonb_build_object(
    'success', true,
    'transaction_id', p_transaction_id,
    'invoice_number', v_invoice_no
  );
end;
$$;

-- service role only — no grant to authenticated

-- ---------------------------------------------------------------------------
-- Deduct cloud SMS balance (edge functions)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_sms_deduct_credit(
  p_store_id text,
  p_count integer default 1
)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_bal int;
begin
  select balance_remaining into v_bal
  from store_sms_wallets where store_id = p_store_id for update;
  if v_bal is null or v_bal < p_count then
    return false;
  end if;
  update store_sms_wallets set
    balance_remaining = balance_remaining - p_count,
    balance_used = balance_used + p_count,
    updated_at = now()
  where store_id = p_store_id;
  return true;
end;
$$;

-- ---------------------------------------------------------------------------
-- Platform billing analytics
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_platform_billing_analytics()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_result jsonb;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  select jsonb_build_object(
    'total_revenue_cents', coalesce((
      select sum(amount_cents)::bigint from payment_transactions where status = 'completed'
    ), 0),
    'subscription_revenue_cents', coalesce((
      select sum(amount_cents)::bigint from payment_transactions
      where status = 'completed' and payment_type in ('subscription', 'renewal', 'upgrade')
    ), 0),
    'sms_revenue_cents', coalesce((
      select sum(amount_cents)::bigint from payment_transactions
      where status = 'completed' and payment_type = 'sms_package'
    ), 0),
    'active_subscriptions', (select count(*)::int from subscriptions where status = 'active'),
    'trialing_subscriptions', (select count(*)::int from subscriptions where status = 'trialing'),
    'expiring_trials_7d', (select count(*)::int from subscriptions
      where status = 'trialing' and trial_ends_at <= now() + interval '7 days'),
    'failed_payments_30d', (select count(*)::int from payment_transactions
      where status = 'failed' and created_at >= now() - interval '30 days'),
    'total_sms_credits_sold', coalesce((
      select sum((line_items->0->>'amount_cents')::int) from billing_invoices
    ), 0),
    'mrr_cents', coalesce((
      select sum(
        case when s.billing_cycle = 'yearly'
          then sp.yearly_price_cents / 12
          else sp.monthly_price_cents
        end
      )::bigint
      from subscriptions s
      join subscription_plans sp on sp.id = s.plan_id
      where s.status in ('active', 'trialing') and sp.monthly_price_cents > 0
    ), 0)
  ) into v_result;

  return v_result;
end;
$$;

grant execute on function public.inventrax_platform_billing_analytics to authenticated;

-- Patch register_store to create SMS wallet
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
  if v_user_id is null then raise exception 'Not authenticated'; end if;
  if v_store_name is null or v_store_name = '' then raise exception 'Store name is required'; end if;
  if v_phone is null or length(v_phone) < 7 then raise exception 'Valid phone number is required'; end if;
  if not otp_is_phone_verified(v_phone, 'registration', 15) then
    raise exception 'Phone not verified. Complete OTP verification first.';
  end if;
  if exists (select 1 from profiles where id = v_user_id) then
    raise exception 'Account already registered';
  end if;

  select email into v_email from auth.users where id = v_user_id;
  v_name := coalesce(nullif(trim(p_owner_name), ''), split_part(v_email, '@', 1));
  select coalesce(default_trial_days, 14) into v_trial_days from billing_settings where id = 'global';

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

  perform inventrax_ensure_sms_wallet(v_tenant_id, v_store_id, 50);

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
