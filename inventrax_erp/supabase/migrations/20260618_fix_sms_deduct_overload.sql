-- Remove legacy boolean overload that breaks send-sms balance checks (returns true, not balance).

drop function if exists public.inventrax_sms_deduct_credit(text, integer);

create or replace function public.inventrax_sms_deduct_credit(
  p_store_id text,
  p_count integer default 1,
  p_description text default null
)
returns jsonb
language plpgsql
volatile
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
    return jsonb_build_object(
      'success', false,
      'error', 'SMS wallet not found',
      'balance_remaining', 0
    );
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

grant execute on function public.inventrax_sms_deduct_credit(text, integer, text) to service_role;
grant execute on function public.inventrax_sms_deduct_credit(text, integer, text) to authenticated;
