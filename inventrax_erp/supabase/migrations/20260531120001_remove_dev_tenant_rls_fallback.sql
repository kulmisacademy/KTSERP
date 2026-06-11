-- Remove dev-tenant/dev-store RLS fallbacks — unauthenticated or unscoped users see no rows.

create or replace function public.inventrax_tenant_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select tenant_id from admin_impersonation_sessions where user_id = auth.uid()),
    (select tenant_id from profiles where id = auth.uid() and is_active),
    nullif(auth.jwt() -> 'user_metadata' ->> 'tenant_id', ''),
    nullif(auth.jwt() -> 'app_metadata' ->> 'tenant_id', '')
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
    (select store_id from admin_impersonation_sessions where user_id = auth.uid()),
    (select store_id from profiles where id = auth.uid() and is_active),
    nullif(auth.jwt() -> 'user_metadata' ->> 'store_id', ''),
    nullif(auth.jwt() -> 'app_metadata' ->> 'store_id', '')
  );
$$;
