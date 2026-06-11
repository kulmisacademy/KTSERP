-- Allow edge functions (service role, auth.uid() null) to recover SMS purchases.

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
  v_balance int;
begin
  select * into v_tx from payment_transactions where id = p_transaction_id;
  if not found then raise exception 'Transaction not found'; end if;

  if v_tx.payment_type != 'sms_package' then
    raise exception 'Not an SMS package transaction';
  end if;

  if auth.uid() is not null
     and v_tx.tenant_id != public.inventrax_tenant_id()
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
    select balance_remaining into v_balance from store_sms_wallets where store_id = v_tx.store_id;
    return jsonb_build_object(
      'success', true,
      'already_activated', true,
      'balance_remaining', v_balance
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

  select balance_remaining into v_balance from store_sms_wallets where store_id = v_tx.store_id;

  return jsonb_build_object(
    'success', true,
    'activated', true,
    'recovered', true,
    'sms_credits_added', v_pkg.sms_count,
    'balance_remaining', v_balance
  );
end;
$$;

grant execute on function public.inventrax_finalize_sms_purchase to service_role;
