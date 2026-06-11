-- InventraX accounting (double-entry) — cloud mirror of local Drift schema

create table if not exists chart_of_accounts (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  code text not null,
  name text not null,
  type text not null check (type in ('asset','liability','equity','revenue','expense')),
  parent_id text references chart_of_accounts(id),
  opening_balance_cents integer not null default 0,
  is_system boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (store_id, code)
);

create table if not exists payment_accounts (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  name text not null,
  account_type text not null,
  chart_account_id text not null references chart_of_accounts(id),
  is_default boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists journal_entries (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  entry_date timestamptz not null,
  description text not null,
  source_module text not null,
  source_id text,
  status text not null default 'posted',
  created_by text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists journal_lines (
  id text primary key,
  journal_entry_id text not null references journal_entries(id) on delete cascade,
  account_id text not null references chart_of_accounts(id),
  debit_cents integer not null default 0,
  credit_cents integer not null default 0,
  line_description text
);

create index if not exists idx_journal_entries_store_date
  on journal_entries (store_id, entry_date desc);

alter table chart_of_accounts enable row level security;
alter table payment_accounts enable row level security;
alter table journal_entries enable row level security;
alter table journal_lines enable row level security;
