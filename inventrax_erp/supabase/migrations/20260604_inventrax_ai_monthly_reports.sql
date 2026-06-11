-- Monthly AI report deduplication (one report per store per calendar month).

create table if not exists store_ai_report_periods (
  store_id text not null references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  period text not null,
  summary text,
  created_at timestamptz not null default now(),
  primary key (store_id, period)
);

create index if not exists idx_store_ai_report_period on store_ai_report_periods (period);

alter table store_ai_report_periods enable row level security;

drop policy if exists inventrax_ai_report_periods_read on store_ai_report_periods;
create policy inventrax_ai_report_periods_read on store_ai_report_periods
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_ai_report_periods_insert on store_ai_report_periods;
create policy inventrax_ai_report_periods_insert on store_ai_report_periods
  for insert to authenticated
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_ai_report_periods_update on store_ai_report_periods;
create policy inventrax_ai_report_periods_update on store_ai_report_periods
  for update to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Returns true if this device may generate the monthly report (first claim wins).
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

grant execute on function public.inventrax_try_claim_ai_monthly_report(text) to authenticated;
