-- InventraX: debt share link compatibility
--
-- Problem: older migration created debt_share_links with UUID tenant/store ids,
-- but the ERP data model uses TEXT ids. We preserve existing tokens/URLs by:
-- 1) Leaving the legacy table intact (uuid columns)
-- 2) Creating a new text-based table debt_share_links_v2
-- 3) Providing a single resolver RPC that checks both tables by token

create table if not exists public.debt_share_links_v2 (
  id text primary key,
  tenant_id text not null,
  store_id text not null,
  token text not null unique,
  customer_id text not null,
  debt_id text,
  created_at timestamptz not null default now(),
  expires_at timestamptz
);

create index if not exists idx_debt_share_links_v2_store
  on public.debt_share_links_v2 (tenant_id, store_id, created_at desc);

alter table public.debt_share_links_v2 enable row level security;

drop policy if exists inventrax_debt_share_links_v2_all on public.debt_share_links_v2;
create policy inventrax_debt_share_links_v2_all on public.debt_share_links_v2
  for all to authenticated
  using (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  )
  with check (
    tenant_id = public.inventrax_tenant_id()
    and store_id = public.inventrax_store_id()
  );

-- Public resolver by token. Uses SECURITY DEFINER so it can read both tables
-- without exposing the entire table publicly.
create or replace function public.resolve_debt_share_link(p_token text)
returns table (
  token text,
  tenant_id text,
  store_id text,
  customer_id text,
  debt_id text,
  created_at timestamptz,
  expires_at timestamptz,
  source text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  -- Prefer v2 (text) links.
  return query
    select
      l.token,
      l.tenant_id,
      l.store_id,
      l.customer_id,
      l.debt_id,
      l.created_at,
      l.expires_at,
      'v2'::text as source
    from public.debt_share_links_v2 l
    where l.token = p_token
      and (l.expires_at is null or l.expires_at > now())
    limit 1;

  if found then
    return;
  end if;

  -- Fallback to legacy (uuid) links, casting to text for API consumers.
  return query
    select
      l.token,
      l.tenant_id::text as tenant_id,
      l.store_id::text as store_id,
      l.customer_id::text as customer_id,
      l.debt_id::text as debt_id,
      l.created_at,
      l.expires_at,
      'legacy'::text as source
    from public.debt_share_links l
    where l.token = p_token
      and (l.expires_at is null or l.expires_at > now())
    limit 1;
end;
$$;

revoke all on function public.resolve_debt_share_link(text) from public;
grant execute on function public.resolve_debt_share_link(text) to anon, authenticated;

