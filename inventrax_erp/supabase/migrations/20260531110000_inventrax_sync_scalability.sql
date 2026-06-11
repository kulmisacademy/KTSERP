-- InventraX: sync scalability — indexes, RLS fixes, column alignment, debt tables.
-- Supports offline-first bidirectional sync and supermarket-scale queries.

-- ---------------------------------------------------------------------------
-- Column alignment for sync (match local Drift schema)
-- ---------------------------------------------------------------------------

alter table products
  add column if not exists image_url text,
  add column if not exists thumbnail_url text,
  add column if not exists category_icon text,
  add column if not exists has_image boolean not null default false,
  add column if not exists created_at timestamptz not null default now();

alter table sales
  add column if not exists paid_cents integer not null default 0,
  add column if not exists payment_status text not null default 'paid';

alter table purchases
  add column if not exists payment_status text not null default 'paid';

alter table customers
  add column if not exists address text,
  add column if not exists created_at timestamptz not null default now();

alter table suppliers
  add column if not exists address text,
  add column if not exists created_at timestamptz not null default now();

alter table stores
  add column if not exists currency_code text default 'USD';

-- ---------------------------------------------------------------------------
-- Performance indexes (PRD §12 — barcode, search, tenant isolation)
-- ---------------------------------------------------------------------------

-- Enable pg_trgm for fuzzy product search (safe if already enabled)
create extension if not exists pg_trgm;

create index if not exists idx_products_barcode_store
  on products (store_id, barcode)
  where barcode is not null;

create index if not exists idx_products_sku_store
  on products (store_id, sku)
  where sku is not null;

create index if not exists idx_products_name_trgm
  on products using gin (name gin_trgm_ops);

create index if not exists idx_sales_tenant_store_created
  on sales (tenant_id, store_id, created_at desc);

create index if not exists idx_purchases_tenant_store_date
  on purchases (tenant_id, store_id, purchase_date desc);

create index if not exists idx_customers_tenant_store
  on customers (tenant_id, store_id);

create index if not exists idx_suppliers_tenant_store
  on suppliers (tenant_id, store_id);

create index if not exists idx_sale_items_tenant_store
  on sale_items (tenant_id, store_id);

create index if not exists idx_purchase_items_tenant_store
  on purchase_items (tenant_id, store_id);

create index if not exists idx_sales_customer
  on sales (store_id, customer_id)
  where customer_id is not null;

create index if not exists idx_purchases_supplier
  on purchases (store_id, supplier_id);

create index if not exists idx_journal_lines_entry
  on journal_lines (journal_entry_id);

-- ---------------------------------------------------------------------------
-- Debt tables (fix broken 20260528100000 migration)
-- ---------------------------------------------------------------------------

create table if not exists debts (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  debt_type text not null,
  supplier_id text,
  customer_id text,
  original_cents integer not null,
  paid_cents integer not null default 0,
  remaining_cents integer not null,
  due_date timestamptz,
  status text not null,
  notes text,
  sale_id text,
  purchase_id text,
  invoice_number text,
  created_at timestamptz not null default now()
);

create table if not exists debt_payments (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  debt_id text not null references debts (id) on delete cascade,
  amount_cents integer not null,
  paid_at timestamptz not null,
  method text,
  payment_account_id text,
  notes text,
  user_id text,
  created_at timestamptz not null default now()
);

create index if not exists idx_debts_store_status
  on debts (store_id, status);

create index if not exists idx_debt_payments_debt
  on debt_payments (debt_id);

alter table debts enable row level security;
alter table debt_payments enable row level security;

drop policy if exists inventrax_debts_all on debts;
create policy inventrax_debts_all on debts
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_debt_payments_all on debt_payments;
create policy inventrax_debt_payments_all on debt_payments
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- ---------------------------------------------------------------------------
-- Accounting RLS (was enabled with zero policies — blocked all access)
-- ---------------------------------------------------------------------------

drop policy if exists inventrax_chart_of_accounts_all on chart_of_accounts;
create policy inventrax_chart_of_accounts_all on chart_of_accounts
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_payment_accounts_all on payment_accounts;
create policy inventrax_payment_accounts_all on payment_accounts
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_journal_entries_all on journal_entries;
create policy inventrax_journal_entries_all on journal_entries
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- journal_lines: isolate via parent journal_entry
drop policy if exists inventrax_journal_lines_all on journal_lines;
create policy inventrax_journal_lines_all on journal_lines
  for all to authenticated
  using (
    exists (
      select 1 from journal_entries je
      where je.id = journal_lines.journal_entry_id
        and je.tenant_id = public.inventrax_tenant_id()
        and je.store_id = public.inventrax_store_id()
    )
  )
  with check (
    exists (
      select 1 from journal_entries je
      where je.id = journal_lines.journal_entry_id
        and je.tenant_id = public.inventrax_tenant_id()
        and je.store_id = public.inventrax_store_id()
    )
  );

-- debt_share_links: store-scoped CRUD + public token read via RPC
drop policy if exists inventrax_debt_share_links_all on debt_share_links;
create policy inventrax_debt_share_links_all on debt_share_links
  for all to authenticated
  using (
    tenant_id::text = public.inventrax_tenant_id()
    and store_id::text = public.inventrax_store_id()
  )
  with check (
    tenant_id::text = public.inventrax_tenant_id()
    and store_id::text = public.inventrax_store_id()
  );

-- ---------------------------------------------------------------------------
-- updated_at triggers for conflict resolution during sync
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_products_updated_at on products;
create trigger trg_products_updated_at
  before update on products
  for each row execute function public.inventrax_set_updated_at();

drop trigger if exists trg_customers_updated_at on customers;
create trigger trg_customers_updated_at
  before update on customers
  for each row execute function public.inventrax_set_updated_at();

drop trigger if exists trg_suppliers_updated_at on suppliers;
create trigger trg_suppliers_updated_at
  before update on suppliers
  for each row execute function public.inventrax_set_updated_at();
