-- Fix inventrax_try_claim_ai_monthly_report: ROW_COUNT is integer, not boolean.

create or replace function public.inventrax_try_claim_ai_monthly_report(p_period text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant text;
  v_store text;
  v_rows integer;
begin
  v_tenant := public.inventrax_tenant_id();
  v_store := public.inventrax_store_id();

  insert into store_ai_report_periods (store_id, tenant_id, period)
  values (v_store, v_tenant, p_period)
  on conflict (store_id, period) do nothing;

  get diagnostics v_rows = row_count;
  return v_rows > 0;
end;
$$;
