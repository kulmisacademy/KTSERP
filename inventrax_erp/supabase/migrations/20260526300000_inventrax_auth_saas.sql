-- InventraX SaaS auth: tenants, stores, profiles, roles, subscriptions, register_store RPC.
-- Apply after prior migrations. Disable email confirmation for dev, or confirm email before first login.

-- ---------------------------------------------------------------------------
-- Core SaaS tables
-- ---------------------------------------------------------------------------

create table if not exists tenants (
  id text primary key,
  name text not null,
  country text not null default '',
  currency_code text not null default 'USD',
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists stores (
  id text primary key,
  tenant_id text not null references tenants (id) on delete cascade,
  name text not null,
  business_type text not null default 'Retail',
  address text,
  country text not null default '',
  currency_code text not null default 'USD',
  tax_number text,
  logo_url text,
  status text not null default 'active',
  created_at timestamptz not null default now()
);

create table if not exists roles (
  id text primary key,
  name text not null unique,
  permissions jsonb not null default '[]'::jsonb,
  description text
);

insert into roles (id, name, permissions, description) values
  ('super_admin', 'Super Admin', '["*"]'::jsonb, 'Platform owner'),
  ('store_owner', 'Store Owner', '["store.*","users.manage","reports.*","settings.*"]'::jsonb, 'Full store access'),
  ('manager', 'Manager', '["pos.*","inventory.*","purchases.*","reports.view"]'::jsonb, 'Operations manager'),
  ('cashier', 'Cashier', '["pos.checkout","products.view"]'::jsonb, 'POS cashier'),
  ('accountant', 'Accountant', '["reports.*","expenses.*","debts.*"]'::jsonb, 'Finance')
on conflict (id) do nothing;

create table if not exists profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  role_id text not null references roles (id) default 'store_owner',
  full_name text not null,
  email text not null,
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (id)
);

create table if not exists subscriptions (
  id text primary key,
  tenant_id text not null references tenants (id) on delete cascade,
  plan_name text not null default 'Free Trial',
  status text not null default 'trialing',
  trial_ends_at timestamptz,
  current_period_end timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_stores_tenant on stores (tenant_id);
create index if not exists idx_profiles_store on profiles (store_id);
create index if not exists idx_profiles_tenant on profiles (tenant_id);

-- ---------------------------------------------------------------------------
-- JWT helpers (profile-first, then metadata, then dev fallback)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_tenant_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select tenant_id from profiles where id = auth.uid() and is_active),
    nullif(auth.jwt() -> 'user_metadata' ->> 'tenant_id', ''),
    nullif(auth.jwt() -> 'app_metadata' ->> 'tenant_id', ''),
    'dev-tenant'
  );
$$;

create or replace function public.inventrax_store_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select store_id from profiles where id = auth.uid() and is_active),
    nullif(auth.jwt() -> 'user_metadata' ->> 'store_id', ''),
    nullif(auth.jwt() -> 'app_metadata' ->> 'store_id', ''),
    'dev-store'
  );
$$;

create or replace function public.inventrax_role_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select role_id from profiles where id = auth.uid() and is_active),
    'cashier'
  );
$$;

-- ---------------------------------------------------------------------------
-- register_store: called once after sign-up (authenticated)
-- ---------------------------------------------------------------------------

create or replace function public.register_store(
  p_store_name text,
  p_business_type text,
  p_country text,
  p_currency text,
  p_address text default null,
  p_owner_name text default null,
  p_phone text default null,
  p_tax_number text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_email text;
  v_tenant_id text := gen_random_uuid()::text;
  v_store_id text := gen_random_uuid()::text;
  v_sub_id text := gen_random_uuid()::text;
  v_name text;
begin
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if exists (select 1 from profiles where id = v_user_id) then
    raise exception 'Account already registered';
  end if;

  select email into v_email from auth.users where id = v_user_id;
  v_name := coalesce(nullif(trim(p_owner_name), ''), split_part(v_email, '@', 1));

  insert into tenants (id, name, country, currency_code)
  values (v_tenant_id, trim(p_store_name), coalesce(p_country, ''), coalesce(p_currency, 'USD'));

  insert into stores (
    id, tenant_id, name, business_type, address, country, currency_code, tax_number
  ) values (
    v_store_id,
    v_tenant_id,
    trim(p_store_name),
    coalesce(nullif(trim(p_business_type), ''), 'Retail'),
    p_address,
    coalesce(p_country, ''),
    coalesce(p_currency, 'USD'),
    p_tax_number
  );

  insert into profiles (id, tenant_id, store_id, role_id, full_name, email, phone)
  values (
    v_user_id,
    v_tenant_id,
    v_store_id,
    'store_owner',
    v_name,
    coalesce(v_email, ''),
    p_phone
  );

  insert into subscriptions (id, tenant_id, plan_name, status, trial_ends_at)
  values (
    v_sub_id,
    v_tenant_id,
    'Free Trial',
    'trialing',
    now() + interval '14 days'
  );

  return jsonb_build_object(
    'tenant_id', v_tenant_id,
    'store_id', v_store_id,
    'role_id', 'store_owner',
    'store_name', trim(p_store_name)
  );
end;
$$;

grant execute on function public.register_store to authenticated;

-- ---------------------------------------------------------------------------
-- RLS for SaaS tables
-- ---------------------------------------------------------------------------

alter table tenants enable row level security;
alter table stores enable row level security;
alter table profiles enable row level security;
alter table subscriptions enable row level security;
alter table roles enable row level security;

-- Roles: readable by authenticated users
drop policy if exists inventrax_roles_read on roles;
create policy inventrax_roles_read on roles
  for select to authenticated using (true);

-- Tenants: members of tenant only; super_admin sees all (via role)
drop policy if exists inventrax_tenants_select on tenants;
create policy inventrax_tenants_select on tenants
  for select to authenticated
  using (
    id = public.inventrax_tenant_id()
    or public.inventrax_role_id() = 'super_admin'
  );

-- Stores: same tenant
drop policy if exists inventrax_stores_all on stores;
create policy inventrax_stores_all on stores
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_role_id() = 'super_admin'
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_role_id() = 'super_admin'
  );

-- Profiles: own row or same store (for managers inviting users later)
drop policy if exists inventrax_profiles_select on profiles;
create policy inventrax_profiles_select on profiles
  for select to authenticated
  using (
    id = auth.uid()
    or (
      store_id = public.inventrax_store_id()
      and tenant_id = public.inventrax_tenant_id()
    )
    or public.inventrax_role_id() = 'super_admin'
  );

drop policy if exists inventrax_profiles_insert_self on profiles;
create policy inventrax_profiles_insert_self on profiles
  for insert to authenticated
  with check (id = auth.uid());

-- Subscriptions: tenant scoped
drop policy if exists inventrax_subscriptions_select on subscriptions;
create policy inventrax_subscriptions_select on subscriptions
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    or public.inventrax_role_id() = 'super_admin'
  );

-- Allow authenticated users to insert tenant/store during register_store (security definer handles it)
-- No direct insert policies on tenants/stores for clients — RPC only.
