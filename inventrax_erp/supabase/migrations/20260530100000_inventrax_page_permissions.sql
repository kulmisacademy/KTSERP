-- Page-level RBAC: modules, pages, expanded permissions (synced with Flutter PermissionRegistry)

create table if not exists modules (
  id text primary key,
  name text not null,
  sort_order integer not null default 0,
  icon_key text
);

create table if not exists pages (
  module_id text not null references modules (id) on delete cascade,
  id text not null,
  label text not null,
  route text,
  sidebar_label text,
  sort_order integer not null default 0,
  primary key (module_id, id)
);

alter table permissions
  add column if not exists page_id text,
  add column if not exists module_id text;

-- Old schema: unique (module, action) — only one permission per module+action.
-- Granular ids need multiple rows per module (e.g. accounting.*.view).
alter table permissions drop constraint if exists permissions_module_action_key;

create unique index if not exists permissions_module_page_action_uidx
  on permissions (module_id, page_id, action)
  where page_id is not null and module_id is not null;

-- Modules
insert into modules (id, name, sort_order) values
  ('dashboard', 'Dashboard', 10),
  ('pos', 'POS', 20),
  ('sales', 'Sales', 30),
  ('products', 'Products', 40),
  ('inventory', 'Inventory', 50),
  ('purchases', 'Purchases', 60),
  ('customers', 'Customers', 70),
  ('suppliers', 'Suppliers', 80),
  ('debts', 'Debts', 90),
  ('expenses', 'Expenses', 100),
  ('accounting', 'Accounting', 110),
  ('reports', 'Reports', 120),
  ('notifications', 'Notifications', 130),
  ('sync', 'Sync', 140),
  ('users', 'Users', 150),
  ('settings', 'Settings', 160),
  ('audit', 'Audit logs', 170),
  ('subscription', 'Subscription', 180)
on conflict (id) do update set name = excluded.name, sort_order = excluded.sort_order;

-- Pages (subset; app registry is source of truth for full list)
insert into pages (module_id, id, label, route, sidebar_label, sort_order) values
  ('dashboard', 'main', 'Dashboard', '/dashboard', 'Dashboard', 1),
  ('pos', 'terminal', 'POS Terminal', '/pos', 'POS', 1),
  ('sales', 'history', 'Sales history', '/sales', 'Sales', 1),
  ('products', 'catalog', 'Product list', '/products', 'Products', 1),
  ('products', 'categories', 'Categories', '/categories', 'Categories', 2),
  ('inventory', 'stock', 'Inventory', '/inventory', 'Inventory', 1),
  ('purchases', 'history', 'Purchases', '/purchases', 'Purchases', 1),
  ('purchases', 'create', 'Add purchase', '/purchases/add', 'Add Purchase', 2),
  ('customers', 'directory', 'Customers', '/customers', 'Customers', 1),
  ('suppliers', 'directory', 'Suppliers', '/suppliers', 'Suppliers', 1),
  ('debts', 'ledger', 'Debts', '/debts', 'Debts', 1),
  ('expenses', 'list', 'Expenses', '/expenses', 'Expenses', 1),
  ('accounting', 'dashboard', 'Accounting', '/accounting', 'Accounting', 1),
  ('reports', 'main', 'Reports', '/reports', 'Reports', 1),
  ('notifications', 'inbox', 'Notifications', '/notifications', 'Notifications', 1),
  ('sync', 'queue', 'Sync queue', '/sync', 'Sync', 1),
  ('users', 'directory', 'User management', '/users', 'User Management', 1),
  ('settings', 'store', 'Settings', '/settings', 'Settings', 1)
on conflict (module_id, id) do nothing;

