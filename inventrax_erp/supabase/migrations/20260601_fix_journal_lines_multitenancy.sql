-- journal_lines: add tenant/store scoping + updated_at for sync/RLS

alter table journal_lines
  add column if not exists tenant_id text,
  add column if not exists store_id text,
  add column if not exists updated_at timestamptz;

-- Backfill from parent journal_entries
update journal_lines jl
set
  tenant_id = je.tenant_id,
  store_id = je.store_id,
  updated_at = coalesce(jl.updated_at, je.created_at, now())
from journal_entries je
where je.id = jl.journal_entry_id
  and (jl.tenant_id is null or jl.store_id is null);

-- Remove orphan lines that cannot be scoped
delete from journal_lines
where tenant_id is null or store_id is null;

alter table journal_lines
  alter column tenant_id set not null,
  alter column store_id set not null,
  alter column updated_at set not null,
  alter column updated_at set default now();

-- Composite indexes for tenant/store sync and lookups
drop index if exists idx_journal_lines_entry;
create index if not exists idx_journal_lines_tenant_store
  on journal_lines (tenant_id, store_id);
create index if not exists idx_journal_lines_journal_entry
  on journal_lines (tenant_id, store_id, journal_entry_id);
create index if not exists idx_journal_lines_account
  on journal_lines (tenant_id, store_id, account_id);

-- Direct tenant/store RLS (replaces parent-join policy)
drop policy if exists inventrax_journal_lines_all on journal_lines;
create policy inventrax_journal_lines_all on journal_lines
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

drop trigger if exists trg_journal_lines_updated_at on journal_lines;
create trigger trg_journal_lines_updated_at
  before update on journal_lines
  for each row execute function public.inventrax_set_updated_at();
