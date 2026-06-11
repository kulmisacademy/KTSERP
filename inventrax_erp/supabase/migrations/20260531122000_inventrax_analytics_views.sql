-- InventraX: analytics/materialized views for high-volume reporting
-- Goal: keep Flutter reports lightweight by serving pre-aggregated data.

-- Daily sales summary (per store)
create materialized view if not exists public.daily_sales_summary as
select
  tenant_id,
  store_id,
  date_trunc('day', created_at)::date as day,
  count(*) filter (where status != 'voided') as invoices_count,
  sum(total_cents) filter (where status != 'voided') as gross_sales_cents,
  sum(discount_cents) filter (where status != 'voided') as discounts_cents,
  sum(tax_cents) filter (where status != 'voided') as tax_cents
from public.sales
group by tenant_id, store_id, date_trunc('day', created_at)::date;

create unique index if not exists daily_sales_summary_uidx
  on public.daily_sales_summary (tenant_id, store_id, day);

-- Top products (per store, per day)
create materialized view if not exists public.top_products_summary as
select
  s.tenant_id,
  s.store_id,
  date_trunc('day', s.created_at)::date as day,
  i.product_id,
  max(i.name) as product_name,
  sum(i.quantity) as qty_sold,
  sum(i.line_total_cents) as revenue_cents
from public.sales s
join public.sale_items i on i.sale_id = s.id
where s.status != 'voided'
group by s.tenant_id, s.store_id, date_trunc('day', s.created_at)::date, i.product_id;

create index if not exists top_products_summary_idx
  on public.top_products_summary (tenant_id, store_id, day, revenue_cents desc);

-- Refresh helper (SECURITY DEFINER) so app can request refresh without elevated role.
create or replace function public.refresh_analytics(p_tenant_id text, p_store_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  -- In Supabase, REFRESH CONCURRENTLY requires unique index. We created one.
  refresh materialized view concurrently public.daily_sales_summary;
  refresh materialized view concurrently public.top_products_summary;
end;
$$;

revoke all on function public.refresh_analytics(text, text) from public;
grant execute on function public.refresh_analytics(text, text) to authenticated;