-- Granular permissions (module.page.action) — ON CONFLICT keeps existing rows
insert into permissions (id, module, page_id, module_id, action, label, sort_order) values
  ('dashboard.main.view', 'dashboard', 'main', 'dashboard', 'view', 'View Dashboard', 10),
  ('pos.terminal.view', 'pos', 'terminal', 'pos', 'view', 'View POS', 20),
  ('pos.terminal.create', 'pos', 'terminal', 'pos', 'create', 'Create Sale', 21),
  ('pos.terminal.edit', 'pos', 'terminal', 'pos', 'edit', 'Edit Sale', 22),
  ('pos.terminal.delete', 'pos', 'terminal', 'pos', 'delete', 'Delete Sale', 23),
  ('pos.terminal.refund', 'pos', 'terminal', 'pos', 'refund', 'Refund Sale', 24),
  ('pos.terminal.print', 'pos', 'terminal', 'pos', 'print', 'Print Receipt', 25),
  ('pos.terminal.manage', 'pos', 'terminal', 'pos', 'manage', 'POS Advanced', 26),
  ('sales.history.view', 'sales', 'history', 'sales', 'view', 'View Sales', 30),
  ('sales.history.create', 'sales', 'history', 'sales', 'create', 'Create Sale', 31),
  ('sales.history.edit', 'sales', 'history', 'sales', 'edit', 'Edit Sale', 32),
  ('sales.history.delete', 'sales', 'history', 'sales', 'delete', 'Delete Sale', 33),
  ('sales.history.refund', 'sales', 'history', 'sales', 'refund', 'Refund Sale', 34),
  ('sales.history.export', 'sales', 'history', 'sales', 'export', 'Export Sales', 35),
  ('sales.history.print', 'sales', 'history', 'sales', 'print', 'Print Receipt', 36),
  ('products.catalog.view', 'products', 'catalog', 'products', 'view', 'View Products', 40),
  ('products.catalog.create', 'products', 'catalog', 'products', 'create', 'Add Product', 41),
  ('products.catalog.edit', 'products', 'catalog', 'products', 'edit', 'Edit Product', 42),
  ('products.catalog.delete', 'products', 'catalog', 'products', 'delete', 'Delete Product', 43),
  ('products.catalog.import', 'products', 'catalog', 'products', 'import', 'Import Products', 44),
  ('products.catalog.export', 'products', 'catalog', 'products', 'export', 'Export Products', 45),
  ('products.categories.view', 'products', 'categories', 'products', 'view', 'View Categories', 50),
  ('products.categories.create', 'products', 'categories', 'products', 'create', 'Create Category', 51),
  ('products.categories.edit', 'products', 'categories', 'products', 'edit', 'Edit Category', 52),
  ('products.categories.delete', 'products', 'categories', 'products', 'delete', 'Delete Category', 53),
  ('products.categories.manage', 'products', 'categories', 'products', 'manage', 'Manage Categories', 54),
  ('inventory.stock.view', 'inventory', 'stock', 'inventory', 'view', 'View Inventory', 60),
  ('inventory.stock.edit', 'inventory', 'stock', 'inventory', 'edit', 'Adjust Stock', 61),
  ('inventory.stock.manage', 'inventory', 'stock', 'inventory', 'manage', 'Inventory Manage', 62),
  ('purchases.history.view', 'purchases', 'history', 'purchases', 'view', 'View Purchases', 70),
  ('purchases.history.create', 'purchases', 'history', 'purchases', 'create', 'Create Purchase', 71),
  ('purchases.history.edit', 'purchases', 'history', 'purchases', 'edit', 'Edit Purchase', 72),
  ('purchases.history.delete', 'purchases', 'history', 'purchases', 'delete', 'Delete Purchase', 73),
  ('purchases.create.view', 'purchases', 'create', 'purchases', 'view', 'Add Purchase Page', 74),
  ('purchases.create.create', 'purchases', 'create', 'purchases', 'create', 'Record Purchase', 75),
  ('customers.directory.view', 'customers', 'directory', 'customers', 'view', 'View Customers', 80),
  ('customers.directory.create', 'customers', 'directory', 'customers', 'create', 'Add Customer', 81),
  ('customers.directory.edit', 'customers', 'directory', 'customers', 'edit', 'Edit Customer', 82),
  ('customers.directory.delete', 'customers', 'directory', 'customers', 'delete', 'Delete Customer', 83),
  ('customers.directory.manage', 'customers', 'directory', 'customers', 'manage', 'Manage Customers', 84),
  ('suppliers.directory.view', 'suppliers', 'directory', 'suppliers', 'view', 'View Suppliers', 90),
  ('suppliers.directory.manage', 'suppliers', 'directory', 'suppliers', 'manage', 'Manage Suppliers', 91),
  ('debts.ledger.view', 'debts', 'ledger', 'debts', 'view', 'View Debts', 100),
  ('debts.ledger.create', 'debts', 'ledger', 'debts', 'create', 'Create Debt', 101),
  ('debts.ledger.edit', 'debts', 'ledger', 'debts', 'edit', 'Edit Debt', 102),
  ('debts.ledger.receive', 'debts', 'ledger', 'debts', 'receive', 'Receive Payment', 103),
  ('expenses.list.view', 'expenses', 'list', 'expenses', 'view', 'View Expenses', 110),
  ('expenses.list.create', 'expenses', 'list', 'expenses', 'create', 'Create Expense', 111),
  ('expenses.list.manage', 'expenses', 'list', 'expenses', 'manage', 'Manage Expenses', 112),
  ('accounting.dashboard.view', 'accounting', 'dashboard', 'accounting', 'view', 'View Accounting', 120),
  ('accounting.chart.view', 'accounting', 'chart', 'accounting', 'view', 'Chart of Accounts', 121),
  ('accounting.journals.view', 'accounting', 'journals', 'accounting', 'view', 'Journal Entries', 122),
  ('accounting.journals.create', 'accounting', 'journals', 'accounting', 'create', 'Create Journal', 123),
  ('accounting.ledger.view', 'accounting', 'ledger', 'accounting', 'view', 'General Ledger', 124),
  ('accounting.trial_balance.view', 'accounting', 'trial_balance', 'accounting', 'view', 'Trial Balance', 125),
  ('accounting.balance_sheet.view', 'accounting', 'balance_sheet', 'accounting', 'view', 'Balance Sheet', 126),
  ('reports.main.view', 'reports', 'main', 'reports', 'view', 'View Reports', 130),
  ('reports.main.export', 'reports', 'main', 'reports', 'export', 'Export Reports', 131),
  ('notifications.inbox.view', 'notifications', 'inbox', 'notifications', 'view', 'Notifications', 140),
  ('sync.queue.view', 'sync', 'queue', 'sync', 'view', 'Sync Queue', 150),
  ('users.directory.view', 'users', 'directory', 'users', 'view', 'View Users', 160),
  ('users.directory.create', 'users', 'directory', 'users', 'create', 'Create Users', 161),
  ('users.permissions.manage', 'users', 'permissions', 'users', 'manage', 'Edit Permissions', 162),
  ('settings.store.view', 'settings', 'store', 'settings', 'view', 'View Settings', 170),
  ('settings.store.manage', 'settings', 'store', 'settings', 'manage', 'Manage Settings', 171)
