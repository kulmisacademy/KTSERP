-- InventraX User Management & RBAC
-- Tables: permissions, role_permissions, user_permissions, user_activity_logs
-- Extends profiles; seeds default roles; RLS + helper functions + store user RPCs

-- ---------------------------------------------------------------------------
-- Permission catalog
-- ---------------------------------------------------------------------------

create table if not exists permissions (
  id text primary key,
  module text not null,
  action text not null,
  label text not null,
  description text,
  sort_order integer not null default 0,
  unique (module, action)
);

insert into permissions (id, module, action, label, description, sort_order) values
  ('dashboard.view', 'dashboard', 'view', 'View dashboard', 'Access main dashboard', 10),
  ('pos.checkout', 'pos', 'checkout', 'POS checkout', 'Use point of sale', 20),
  ('pos.hold_sale', 'pos', 'hold_sale', 'Hold sales', 'Park/hold carts', 21),
  ('pos.override_price', 'pos', 'override_price', 'Override prices', 'Change price at checkout', 22),
  ('sales.view', 'sales', 'view', 'View sales', 'Sales history', 30),
  ('sales.create', 'sales', 'create', 'Create sales', 'Record sales', 31),
  ('sales.delete', 'sales', 'delete', 'Delete/void sales', 'Void or delete sales', 32),
  ('sales.refund', 'sales', 'refund', 'Refund sales', 'Process refunds', 33),
  ('products.view', 'products', 'view', 'View products', 'Browse catalog', 40),
  ('products.create', 'products', 'create', 'Create products', 'Add products', 41),
  ('products.edit', 'products', 'edit', 'Edit products', 'Update products', 42),
  ('products.delete', 'products', 'delete', 'Delete products', 'Remove products', 43),
  ('categories.manage', 'categories', 'manage', 'Manage categories', 'Categories CRUD', 50),
  ('inventory.view', 'inventory', 'view', 'View inventory', 'Stock levels', 60),
  ('inventory.adjust', 'inventory', 'adjust', 'Adjust stock', 'Manual adjustments', 61),
  ('purchases.view', 'purchases', 'view', 'View purchases', 'Purchase history', 70),
  ('purchases.create', 'purchases', 'create', 'Create purchases', 'Record purchases', 71),
  ('customers.manage', 'customers', 'manage', 'Manage customers', 'Customer directory', 80),
  ('suppliers.manage', 'suppliers', 'manage', 'Manage suppliers', 'Supplier directory', 90),
  ('debts.view', 'debts', 'view', 'View debts', 'Receivables/payables', 100),
  ('debts.manage', 'debts', 'manage', 'Manage debts', 'Record debt payments', 101),
  ('expenses.view', 'expenses', 'view', 'View expenses', 'Expense list', 110),
  ('expenses.manage', 'expenses', 'manage', 'Manage expenses', 'Create/edit expenses', 111),
  ('accounting.view', 'accounting', 'view', 'View accounting', 'Accounting module', 120),
  ('accounting.manage', 'accounting', 'manage', 'Manage accounting', 'Journals, COA, etc.', 121),
  ('reports.view', 'reports', 'view', 'View reports', 'Business reports', 130),
  ('reports.export', 'reports', 'export', 'Export reports', 'PDF/Excel export', 131),
  ('notifications.view', 'notifications', 'view', 'Notifications', 'In-app alerts', 140),
  ('sync.view', 'sync', 'view', 'Sync queue', 'Offline sync status', 150),
  ('settings.view', 'settings', 'view', 'View settings', 'Store settings read', 160),
  ('settings.manage', 'settings', 'manage', 'Manage settings', 'Edit store settings', 161),
  ('users.view', 'users', 'view', 'View users', 'Staff directory', 170),
  ('users.manage', 'users', 'manage', 'Manage users', 'Create/edit staff', 171),
  ('users.permissions', 'users', 'permissions', 'Manage permissions', 'Assign custom permissions', 172)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Role ↔ permission junction (normalized; roles.permissions jsonb kept for compat)
