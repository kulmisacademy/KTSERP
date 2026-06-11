-- Debt management extensions (mirror local Drift v13)

alter table if exists public.purchases
  add column if not exists payment_status text not null default 'paid';

alter table if exists public.sales
  add column if not exists paid_cents integer not null default 0,
  add column if not exists payment_status text not null default 'paid';

alter table if exists public.debts
  add column if not exists sale_id uuid,
  add column if not exists purchase_id uuid,
  add column if not exists invoice_number text;

alter table if exists public.debt_payments
  add column if not exists payment_account_id uuid;

create table if not exists public.debt_share_links (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid not null,
  token text not null unique,
  customer_id uuid not null,
  debt_id uuid,
  created_at timestamptz not null default now(),
  expires_at timestamptz
);

alter table public.debt_share_links enable row level security;
