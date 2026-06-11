-- InventraX: operational tables missing in cloud (categories, brands, expenses)
-- Aligns with local Drift tables and enables bidirectional sync at scale.

create extension if not exists pg_trgm;

-- ---------------------------------------------------------------------------
-- Categories
-- ---------------------------------------------------------------------------

create table if not exists categories (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  parent_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_categories_tenant_store
  on categories (tenant_id, store_id);

create index if not exists idx_categories_store_name_trgm
  on categories using gin (name gin_trgm_ops);

alter table categories enable row level security;

drop policy if exists inventrax_categories_all on categories;
create policy inventrax_categories_all on categories
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
-- Brands
-- ---------------------------------------------------------------------------

create table if not exists brands (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_brands_tenant_store
  on brands (tenant_id, store_id);

create index if not exists idx_brands_store_name_trgm
  on brands using gin (name gin_trgm_ops);

alter table brands enable row level security;

drop policy if exists inventrax_brands_all on brands;
create policy inventrax_brands_all on brands
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
-- Expenses
-- ---------------------------------------------------------------------------

create table if not exists expenses (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  category text not null,
  amount_cents integer not null,
  expense_date timestamptz not null,
  paid_by text,
  receipt_image_url text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_expenses_tenant_store_date
  on expenses (tenant_id, store_id, expense_date desc);

alter table expenses enable row level security;

drop policy if exists inventrax_expenses_all on expenses;
create policy inventrax_expenses_all on expenses
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
-- updated_at triggers
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_categories_updated_at on categories;
create trigger trg_categories_updated_at
  before update on categories
  for each row execute function public.inventrax_touch_updated_at();

drop trigger if exists trg_brands_updated_at on brands;
create trigger trg_brands_updated_at
  before update on brands
  for each row execute function public.inventrax_touch_updated_at();

drop trigger if exists trg_expenses_updated_at on expenses;
create trigger trg_expenses_updated_at
  before update on expenses
  for each row execute function public.inventrax_touch_updated_at();

