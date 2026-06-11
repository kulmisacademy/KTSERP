-- Atomic SMS payment fulfillment: NEVER mark completed without crediting wallet.

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
  v_ledger_exists int;
  v_credits_added int;
begin
  select * into v_tx from payment_transactions where id = p_transaction_id for update;
  if not found then raise exception 'Transaction not found'; end if;

  -- Already completed: ensure SMS ledger exists (recovery path)
  if v_tx.status = 'completed' then
    if v_tx.payment_type = 'sms_package' and v_tx.sms_package_id is not null then
      select count(*)::int into v_ledger_exists
      from sms_wallet_transactions
      where payment_transaction_id = p_transaction_id
        and transaction_type = 'purchase';

      if v_ledger_exists = 0 then
        select * into v_pkg from sms_packages where id = v_tx.sms_package_id;
        if not found then
          raise exception 'SMS package % not found for completed payment', v_tx.sms_package_id;
        end if;
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
          format('+%s SMS — Purchase %s via Waafi (recovered)', v_pkg.sms_count, v_pkg.name)
        );
        v_credits_added := v_pkg.sms_count;
      else
        select balance_remaining into v_wallet_balance
        from store_sms_wallets where store_id = v_tx.store_id;
      end if;
    end if;

    return jsonb_build_object(
      'success', true,
      'already_fulfilled', true,
      'wallet_balance', v_wallet_balance,
      'sms_credits_added', v_credits_added
    );
  end if;

  if p_status != 'completed' then
    update payment_transactions set
      status = p_status,
      provider_transaction_id = coalesce(p_provider_transaction_id, provider_transaction_id),
      updated_at = now()
    where id = p_transaction_id;
    return jsonb_build_object('success', false, 'status', p_status);
  end if;

  -- Subscription activation (before marking completed)
  if v_tx.payment_type in ('subscription', 'renewal', 'upgrade') and v_tx.plan_id is not null then
    select name into v_plan_name from subscription_plans where id = v_tx.plan_id;
    if not found then
      raise exception 'Subscription plan % not found', v_tx.plan_id;
    end if;
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

  -- SMS wallet credit MUST succeed before payment marked completed
  if v_tx.payment_type = 'sms_package' then
    if v_tx.sms_package_id is null then
      raise exception 'sms_package_id missing on SMS payment transaction';
    end if;

    select * into v_pkg from sms_packages where id = v_tx.sms_package_id;
    if not found then
      raise exception 'SMS package % not found or inactive', v_tx.sms_package_id;
    end if;

    if coalesce(v_pkg.sms_count, 0) <= 0 then
      raise exception 'SMS package % has invalid sms_count', v_tx.sms_package_id;
    end if;

    perform inventrax_ensure_sms_wallet(v_tx.tenant_id, v_tx.store_id, 0);

    update store_sms_wallets set
      balance_remaining = balance_remaining + v_pkg.sms_count,
      balance_purchased = balance_purchased + v_pkg.sms_count,
      updated_at = now()
    where store_id = v_tx.store_id
    returning balance_remaining into v_wallet_balance;

    if v_wallet_balance is null or v_wallet_balance < v_pkg.sms_count then
      raise exception 'SMS wallet credit failed for store %', v_tx.store_id;
    end if;

    insert into sms_wallet_transactions (
      store_id, tenant_id, payment_transaction_id, transaction_type,
      sms_count, balance_after, provider, amount_cents, currency_code, description
    ) values (
      v_tx.store_id, v_tx.tenant_id, p_transaction_id, 'purchase',
      v_pkg.sms_count, v_wallet_balance, v_tx.provider,
      v_tx.amount_cents, v_tx.currency_code,
      format('+%s SMS — Purchase %s via Waafi', v_pkg.sms_count, v_pkg.name)
    );

    v_credits_added := v_pkg.sms_count;
  end if;

  -- Mark payment completed ONLY after wallet/plan updates succeed
  update payment_transactions set
    status = 'completed',
    provider_transaction_id = coalesce(p_provider_transaction_id, provider_transaction_id),
    completed_at = now(),
    updated_at = now()
  where id = p_transaction_id;

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
      'amount_cents', v_tx.amount_cents,
      'sms_credits_added', v_credits_added
    ))
  ) on conflict (transaction_id) do nothing;

  return jsonb_build_object(
    'success', true,
    'transaction_id', p_transaction_id,
    'invoice_number', v_invoice_no,
    'sms_credits_added', v_credits_added,
    'wallet_balance', v_wallet_balance,
    'plan_name', v_plan_name,
    'plan_activated', v_plan_name is not null
  );
exception
  when others then
    insert into payment_activation_failures (
      transaction_id, store_id, tenant_id, error_message
    ) values (
      p_transaction_id, v_tx.store_id, v_tx.tenant_id, SQLERRM
    );
    raise;
end;
$$;

-- Payment verified only when SMS ledger exists for SMS purchases
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
  v_verified boolean;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

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
    select coalesce(sum(sms_count), 0)::int into v_sms_ledger
    from sms_wallet_transactions
    where payment_transaction_id = p_transaction_id
      and transaction_type = 'purchase';
  end if;

  v_verified := v_tx.status = 'completed'
    and v_tx.completed_at is not null
    and (
      v_tx.payment_type != 'sms_package'
      or (coalesce(v_sms_ledger, 0) > 0 and coalesce(v_wallet, 0) > 0)
    );

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
    'verified', v_verified,
    'sms_credits_added', coalesce(v_sms_ledger, v_pkg.sms_count),
    'sms_package_name', v_pkg.name,
    'wallet_balance', v_wallet,
    'plan_name', v_plan_name
  );
end;
$$;