-- ---------------------------------------------------------------------------

create table if not exists role_permissions (
  role_id text not null references roles (id) on delete cascade,
  permission_id text not null references permissions (id) on delete cascade,
  primary key (role_id, permission_id)
);

-- Inventory staff role
insert into roles (id, name, permissions, description) values
  ('inventory_staff', 'Inventory Staff', '["products.*","inventory.*","purchases.*","categories.manage"]'::jsonb, 'Stock and purchasing')
on conflict (id) do update set
  name = excluded.name,
  permissions = excluded.permissions,
  description = excluded.description;

-- Refresh default role permission rows
delete from role_permissions where role_id in (
  'super_admin','store_owner','manager','cashier','accountant','inventory_staff'
);

insert into role_permissions (role_id, permission_id)
select 'super_admin', id from permissions
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'store_owner', id from permissions
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'manager', p.id from permissions p
where p.id in (
  'dashboard.view','pos.checkout','pos.hold_sale','pos.override_price',
  'sales.view','sales.create','products.view','products.create','products.edit',
  'categories.manage','inventory.view','inventory.adjust',
  'purchases.view','purchases.create','customers.manage','suppliers.manage',
  'debts.view','debts.manage','expenses.view','reports.view','notifications.view',
  'sync.view','settings.view','users.view'
)
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'cashier', p.id from permissions p
where p.id in (
  'dashboard.view','pos.checkout','pos.hold_sale',
  'sales.view','sales.create','products.view','notifications.view'
)
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'accountant', p.id from permissions p
where p.id in (
  'dashboard.view','debts.view','debts.manage','expenses.view','expenses.manage',
  'accounting.view','accounting.manage','reports.view','reports.export','notifications.view'
)
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'inventory_staff', p.id from permissions p
where p.id in (
  'dashboard.view','products.view','products.create','products.edit','products.delete',
  'categories.manage','inventory.view','inventory.adjust',
  'purchases.view','purchases.create','notifications.view','sync.view'
)
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Per-user permission overrides (grant=true adds, grant=false revokes)
-- ---------------------------------------------------------------------------

create table if not exists user_permissions (
  user_id uuid not null references profiles (id) on delete cascade,
  permission_id text not null references permissions (id) on delete cascade,
  granted boolean not null default true,
  primary key (user_id, permission_id)
);

-- ---------------------------------------------------------------------------
-- Activity logs (server-side audit trail)
-- ---------------------------------------------------------------------------

