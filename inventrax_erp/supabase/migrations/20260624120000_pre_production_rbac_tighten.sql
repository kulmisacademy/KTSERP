-- Pre-production RBAC: strict accountant / inventory templates (matches Flutter registry).

delete from role_permissions
where role_id in ('accountant', 'inventory_staff');

-- Accountant: reports, invoices, debts, expenses — no products/inventory/settings/AI
insert into role_permissions (role_id, permission_id)
select 'accountant', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'custom_sales.builder.view', 'custom_sales.builder.create',
  'custom_sales.builder.edit', 'custom_sales.builder.print',
  'custom_sales.drafts.view', 'custom_sales.drafts.create', 'custom_sales.drafts.edit',
  'sales.history.view', 'sales.history.print', 'sales.history.export',
  'debts.ledger.view', 'debts.ledger.create', 'debts.ledger.edit',
  'debts.ledger.receive', 'debts.ledger.export',
  'debts.customer_profile.view', 'debts.customer_profile.edit', 'debts.customer_profile.receive',
  'debts.supplier_profile.view', 'debts.supplier_profile.edit', 'debts.supplier_profile.receive',
  'expenses.list.view', 'expenses.list.create', 'expenses.list.edit',
  'expenses.list.delete', 'expenses.list.export',
  'accounting.dashboard.view', 'accounting.chart.view',
  'accounting.journals.view', 'accounting.journals.create',
  'accounting.journal_new.view', 'accounting.journal_new.create',
  'accounting.ledger.view', 'accounting.cash.view', 'accounting.cash.create',
  'accounting.payment_accounts.view', 'accounting.payment_accounts.create',
  'accounting.trial_balance.view', 'accounting.profit_loss.view',
  'accounting.balance_sheet.view', 'accounting.cash_flow.view',
  'reports.main.view', 'reports.main.export',
  'notifications.inbox.view'
) on conflict do nothing;

-- Inventory: stock, suppliers, purchases — no billing/settings/AI
insert into role_permissions (role_id, permission_id)
select 'inventory_staff', p.id from permissions p
where p.id in (
  'dashboard.main.view',
  'products.catalog.view', 'products.catalog.create', 'products.catalog.edit',
  'products.catalog.delete', 'products.catalog.import', 'products.catalog.print',
  'products.categories.view', 'products.categories.create',
  'products.categories.edit', 'products.categories.delete',
  'products.brands.view', 'products.brands.create',
  'products.brands.edit', 'products.brands.delete',
  'products.barcode.view', 'products.barcode.print',
  'inventory.stock.view', 'inventory.stock.edit', 'inventory.stock.manage',
  'suppliers.directory.view', 'suppliers.directory.create',
  'suppliers.directory.edit', 'suppliers.directory.delete',
  'purchases.history.view', 'purchases.history.edit', 'purchases.history.export',
  'purchases.create.view', 'purchases.create.create',
  'purchases.detail.view', 'purchases.detail.edit',
  'notifications.inbox.view',
  'sync.queue.view', 'sync.queue.manage'
) on conflict do nothing;
