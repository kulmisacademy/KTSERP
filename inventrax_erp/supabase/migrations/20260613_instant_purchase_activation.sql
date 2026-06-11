-- Server-verified purchase activation: wallet ledger, duplicate guard, enriched status.

-- ---------------------------------------------------------------------------
-- SMS wallet transaction ledger
-- ---------------------------------------------------------------------------

create table if not exists sms_wallet_transactions (
  id text primary key default gen_random_uuid()::text,
  store_id text not null references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  payment_transaction_id text references payment_transactions (id) on delete set null,
  transaction_type text not null check (
    transaction_type in ('purchase', 'usage', 'adjustment', 'bonus')
  ),
  sms_count integer not null,
  balance_after integer,
  provider text default 'waafi',
  amount_cents integer,
  currency_code text default 'USD',
  description text,
  created_at timestamptz not null default now()
);

create index if not exists idx_sms_wallet_tx_store
  on sms_wallet_transactions (store_id, created_at desc);

alter table sms_wallet_transactions enable row level security;

create policy sms_wallet_tx_tenant on sms_wallet_transactions
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_is_super_admin()
  );

-- ---------------------------------------------------------------------------
-- Prevent duplicate in-flight payments per store
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
  v_pending int;
begin
  if v_tenant is null or v_user is null then
    raise exception 'Not authenticated';
  end if;

  select store_id into v_store from profiles where id = v_user;
  if v_store is null then raise exception 'No store'; end if;

  select count(*)::int into v_pending
  from payment_transactions
  where store_id = v_store
    and status in ('pending', 'processing')
    and created_at > now() - interval '5 minutes';

  if v_pending > 0 then
    raise exception 'A payment is already in progress. Please wait for it to finish.';
  end if;

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

-- ---------------------------------------------------------------------------
-- Cancel in-flight payment (store owner)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_billing_cancel_payment(p_transaction_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_tx from payment_transactions where id = p_transaction_id;
  if not found then raise exception 'Transaction not found'; end if;

  if v_tx.tenant_id != public.inventrax_tenant_id()
     and not public.inventrax_is_super_admin() then
    raise exception 'Access denied';
  end if;

  if v_tx.status not in ('pending', 'processing') then
    return jsonb_build_object(
      'cancelled', false,
      'status', v_tx.status,
      'message', 'Payment can no longer be cancelled'
    );
  end if;

  update payment_transactions set
    status = 'cancelled',
    error_message = 'Cancelled by user',
    updated_at = now()
  where id = p_transaction_id;

  return jsonb_build_object('cancelled', true, 'status', 'cancelled');
end;
$$;

grant execute on function public.inventrax_billing_cancel_payment to authenticated;

-- ---------------------------------------------------------------------------
-- Fulfill payment — server-side activation + SMS wallet ledger entry
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
  v_wallet_balance int;
  v_plan_name text;
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
    select name into v_plan_name from subscription_plans where id = v_tx.plan_id;
    v_period := case when v_tx.billing_cycle = 'yearly'
      then interval '1 year' else interval '1 month' end;

    update subscriptions set
      plan_id = v_tx.plan_id,
      plan_name = v_plan_name,
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
        v_plan_name, 'active', coalesce(v_tx.billing_cycle, 'monthly'), now() + v_period
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
    where store_id = v_tx.store_id
    returning balance_remaining into v_wallet_balance;

    insert into sms_wallet_transactions (
      store_id, tenant_id, payment_transaction_id, transaction_type,
      sms_count, balance_after, provider, amount_cents, currency_code, description
    ) values (
      v_tx.store_id, v_tx.tenant_id, p_transaction_id, 'purchase',
      v_pkg.sms_count, v_wallet_balance, v_tx.provider,
      v_tx.amount_cents, v_tx.currency_code,
      format('+%s SMS — Purchase %s via Waafi', v_pkg.sms_count, v_pkg.name)
    );
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
    'invoice_number', v_invoice_no,
    'sms_credits_added', case when v_pkg.id is not null then v_pkg.sms_count else null end,
    'wallet_balance', v_wallet_balance,
    'plan_name', v_plan_name,
    'plan_activated', v_plan_name is not null
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Enriched payment status — includes server-verified activation details
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_billing_payment_status(p_transaction_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
  v_pkg sms_packages%rowtype;
  v_wallet int;
  v_plan_name text;
  v_sms_ledger int;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_tx from payment_transactions where id = p_transaction_id;
  if not found then raise exception 'Transaction not found'; end if;

  if v_tx.tenant_id != public.inventrax_tenant_id()
     and not public.inventrax_is_super_admin() then
    raise exception 'Access denied';
  end if;

  if v_tx.sms_package_id is not null then
    select * into v_pkg from sms_packages where id = v_tx.sms_package_id;
  end if;

  if v_tx.plan_id is not null then
    select name into v_plan_name from subscription_plans where id = v_tx.plan_id;
  end if;

  select balance_remaining into v_wallet
  from store_sms_wallets where store_id = v_tx.store_id;

  if v_tx.status = 'completed' and v_tx.payment_type = 'sms_package' then
    select sms_count into v_sms_ledger
    from sms_wallet_transactions
    where payment_transaction_id = p_transaction_id
    order by created_at desc
    limit 1;
  end if;

  return jsonb_build_object(
    'transaction_id', v_tx.id,
    'status', v_tx.status,
    'payment_type', v_tx.payment_type,
    'amount_cents', v_tx.amount_cents,
    'currency_code', v_tx.currency_code,
    'error_message', v_tx.error_message,
    'provider', v_tx.provider,
    'provider_transaction_id', v_tx.provider_transaction_id,
    'provider_reference_id', v_tx.provider_reference_id,
    'payer_phone', v_tx.payer_phone,
    'completed_at', v_tx.completed_at,
    'updated_at', v_tx.updated_at,
    'verified', v_tx.status = 'completed' and v_tx.completed_at is not null,
    'sms_credits_added', coalesce(v_sms_ledger, v_pkg.sms_count),
    'sms_package_name', v_pkg.name,
    'wallet_balance', v_wallet,
    'plan_name', v_plan_name
  );
end;
$$;
