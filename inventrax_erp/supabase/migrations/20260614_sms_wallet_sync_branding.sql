-- SMS wallet cloud sync, finalize purchase, branded send + usage ledger.

alter table store_sms_wallets replica identity full;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'store_sms_wallets'
  ) then
    alter publication supabase_realtime add table store_sms_wallets;
  end if;
end $$;

-- Failed activation audit (payment ok, credits not applied)
create table if not exists payment_activation_failures (
  id text primary key default gen_random_uuid()::text,
  transaction_id text not null references payment_transactions (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  error_message text not null,
  retry_count integer not null default 0,
  resolved boolean not null default false,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

alter table payment_activation_failures enable row level security;

create policy payment_activation_failures_admin on payment_activation_failures
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

-- Store SMS wallet snapshot (authenticated store owner)
create or replace function public.inventrax_store_sms_wallet()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text;
  v_wallet record;
begin
  if v_tenant is null then raise exception 'Not authenticated'; end if;
  select store_id into v_store from profiles where id = auth.uid();
  if v_store is null then raise exception 'No store profile'; end if;

  perform inventrax_ensure_sms_wallet(v_tenant, v_store, 0);
  select * into v_wallet from store_sms_wallets where store_id = v_store;

  return jsonb_build_object(
    'store_id', v_store,
    'tenant_id', v_tenant,
    'balance_remaining', coalesce(v_wallet.balance_remaining, 0),
    'balance_purchased', coalesce(v_wallet.balance_purchased, 0),
    'balance_used', coalesce(v_wallet.balance_used, 0),
    'updated_at', v_wallet.updated_at
  );
end;
$$;

grant execute on function public.inventrax_store_sms_wallet to authenticated;

-- Idempotent SMS purchase finalization / recovery
create or replace function public.inventrax_finalize_sms_purchase(p_transaction_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
  v_pkg sms_packages%rowtype;
  v_ledger int;
  v_result jsonb;
begin
  select * into v_tx from payment_transactions where id = p_transaction_id;
  if not found then raise exception 'Transaction not found'; end if;

  if v_tx.payment_type != 'sms_package' then
    raise exception 'Not an SMS package transaction';
  end if;

  if v_tx.tenant_id != public.inventrax_tenant_id()
     and not public.inventrax_is_super_admin() then
    raise exception 'Access denied';
  end if;

  if v_tx.status != 'completed' then
    return jsonb_build_object(
      'success', false,
      'status', v_tx.status,
      'message', 'Payment not completed yet'
    );
  end if;

  select count(*)::int into v_ledger
  from sms_wallet_transactions
  where payment_transaction_id = p_transaction_id
    and transaction_type = 'purchase';

  if v_ledger > 0 then
    select balance_remaining into v_ledger from store_sms_wallets where store_id = v_tx.store_id;
    return jsonb_build_object(
      'success', true,
      'already_activated', true,
      'balance_remaining', v_ledger
    );
  end if;

  select * into v_pkg from sms_packages where id = v_tx.sms_package_id;
  if not found then raise exception 'SMS package not found'; end if;

  begin
    perform inventrax_ensure_sms_wallet(v_tx.tenant_id, v_tx.store_id, 0);
    update store_sms_wallets set
      balance_remaining = balance_remaining + v_pkg.sms_count,
      balance_purchased = balance_purchased + v_pkg.sms_count,
      updated_at = now()
    where store_id = v_tx.store_id;

    insert into sms_wallet_transactions (
      store_id, tenant_id, payment_transaction_id, transaction_type,
      sms_count, balance_after, provider, amount_cents, currency_code, description
    )
    select
      v_tx.store_id, v_tx.tenant_id, p_transaction_id, 'purchase',
      v_pkg.sms_count, w.balance_remaining, v_tx.provider,
      v_tx.amount_cents, v_tx.currency_code,
      format('+%s SMS — Purchase %s via Waafi (recovery)', v_pkg.sms_count, v_pkg.name)
    from store_sms_wallets w where w.store_id = v_tx.store_id;
  exception when others then
    insert into payment_activation_failures (
      transaction_id, store_id, tenant_id, error_message
    ) values (
      p_transaction_id, v_tx.store_id, v_tx.tenant_id, SQLERRM
    );
    raise;
  end;

  select balance_remaining into v_ledger from store_sms_wallets where store_id = v_tx.store_id;

  return jsonb_build_object(
    'success', true,
    'activated', true,
    'recovered', true,
    'sms_credits_added', v_pkg.sms_count,
    'balance_remaining', v_ledger
  );
end;
$$;

grant execute on function public.inventrax_finalize_sms_purchase to authenticated;

-- Deduct cloud SMS + usage ledger
create or replace function public.inventrax_sms_deduct_credit(
  p_store_id text,
  p_count integer default 1,
  p_description text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_wallet store_sms_wallets%rowtype;
  v_bal int;
begin
  select * into v_wallet
  from store_sms_wallets
  where store_id = p_store_id
  for update;

  if not found then
    return jsonb_build_object('success', false, 'error', 'SMS wallet not found');
  end if;

  if p_count <= 0 then
    return jsonb_build_object(
      'success', true,
      'check_only', true,
      'balance_remaining', v_wallet.balance_remaining
    );
  end if;

  if v_wallet.balance_remaining < p_count then
    return jsonb_build_object(
      'success', false,
      'error', 'Insufficient SMS balance',
      'balance_remaining', v_wallet.balance_remaining
    );
  end if;

  update store_sms_wallets set
    balance_remaining = balance_remaining - p_count,
    balance_used = balance_used + p_count,
    updated_at = now()
  where store_id = p_store_id
  returning balance_remaining into v_bal;

  insert into sms_wallet_transactions (
    store_id, tenant_id, transaction_type,
    sms_count, balance_after, provider, description
  ) values (
    p_store_id, v_wallet.tenant_id, 'usage',
    -p_count, v_bal, 'hormuud',
    coalesce(p_description, format('-%s SMS sent', p_count))
  );

  return jsonb_build_object(
    'success', true,
    'balance_remaining', v_bal
  );
end;
$$;
