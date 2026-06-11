-- Platform phase 2: impersonation RLS, storage refresh, analytics, alerts.

-- ---------------------------------------------------------------------------
-- Super-admin impersonation (scoped RLS via inventrax_*_id helpers)
-- ---------------------------------------------------------------------------

create table if not exists admin_impersonation_sessions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  store_id text not null references stores (id) on delete cascade,
  store_name text,
  started_at timestamptz not null default now()
);

alter table admin_impersonation_sessions enable row level security;

drop policy if exists inventrax_impersonation_self on admin_impersonation_sessions;
create policy inventrax_impersonation_self on admin_impersonation_sessions
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and public.inventrax_is_super_admin());

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
    (select store_id from admin_impersonation_sessions where user_id = auth.uid()),
    (select store_id from profiles where id = auth.uid() and is_active),
    nullif(auth.jwt() -> 'user_metadata' ->> 'store_id', ''),
    nullif(auth.jwt() -> 'app_metadata' ->> 'store_id', ''),
    'dev-store'
  );
$$;

create or replace function public.inventrax_platform_impersonate_store(p_store_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant text;
  v_name text;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  select s.tenant_id, s.name into v_tenant, v_name
  from stores s where s.id = p_store_id;

  if v_tenant is null then
    raise exception 'Store not found';
  end if;

  insert into admin_impersonation_sessions (user_id, tenant_id, store_id, store_name)
  values (auth.uid(), v_tenant, p_store_id, v_name)
  on conflict (user_id) do update set
    tenant_id = excluded.tenant_id,
    store_id = excluded.store_id,
    store_name = excluded.store_name,
    started_at = now();

  insert into admin_activity_logs (id, admin_user_id, admin_email, action, target_type, target_id, metadata)
  values (
    gen_random_uuid()::text,
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    'store.impersonate',
    'store',
    p_store_id,
    jsonb_build_object('tenant_id', v_tenant, 'store_name', v_name)
  );

  return jsonb_build_object(
    'tenant_id', v_tenant,
    'store_id', p_store_id,
    'store_name', v_name
  );
end;
$$;

create or replace function public.inventrax_platform_end_impersonation()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store text;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  select store_id into v_store
  from admin_impersonation_sessions where user_id = auth.uid();

  delete from admin_impersonation_sessions where user_id = auth.uid();

  if v_store is not null then
    insert into admin_activity_logs (id, admin_user_id, admin_email, action, target_type, target_id, metadata)
    values (
      gen_random_uuid()::text,
      auth.uid(),
      (select email from profiles where id = auth.uid()),
      'store.impersonate.end',
      'store',
      v_store,
      '{}'::jsonb
    );
  end if;
end;
$$;

-- ---------------------------------------------------------------------------
-- Storage usage refresh (products + storage.objects)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_refresh_storage_usage(p_store_id text default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  n int := 0;
  v_images int;
  v_bytes bigint;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  for r in
    select s.id as store_id, s.tenant_id
    from stores s
    where p_store_id is null or s.id = p_store_id
  loop
    select count(*)::int into v_images
    from products p
    where p.store_id = r.store_id and p.has_image = true;

    select coalesce(sum(
      case when o.metadata ? 'size' then (o.metadata ->> 'size')::bigint else 0 end
    ), 0) into v_bytes
    from storage.objects o
    where o.bucket_id in ('product-images', 'store-logos')
      and (
        (storage.foldername(o.name))[2] = r.store_id
        or o.name like r.tenant_id || '/' || r.store_id || '/%'
      );

    if v_bytes = 0 and v_images > 0 then
      v_bytes := v_images::bigint * 180000;
    end if;

    insert into storage_usage (
      store_id, tenant_id, total_bytes, image_count, pdf_bytes, attachment_bytes, updated_at
    )
    values (r.store_id, r.tenant_id, v_bytes, v_images, 0, 0, now())
    on conflict (store_id) do update set
      total_bytes = excluded.total_bytes,
      image_count = excluded.image_count,
      updated_at = now();

    n := n + 1;
  end loop;
  return n;
end;
$$;

-- ---------------------------------------------------------------------------
-- Analytics + alerts for platform dashboard
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_platform_analytics()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  perform public.inventrax_refresh_storage_usage(null);

  select jsonb_build_object(
    'store_growth', coalesce((
      select jsonb_agg(row_to_json(g) order by g.month)
      from (
        select to_char(date_trunc('month', s.created_at), 'YYYY-MM') as month,
               count(*)::int as count
        from stores s
        where s.created_at >= now() - interval '12 months'
        group by 1
        order by 1
      ) g
    ), '[]'::jsonb),
    'subscriptions_by_plan', coalesce((
      select jsonb_agg(row_to_json(p))
      from (
        select sp.name as plan_name, sp.id as plan_id,
               count(sub.id)::int as store_count,
               sum(sp.monthly_price_cents)::bigint as mrr_cents
        from subscriptions sub
        join subscription_plans sp on sp.id = sub.plan_id
        where sub.status in ('active', 'trialing')
        group by sp.id, sp.name
        order by store_count desc
      ) p
    ), '[]'::jsonb),
    'top_storage_stores', coalesce((
      select jsonb_agg(row_to_json(t))
      from (
        select s.name as store_name, st.store_id, st.total_bytes, st.image_count
        from storage_usage st
        join stores s on s.id = st.store_id
        order by st.total_bytes desc
        limit 10
      ) t
    ), '[]'::jsonb),
    'alerts', coalesce((
      select jsonb_agg(row_to_json(a))
      from (
        select 'expired_subscription' as type, s.id as store_id, s.name as store_name,
               'Subscription expired or past due' as message,
               sub.status as detail
        from subscriptions sub
        join stores s on s.tenant_id = sub.tenant_id
        where sub.status in ('expired', 'past_due')
        union all
        select 'trial_ending', s.id, s.name,
               'Trial ending within 3 days',
               sub.status
        from subscriptions sub
        join stores s on s.tenant_id = sub.tenant_id
        where sub.status = 'trialing'
          and sub.trial_ends_at is not null
          and sub.trial_ends_at <= now() + interval '3 days'
        union all
        select 'high_storage', s.id, s.name,
               'Storage above 80% of plan limit',
               st.total_bytes::text
        from storage_usage st
        join stores s on s.id = st.store_id
        join subscriptions sub on sub.tenant_id = s.tenant_id
        join subscription_plans sp on sp.id = sub.plan_id
        where sp.storage_limit_bytes is not null
          and sp.storage_limit_bytes > 0
          and st.total_bytes::numeric / sp.storage_limit_bytes::numeric >= 0.8
        limit 30
      ) a
    ), '[]'::jsonb)
  ) into result;

  return result;
end;
$$;

-- Global search (stores + plans)
create or replace function public.inventrax_platform_search(p_query text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  return jsonb_build_object(
    'stores', public.inventrax_platform_list_stores(p_query),
    'plans', coalesce((
      select jsonb_agg(row_to_json(p))
      from (
        select id, name, monthly_price_cents, status_text
        from (
          select sp.id, sp.name, sp.monthly_price_cents,
                 case when sp.is_active then 'active' else 'inactive' end as status_text
          from subscription_plans sp
          where p_query is null
             or sp.name ilike '%' || p_query || '%'
             or sp.id ilike '%' || p_query || '%'
          order by sp.sort_order
          limit 20
        ) x
      ) p
    ), '[]'::jsonb)
  );
end;
$$;

create or replace function public.inventrax_platform_dashboard()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  result jsonb;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  perform public.inventrax_refresh_store_usage(null);
  perform public.inventrax_refresh_storage_usage(null);

  select jsonb_build_object(
    'total_stores', (select count(*)::int from stores),
    'active_stores', (select count(*)::int from stores where status = 'active'),
    'trial_stores', (select count(*)::int from subscriptions where status = 'trialing'),
    'expired_stores', (select count(*)::int from subscriptions where status in ('expired', 'past_due')),
    'suspended_stores', (select count(*)::int from subscriptions where status = 'suspended'),
    'mrr_cents', coalesce((
      select sum(sp.monthly_price_cents)::bigint
      from subscriptions sub
      join subscription_plans sp on sp.id = sub.plan_id
      where sub.status = 'active'
    ), 0),
    'total_products', coalesce((select sum(product_count)::bigint from store_usage), 0),
    'total_sales', coalesce((select sum(sale_count)::bigint from store_usage), 0),
    'total_users', (select count(*)::int from profiles where is_active),
    'total_storage_bytes', coalesce((select sum(total_bytes)::bigint from storage_usage), 0),
    'paid_stores', (select count(*)::int from subscriptions where status = 'active' and plan_id <> 'free_trial')
  ) into result;

  return result;
end;
$$;

grant execute on function public.inventrax_platform_impersonate_store(text) to authenticated;
grant execute on function public.inventrax_platform_end_impersonation() to authenticated;
grant execute on function public.inventrax_refresh_storage_usage(text) to authenticated;
grant execute on function public.inventrax_platform_analytics() to authenticated;
grant execute on function public.inventrax_platform_search(text) to authenticated;