on conflict (id) do update set
  label = excluded.label,
  page_id = excluded.page_id,
  module_id = excluded.module_id,
  module = excluded.module,
  action = excluded.action;

-- Legacy flat permission ids (superseded by granular ids).
-- Do not UPDATE role_permissions in place — several old ids map to one new id
-- (e.g. pos.hold_sale + pos.override_price → pos.terminal.manage) and violate PK.

-- Preserve user overrides: copy to new ids, then drop legacy rows.
insert into user_permissions (user_id, permission_id, granted)
select distinct on (up.user_id, v.new_id) up.user_id, v.new_id, up.granted
from user_permissions up
join (values
  ('dashboard.view', 'dashboard.main.view'),
  ('pos.checkout', 'pos.terminal.view'),
  ('pos.hold_sale', 'pos.terminal.manage'),
  ('pos.override_price', 'pos.terminal.manage'),
  ('sales.view', 'sales.history.view'),
  ('sales.create', 'sales.history.create'),
  ('sales.delete', 'sales.history.delete'),
  ('sales.refund', 'sales.history.refund'),
  ('products.view', 'products.catalog.view'),
  ('products.create', 'products.catalog.create'),
  ('products.edit', 'products.catalog.edit'),
  ('products.delete', 'products.catalog.delete'),
  ('categories.manage', 'products.categories.manage'),
  ('inventory.view', 'inventory.stock.view'),
  ('inventory.adjust', 'inventory.stock.manage'),
  ('purchases.view', 'purchases.history.view'),
  ('purchases.create', 'purchases.create.create'),
  ('customers.manage', 'customers.directory.manage'),
  ('suppliers.manage', 'suppliers.directory.manage'),
  ('debts.view', 'debts.ledger.view'),
  ('debts.manage', 'debts.ledger.receive'),
  ('expenses.view', 'expenses.list.view'),
  ('expenses.manage', 'expenses.list.manage'),
  ('accounting.view', 'accounting.dashboard.view'),
  ('accounting.manage', 'accounting.journals.create'),
  ('reports.view', 'reports.main.view'),
  ('reports.export', 'reports.main.export'),
  ('notifications.view', 'notifications.inbox.view'),
  ('sync.view', 'sync.queue.view'),
  ('settings.view', 'settings.store.view'),
  ('settings.manage', 'settings.store.manage'),
  ('users.view', 'users.directory.view'),
  ('users.manage', 'users.directory.create'),
  ('users.permissions', 'users.permissions.manage')
) as v(old_id, new_id) on up.permission_id = v.old_id
where exists (select 1 from permissions p where p.id = v.new_id)
on conflict (user_id, permission_id) do update set granted = excluded.granted;

