-- Waafi mobile push payment: expired status, realtime, status RPC

alter table payment_transactions drop constraint if exists payment_transactions_status_check;
alter table payment_transactions add constraint payment_transactions_status_check
  check (status in (
    'pending', 'processing', 'completed', 'failed',
    'refunded', 'cancelled', 'expired'
  ));

-- Realtime updates for payment status polling in Flutter
alter table payment_transactions replica identity full;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'payment_transactions'
  ) then
    alter publication supabase_realtime add table payment_transactions;
  end if;
end $$;

create or replace function public.inventrax_billing_payment_status(p_transaction_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_tx payment_transactions%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into v_tx
  from payment_transactions
  where id = p_transaction_id;

  if not found then
    raise exception 'Transaction not found';
  end if;

  if v_tx.tenant_id != public.inventrax_tenant_id()
     and not public.inventrax_is_super_admin() then
    raise exception 'Access denied';
  end if;

  return jsonb_build_object(
    'transaction_id', v_tx.id,
    'status', v_tx.status,
    'payment_type', v_tx.payment_type,
    'amount_cents', v_tx.amount_cents,
    'currency_code', v_tx.currency_code,
    'error_message', v_tx.error_message,
    'provider_transaction_id', v_tx.provider_transaction_id,
    'completed_at', v_tx.completed_at,
    'updated_at', v_tx.updated_at
  );
end;
$$;

grant execute on function public.inventrax_billing_payment_status to authenticated;
