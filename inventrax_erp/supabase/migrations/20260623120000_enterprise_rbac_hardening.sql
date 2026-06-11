-- Enterprise RBAC hardening: strict role templates, new roles, product mutation guards.

-- ---------------------------------------------------------------------------
-- New roles
-- ---------------------------------------------------------------------------
insert into roles (id, name, permissions, description) values
  ('admin', 'Admin', '[]'::jsonb, 'Operations — no billing or user management'),
  ('sales', 'Sales', '[]'::jsonb, 'POS, sales, customers — no catalog management'),
  ('reports', 'Reports', '[]'::jsonb, 'Read-only dashboards and analytics')
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description;

-- Subscription / billing page permission (if missing)
insert into permissions (id, module, page_id, module_id, action, label, sort_order) values
  ('subscription.plan.view', 'subscription', 'plan', 'subscription', 'view', 'View billing', 181),
  ('subscription.plan.manage', 'subscription', 'plan', 'subscription', 'manage', 'Manage subscription', 182)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Strict role_permissions (replaces broad LIKE patterns)
-- ---------------------------------------------------------------------------
delete from role_permissions where role_id in (
  'super_admin', 'store_owner', 'admin', 'manager', 'cashier',
  'sales', 'accountant', 'inventory_staff', 'reports'
);

insert into role_permissions (role_id, permission_id)
select 'super_admin', id from permissions on conflict do nothing;

insert into role_permissions (role_id, permission_id)
select 'store_owner', id from permissions on conflict do nothing;

-- Admin: operations without billing, users, or settings manage
insert into role_permissions (role_id, permission_id)
select 'admin', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.edit',
  'pos.terminal.print', 'pos.terminal.refund', 'pos.terminal.manage',
  'custom_sales.builder.view', 'custom_sales.builder.create',
  'custom_sales.builder.edit', 'custom_sales.builder.print',
  'custom_sales.drafts.view', 'custom_sales.drafts.create', 'custom_sales.drafts.edit',
  'sales.history.view', 'sales.history.create', 'sales.history.edit',
  'sales.history.refund', 'sales.history.export', 'sales.history.print',
  'products.catalog.view', 'products.catalog.create', 'products.catalog.edit',
  'products.catalog.delete', 'products.catalog.import', 'products.catalog.export',
  'products.categories.view', 'products.categories.create', 'products.categories.edit',
  'products.brands.view', 'products.brands.create', 'products.brands.edit',
  'inventory.stock.view', 'inventory.stock.edit', 'inventory.stock.manage',
  'purchases.history.view', 'purchases.history.edit', 'purchases.history.export',
  'purchases.create.view', 'purchases.create.create',
  'customers.directory.view', 'customers.directory.create',
  'customers.directory.edit', 'customers.directory.delete',
  'suppliers.directory.view', 'suppliers.directory.create',
  'suppliers.directory.edit', 'suppliers.directory.delete',
  'debts.ledger.view', 'debts.ledger.receive', 'debts.ledger.export',
  'expenses.list.view',
  'reports.main.view', 'reports.main.export',
  'notifications.inbox.view',
  'sync.queue.view',
  'settings.store.view'
) on conflict do nothing;

-- Manager: admin + staff visibility + expenses manage
insert into role_permissions (role_id, permission_id)
select 'manager', p.id from permissions p
where p.id in (
  select rp.permission_id from role_permissions rp where rp.role_id = 'admin'
  union select unnest(array[
    'debts.ledger.create', 'debts.ledger.edit',
    'expenses.list.create', 'expenses.list.edit', 'expenses.list.export',
    'users.directory.view',
    'audit.logs.view'
  ]::text[])
) on conflict do nothing;

-- Cashier: POS only — NO products catalog access
insert into role_permissions (role_id, permission_id)
select 'cashier', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.print', 'pos.terminal.manage',
  'custom_sales.builder.view', 'custom_sales.builder.create', 'custom_sales.builder.print',
  'custom_sales.drafts.view', 'custom_sales.drafts.create', 'custom_sales.drafts.edit',
  'sales.history.view', 'sales.history.create', 'sales.history.print',
  'customers.directory.view', 'customers.directory.create', 'customers.directory.edit',
  'notifications.inbox.view'
) on conflict do nothing;

-- Sales: POS + invoices + customers — no product management
insert into role_permissions (role_id, permission_id)
select 'sales', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'pos.terminal.view', 'pos.terminal.create', 'pos.terminal.print', 'pos.terminal.manage',
  'custom_sales.builder.view', 'custom_sales.builder.create',
  'custom_sales.builder.edit', 'custom_sales.builder.print',
  'custom_sales.drafts.view', 'custom_sales.drafts.create', 'custom_sales.drafts.edit',
  'sales.history.view', 'sales.history.create', 'sales.history.edit',
  'sales.history.print', 'sales.history.export',
  'customers.directory.view', 'customers.directory.create', 'customers.directory.edit',
  'notifications.inbox.view'
) on conflict do nothing;

-- Accountant: finance modules only
insert into role_permissions (role_id, permission_id)
select 'accountant', p.id from permissions p
where p.id like 'dashboard.%'
   or p.id like 'debts.%'
   or p.id like 'expenses.%'
   or p.id like 'accounting.%'
   or p.id like 'reports.%'
   or p.id like 'notifications.%'
   or p.id like 'audit.%'
on conflict do nothing;

-- Inventory: stock & purchasing only
insert into role_permissions (role_id, permission_id)
select 'inventory_staff', p.id from permissions p
where p.id like 'dashboard.%'
   or p.id like 'products.%'
   or p.id like 'inventory.%'
   or p.id like 'purchases.%'
   or p.id like 'notifications.%'
   or p.id like 'sync.%'
on conflict do nothing;

-- Reports: read-only analytics
insert into role_permissions (role_id, permission_id)
select 'reports', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'reports.main.view', 'reports.main.export',
  'reports.ai.view',
  'notifications.inbox.view'
) on conflict do nothing;

-- Owner / super_admin retain subscription + billing
insert into role_permissions (role_id, permission_id)
select 'store_owner', p.id from permissions p
where p.id in ('subscription.plan.view', 'subscription.plan.manage')
  and not exists (
    select 1 from role_permissions rp
    where rp.role_id = 'store_owner' and rp.permission_id = p.id
  )
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Products: tenant isolation + permission checks on mutations
-- ---------------------------------------------------------------------------
drop policy if exists inventrax_products_all on products;

create policy inventrax_products_select on products
  for select to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

create policy inventrax_products_insert on products
  for insert to authenticated
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
    and public.inventrax_has_permission('products.catalog.create')
  );

create policy inventrax_products_update on products
  for update to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
    and public.inventrax_has_permission('products.catalog.edit')
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

create policy inventrax_products_delete on products
  for delete to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
    and public.inventrax_has_permission('products.catalog.delete')
  );