delete from user_permissions
where permission_id in (
  'dashboard.view','pos.checkout','pos.hold_sale','pos.override_price',
  'sales.view','sales.create','sales.delete','sales.refund',
  'products.view','products.create','products.edit','products.delete',
  'categories.manage','inventory.view','inventory.adjust',
  'purchases.view','purchases.create','customers.manage','suppliers.manage',
  'debts.view','debts.manage','expenses.view','expenses.manage',
  'accounting.view','accounting.manage','reports.view','reports.export',
  'notifications.view','sync.view','settings.view','settings.manage',
  'users.view','users.manage','users.permissions'
);

-- Drop legacy role grants (re-seeded below); required before deleting permission rows.
delete from role_permissions
where permission_id in (
  'dashboard.view','pos.checkout','pos.hold_sale','pos.override_price',
  'sales.view','sales.create','sales.delete','sales.refund',
  'products.view','products.create','products.edit','products.delete',
  'categories.manage','inventory.view','inventory.adjust',
  'purchases.view','purchases.create','customers.manage','suppliers.manage',
  'debts.view','debts.manage','expenses.view','expenses.manage',
  'accounting.view','accounting.manage','reports.view','reports.export',
  'notifications.view','sync.view','settings.view','settings.manage',
  'users.view','users.manage','users.permissions'
);

delete from permissions
where id in (
  'dashboard.view','pos.checkout','pos.hold_sale','pos.override_price',
  'sales.view','sales.create','sales.delete','sales.refund',
  'products.view','products.create','products.edit','products.delete',
  'categories.manage','inventory.view','inventory.adjust',
  'purchases.view','purchases.create','customers.manage','suppliers.manage',
  'debts.view','debts.manage','expenses.view','expenses.manage',
  'accounting.view','accounting.manage','reports.view','reports.export',
  'notifications.view','sync.view','settings.view','settings.manage',
  'users.view','users.manage','users.permissions'
);

