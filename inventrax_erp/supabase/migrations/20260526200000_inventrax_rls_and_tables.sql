-- InventraX: child tables, column alignment, indexes, JWT helpers, RLS.
-- Apply after 20260526100000_inventrax_core.sql via Supabase CLI or SQL editor.
--
-- JWT: set app_metadata on users, e.g.
--   { "tenant_id": "dev-tenant", "store_id": "dev-store" }
-- Until claims exist, helpers fall back to dev-tenant / dev-store (local ERP defaults).

-- ---------------------------------------------------------------------------
-- Column alignment (safe if core migration already ran)
-- ---------------------------------------------------------------------------

alter table products
  add column if not exists secondary_name text,
  add column if not exists barcode_type text default 'code128',
  add column if not exists scan_count integer not null default 0;

alter table sales
  add column if not exists customer_id text,
  add column if not exists refunded_total_cents integer not null default 0,
  add column if not exists voided_at timestamptz,
  add column if not exists void_reason text;

-- Ensure payment_json is jsonb (text from older drafts → migrate if needed)
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'sales'
      and column_name = 'payment_json' and data_type = 'text'
  ) then
    alter table sales
      alter column payment_json type jsonb
      using coalesce(payment_json::jsonb, '{}'::jsonb);
  end if;
exception when others then
  null;
end $$;

-- ---------------------------------------------------------------------------
-- Child & reference tables
-- ---------------------------------------------------------------------------

create table if not exists sale_items (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  sale_id text not null references sales (id) on delete cascade,
  product_id text,
  name text not null,
  quantity integer not null,
  unit_price_cents integer not null,
  line_total_cents integer not null,
  refunded_quantity integer not null default 0
);

create table if not exists suppliers (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  phone text,
  email text,
  updated_at timestamptz not null default now()
);

create table if not exists customers (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  phone text,
  email text,
  updated_at timestamptz not null default now()
);

create table if not exists purchases (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  supplier_id text not null,
  invoice_number text,
  total_cents integer not null,
  paid_cents integer not null default 0,
  purchase_date timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists purchase_items (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  purchase_id text not null references purchases (id) on delete cascade,
  product_id text not null,
  quantity integer not null,
  purchase_price_cents integer not null,
  line_total_cents integer not null
);

create index if not exists idx_products_store on products (store_id);
create index if not exists idx_products_tenant_store on products (tenant_id, store_id);
create index if not exists idx_sales_store_created on sales (store_id, created_at desc);
create index if not exists idx_sale_items_sale on sale_items (sale_id);
create index if not exists idx_purchases_store_date on purchases (store_id, purchase_date desc);
create index if not exists idx_purchase_items_purchase on purchase_items (purchase_id);

-- ---------------------------------------------------------------------------
-- JWT helpers (match Flutter StoreContext defaults when claims missing)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_tenant_id()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(auth.jwt() -> 'app_metadata' ->> 'tenant_id', ''),
    nullif(auth.jwt() ->> 'tenant_id', ''),
    'dev-tenant'
  );
$$;

create or replace function public.inventrax_store_id()
returns text
language sql
stable
as $$
  select coalesce(
    nullif(auth.jwt() -> 'app_metadata' ->> 'store_id', ''),
    nullif(auth.jwt() ->> 'store_id', ''),
    'dev-store'
  );
$$;

-- ---------------------------------------------------------------------------
-- Row level security
-- ---------------------------------------------------------------------------

alter table sale_items enable row level security;
alter table purchase_items enable row level security;
alter table purchases enable row level security;
alter table suppliers enable row level security;
alter table customers enable row level security;

-- Products
drop policy if exists inventrax_products_all on products;
create policy inventrax_products_all on products
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Sales
drop policy if exists inventrax_sales_all on sales;
create policy inventrax_sales_all on sales
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Sale items (via parent sale store)
drop policy if exists inventrax_sale_items_all on sale_items;
create policy inventrax_sale_items_all on sale_items
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Purchases
drop policy if exists inventrax_purchases_all on purchases;
create policy inventrax_purchases_all on purchases
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Purchase items
drop policy if exists inventrax_purchase_items_all on purchase_items;
create policy inventrax_purchase_items_all on purchase_items
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Suppliers / customers
drop policy if exists inventrax_suppliers_all on suppliers;
create policy inventrax_suppliers_all on suppliers
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop policy if exists inventrax_customers_all on customers;
create policy inventrax_customers_all on customers
  for all
  to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );
