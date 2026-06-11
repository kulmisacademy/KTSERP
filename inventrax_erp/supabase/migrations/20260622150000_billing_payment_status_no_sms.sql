-- Payment status RPC: remove references to dropped SMS tables.

create or replace function public.inventrax_billing_payment_status(p_transaction_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
  v_plan_name text;
  v_verified boolean;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;

  select * into v_tx from payment_transactions where id = p_transaction_id;
  if not found then raise exception 'Transaction not found'; end if;

  if v_tx.tenant_id != public.inventrax_tenant_id()
     and not public.inventrax_is_super_admin() then
    raise exception 'Access denied';
  end if;

  if v_tx.plan_id is not null then
    select name into v_plan_name from subscription_plans where id = v_tx.plan_id;
  end if;

  v_verified := v_tx.status = 'completed' and v_tx.completed_at is not null;

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
    'plan_name', v_plan_name
  );
end;
$$;

grant execute on function public.inventrax_billing_payment_status to authenticated;
