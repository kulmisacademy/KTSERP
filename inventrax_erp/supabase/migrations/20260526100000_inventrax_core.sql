-- InventraX ERP core schema (Supabase). Apply via Supabase CLI or SQL editor.
-- Then apply: 20260526200000_inventrax_rls_and_tables.sql (RLS, sale_items, purchases).

create table if not exists products (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  barcode text,
  sku text,
  quantity integer not null default 0,
  purchase_price_cents integer not null,
  selling_price_cents integer not null,
  updated_at timestamptz not null default now()
);

create table if not exists sales (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  subtotal_cents integer not null,
  discount_cents integer not null default 0,
  tax_cents integer not null default 0,
  total_cents integer not null,
  refunded_total_cents integer not null default 0,
  status text not null default 'completed',
  payment_json jsonb not null default '{}',
  created_at timestamptz not null default now()
);

alter table products enable row level security;
alter table sales enable row level security;
-- Policies: see 20260526200000_inventrax_rls_and_tables.sql