create table if not exists user_activity_logs (
  id text primary key default gen_random_uuid()::text,
  tenant_id text not null references tenants (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  user_id uuid not null references profiles (id) on delete cascade,
  action text not null,
  entity text,
  entity_id text,
  old_value jsonb,
  new_value jsonb,
  ip_address text,
  device_info text,
  created_at timestamptz not null default now()
);

create index if not exists idx_user_activity_store on user_activity_logs (store_id, created_at desc);
create index if not exists idx_user_activity_user on user_activity_logs (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Extend profiles
-- ---------------------------------------------------------------------------

alter table profiles
  add column if not exists avatar_url text,
  add column if not exists last_login_at timestamptz,
  add column if not exists status text not null default 'active';

-- ---------------------------------------------------------------------------
-- Permission helpers
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_permission_matches(
  p_grant text,
  p_required text
)
returns boolean
language sql
immutable
as $$
  select
    p_grant = '*'
    or p_grant = 'store.*'
    or p_grant = p_required
    or (
      position('.*' in p_grant) > 0
      and p_required like replace(p_grant, '.*', '.%')
    );
$$;

create or replace function public.inventrax_effective_permissions(p_user_id uuid default auth.uid())
returns text[]
language sql
stable
security definer
set search_path = public
as $$
  with role_grants as (
    select rp.permission_id as perm
    from profiles pr
    join role_permissions rp on rp.role_id = pr.role_id
    where pr.id = p_user_id and pr.is_active
    union
    select jsonb_array_elements_text(r.permissions)
    from profiles pr
    join roles r on r.id = pr.role_id
    where pr.id = p_user_id and pr.is_active
  ),
  user_grants as (
    select permission_id as perm, granted
    from user_permissions
    where user_id = p_user_id
  ),
  merged as (
    select perm from role_grants
    union
    select perm from user_grants where granted = true
  ),
  revoked as (
    select permission_id as perm from user_permissions
    where user_id = p_user_id and granted = false
  )
  select coalesce(array_agg(distinct m.perm), '{}'::text[])
  from merged m
  where not exists (select 1 from revoked r where r.perm = m.perm);
$$;

create or replace function public.inventrax_has_permission(p_perm text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from unnest(public.inventrax_effective_permissions()) g
    where public.inventrax_permission_matches(g, p_perm)
  );
$$;

create or replace function public.inventrax_can_manage_users()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.inventrax_role_id() in ('super_admin', 'store_owner')
    or public.inventrax_has_permission('users.manage');
$$;

-- ---------------------------------------------------------------------------
-- RPC: log activity
-- ---------------------------------------------------------------------------

create or replace function public.log_user_activity(
  p_action text,
  p_entity text default null,
  p_entity_id text default null,
  p_old_value jsonb default null,
  p_new_value jsonb default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then return; end if;

  insert into user_activity_logs (
    tenant_id, store_id, user_id, action, entity, entity_id, old_value, new_value
  )
  select pr.tenant_id, pr.store_id, v_uid, p_action, p_entity, p_entity_id, p_old_value, p_new_value
  from profiles pr
  where pr.id = v_uid;
end;
$$;

grant execute on function public.log_user_activity to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: update profile permissions (store owner)
-- ---------------------------------------------------------------------------

create or replace function public.set_user_permissions(
  p_user_id uuid,
  p_permissions jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.inventrax_can_manage_users() then
    raise exception 'Not authorized to manage permissions';
  end if;

  if not exists (
    select 1 from profiles
    where id = p_user_id
      and store_id = public.inventrax_store_id()
      and tenant_id = public.inventrax_tenant_id()
  ) then
    raise exception 'User not in your store';
  end if;

  delete from user_permissions where user_id = p_user_id;

  insert into user_permissions (user_id, permission_id, granted)
  select p_user_id, key, (value::text)::boolean
  from jsonb_each(p_permissions);

  perform public.log_user_activity(
    'permissions.updated',
    'user',
    p_user_id::text,
    null,
    p_permissions
  );
end;
$$;

grant execute on function public.set_user_permissions to authenticated;

-- ---------------------------------------------------------------------------
-- RPC: create store user (profile row; auth user via edge function or pre-created id)
-- ---------------------------------------------------------------------------

create or replace function public.upsert_store_user_profile(
  p_user_id uuid,
  p_email text,
  p_full_name text,
  p_phone text default null,
  p_role_id text default 'cashier',
  p_avatar_url text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text := public.inventrax_store_id();
begin
  if not public.inventrax_can_manage_users() then
    raise exception 'Not authorized';
  end if;

  if p_role_id = 'super_admin' then
    raise exception 'Cannot assign super_admin';
  end if;

  insert into profiles (
    id, tenant_id, store_id, role_id, full_name, email, phone, avatar_url, is_active, status
  ) values (
    p_user_id, v_tenant, v_store, p_role_id,
    trim(p_full_name), lower(trim(p_email)),
    p_phone, p_avatar_url, true, 'active'
  )
  on conflict (id) do update set
    role_id = excluded.role_id,
    full_name = excluded.full_name,
    phone = excluded.phone,
    avatar_url = coalesce(excluded.avatar_url, profiles.avatar_url),
    is_active = true,
    status = 'active';

  perform public.log_user_activity(
    'user.created',
    'user',
    p_user_id::text,
    null,
    jsonb_build_object('email', p_email, 'role_id', p_role_id)
  );

  return jsonb_build_object('user_id', p_user_id, 'email', lower(trim(p_email)));
end;
$$;

grant execute on function public.upsert_store_user_profile to authenticated;

create or replace function public.update_store_user(
  p_user_id uuid,
  p_full_name text default null,
  p_phone text default null,
  p_role_id text default null,
  p_is_active boolean default null,
  p_status text default null,
  p_avatar_url text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.inventrax_can_manage_users() then
    raise exception 'Not authorized';
  end if;

  update profiles set
    full_name = coalesce(nullif(trim(p_full_name), ''), full_name),
    phone = coalesce(p_phone, phone),
    role_id = coalesce(p_role_id, role_id),
    is_active = coalesce(p_is_active, is_active),
    status = coalesce(p_status, status),
    avatar_url = coalesce(p_avatar_url, avatar_url)
  where id = p_user_id
    and store_id = public.inventrax_store_id()
    and tenant_id = public.inventrax_tenant_id();

  perform public.log_user_activity('user.updated', 'user', p_user_id::text);
end;
$$;

grant execute on function public.update_store_user to authenticated;

create or replace function public.record_login()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update profiles set last_login_at = now() where id = auth.uid();
  perform public.log_user_activity('auth.login', 'session', auth.uid()::text);
end;
$$;

grant execute on function public.record_login to authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table permissions enable row level security;
alter table role_permissions enable row level security;
alter table user_permissions enable row level security;
alter table user_activity_logs enable row level security;

drop policy if exists inventrax_permissions_read on permissions;
create policy inventrax_permissions_read on permissions
  for select to authenticated using (true);

drop policy if exists inventrax_role_permissions_read on role_permissions;
create policy inventrax_role_permissions_read on role_permissions
  for select to authenticated using (true);

drop policy if exists inventrax_user_permissions_select on user_permissions;
create policy inventrax_user_permissions_select on user_permissions
  for select to authenticated
  using (
    user_id = auth.uid()
    or (
      exists (
        select 1 from profiles p
        where p.id = user_permissions.user_id
          and p.store_id = public.inventrax_store_id()
          and p.tenant_id = public.inventrax_tenant_id()
      )
      and public.inventrax_can_manage_users()
    )
    or public.inventrax_role_id() = 'super_admin'
  );

drop policy if exists inventrax_user_permissions_write on user_permissions;
create policy inventrax_user_permissions_write on user_permissions
  for all to authenticated
  using (public.inventrax_can_manage_users())
  with check (public.inventrax_can_manage_users());

drop policy if exists inventrax_profiles_update_manager on profiles;
create policy inventrax_profiles_update_manager on profiles
  for update to authenticated
  using (
    id = auth.uid()
    or (
      store_id = public.inventrax_store_id()
      and tenant_id = public.inventrax_tenant_id()
      and public.inventrax_can_manage_users()
    )
    or public.inventrax_role_id() = 'super_admin'
  )
  with check (
    id = auth.uid()
    or (
      store_id = public.inventrax_store_id()
      and tenant_id = public.inventrax_tenant_id()
      and public.inventrax_can_manage_users()
      and role_id <> 'super_admin'
    )
    or public.inventrax_role_id() = 'super_admin'
  );

drop policy if exists inventrax_activity_logs_select on user_activity_logs;
create policy inventrax_activity_logs_select on user_activity_logs
  for select to authenticated
  using (
    store_id = public.inventrax_store_id()
    and tenant_id = public.inventrax_tenant_id()
    and (
      user_id = auth.uid()
      or public.inventrax_has_permission('users.view')
      or public.inventrax_role_id() = 'super_admin'
    )
  );

drop policy if exists inventrax_activity_logs_insert on user_activity_logs;
create policy inventrax_activity_logs_insert on user_activity_logs
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and store_id = public.inventrax_store_id()
  );