-- Re-seed role_permissions for default roles with granular catalog.
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
select 'manager', id from permissions
where id like 'dashboard.%'
   or id like 'pos.%'
   or id like 'sales.%'
   or id like 'products.%'
   or id like 'inventory.%'
   or id like 'purchases.%'
   or id like 'customers.%'
   or id like 'suppliers.%'
   or id like 'debts.%'
   or id like 'expenses.list.view'
   or id like 'reports.main.view'
   or id like 'notifications.%'
   or id like 'sync.%'
   or id like 'settings.store.view'
   or id like 'users.directory.view'
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'cashier', id from permissions
where id in (
  'dashboard.main.view',
  'pos.terminal.view','pos.terminal.create','pos.terminal.print','pos.terminal.manage',
  'sales.history.view','sales.history.create',
  'products.catalog.view',
  'notifications.inbox.view'
)
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'accountant', id from permissions
where id like 'dashboard.%'
   or id like 'debts.%'
   or id like 'expenses.%'
   or id like 'accounting.%'
   or id like 'reports.%'
   or id like 'notifications.%'
on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'inventory_staff', id from permissions
where id like 'dashboard.%'
   or id like 'products.%'
   or id like 'inventory.%'
   or id like 'purchases.%'
   or id like 'notifications.%'
   or id like 'sync.%'
on conflict do nothing;

-- Legacy permission alias helper (expanded)
create or replace function public.inventrax_resolve_permission(p_perm text)
returns text
language sql
immutable
as $$
  select case p_perm
    when 'dashboard.view' then 'dashboard.main.view'
    when 'pos.checkout' then 'pos.terminal.view'
    when 'pos.hold_sale' then 'pos.terminal.manage'
    when 'pos.override_price' then 'pos.terminal.manage'
    when 'sales.view' then 'sales.history.view'
    when 'sales.create' then 'sales.history.create'
    when 'sales.delete' then 'sales.history.delete'
    when 'sales.refund' then 'sales.history.refund'
    when 'products.view' then 'products.catalog.view'
    when 'products.create' then 'products.catalog.create'
    when 'products.edit' then 'products.catalog.edit'
    when 'products.delete' then 'products.catalog.delete'
    when 'categories.manage' then 'products.categories.manage'
    when 'inventory.view' then 'inventory.stock.view'
    when 'inventory.adjust' then 'inventory.stock.manage'
    when 'purchases.view' then 'purchases.history.view'
    when 'purchases.create' then 'purchases.create.create'
    when 'customers.manage' then 'customers.directory.manage'
    when 'suppliers.manage' then 'suppliers.directory.manage'
    when 'debts.view' then 'debts.ledger.view'
    when 'debts.manage' then 'debts.ledger.receive'
    when 'expenses.view' then 'expenses.list.view'
    when 'expenses.manage' then 'expenses.list.manage'
    when 'accounting.view' then 'accounting.dashboard.view'
    when 'accounting.manage' then 'accounting.journals.create'
    when 'reports.view' then 'reports.main.view'
    when 'reports.export' then 'reports.main.export'
    when 'notifications.view' then 'notifications.inbox.view'
    when 'sync.view' then 'sync.queue.view'
    when 'settings.view' then 'settings.store.view'
    when 'settings.manage' then 'settings.store.manage'
    when 'users.view' then 'users.directory.view'
    when 'users.manage' then 'users.directory.create'
    when 'users.permissions' then 'users.permissions.manage'
    else p_perm
  end;
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
       or public.inventrax_permission_matches(g, public.inventrax_resolve_permission(p_perm))
  );
$$;

alter table modules enable row level security;
alter table pages enable row level security;

drop policy if exists inventrax_modules_read on modules;
create policy inventrax_modules_read on modules for select to authenticated using (true);

drop policy if exists inventrax_pages_read on pages;
create policy inventrax_pages_read on pages for select to authenticated using (true);
