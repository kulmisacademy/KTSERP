-- Super Admin SaaS: plans, usage, storage, audit logs, platform RPCs.

-- ---------------------------------------------------------------------------
-- Subscription plans (catalog)
-- ---------------------------------------------------------------------------

create table if not exists subscription_plans (
  id text primary key,
  name text not null,
  description text,
  monthly_price_cents integer not null default 0,
  yearly_price_cents integer not null default 0,
  product_limit integer,
  user_limit integer,
  storage_limit_bytes bigint,
  branch_limit integer,
  features jsonb not null default '[]'::jsonb,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into subscription_plans (
  id, name, description, monthly_price_cents, yearly_price_cents,
  product_limit, user_limit, storage_limit_bytes, branch_limit, features, sort_order
) values
  (
    'free_trial', 'Free Trial', '14-day evaluation',
    0, 0, 50, 2, 536870912, 1,
    '["pos","products","offline"]'::jsonb, 10
  ),
  (
    'starter', 'Starter', 'Small stores',
    2900, 29000, 500, 5, 5368709120, 1,
    '["pos","products","reports","offline"]'::jsonb, 20
  ),
  (
    'business', 'Business', 'Growing businesses',
    7900, 79000, 5000, 15, 21474836480, 3,
    '["pos","products","reports","accounting","realtime","offline"]'::jsonb, 30
  ),
  (
    'enterprise', 'Enterprise', 'Large supermarkets',
    19900, 199000, null, null, 107374182400, null,
    '["*"]'::jsonb, 40
  )
on conflict (id) do update set
  name = excluded.name,
  description = excluded.description,
  monthly_price_cents = excluded.monthly_price_cents,
  yearly_price_cents = excluded.yearly_price_cents,
  product_limit = excluded.product_limit,
  user_limit = excluded.user_limit,
  storage_limit_bytes = excluded.storage_limit_bytes,
  branch_limit = excluded.branch_limit,
  features = excluded.features,
  sort_order = excluded.sort_order,
  updated_at = now();

-- Link subscriptions to plans
alter table subscriptions
  add column if not exists plan_id text references subscription_plans (id),
  add column if not exists billing_cycle text not null default 'monthly',
  add column if not exists store_id text references stores (id) on delete cascade,
  add column if not exists updated_at timestamptz not null default now();

update subscriptions s
set plan_id = coalesce(
  (select sp.id from subscription_plans sp
   where lower(sp.name) = lower(s.plan_name) limit 1),
  'free_trial'
)
where s.plan_id is null;

update subscriptions s
set store_id = (
  select st.id from stores st where st.tenant_id = s.tenant_id order by st.created_at limit 1
)
where s.store_id is null;

-- ---------------------------------------------------------------------------
-- Per-store usage & storage snapshots
-- ---------------------------------------------------------------------------

create table if not exists store_usage (
  store_id text primary key references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  product_count integer not null default 0,
  sale_count integer not null default 0,
  purchase_count integer not null default 0,
  customer_count integer not null default 0,
  supplier_count integer not null default 0,
  user_count integer not null default 0,
  debt_count integer not null default 0,
  revenue_cents bigint not null default 0,
  expense_cents bigint not null default 0,
  inventory_value_cents bigint not null default 0,
  last_active_at timestamptz,
  last_sync_at timestamptz,
  queue_failures integer not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists storage_usage (
  store_id text primary key references stores (id) on delete cascade,
  tenant_id text not null references tenants (id) on delete cascade,
  total_bytes bigint not null default 0,
  image_count integer not null default 0,
  pdf_bytes bigint not null default 0,
  attachment_bytes bigint not null default 0,
  updated_at timestamptz not null default now()
);

create table if not exists platform_metrics (
  id text primary key default 'global',
  snapshot_at timestamptz not null default now(),
  total_stores integer not null default 0,
  active_stores integer not null default 0,
  trial_stores integer not null default 0,
  expired_stores integer not null default 0,
  mrr_cents bigint not null default 0,
  total_products bigint not null default 0,
  total_sales bigint not null default 0,
  total_users bigint not null default 0,
  total_storage_bytes bigint not null default 0
);

create table if not exists admin_activity_logs (
  id text primary key,
  admin_user_id uuid not null,
  admin_email text,
  action text not null,
  target_type text,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_admin_activity_created
  on admin_activity_logs (created_at desc);

create index if not exists idx_store_usage_tenant on store_usage (tenant_id);
create index if not exists idx_subscriptions_status on subscriptions (status);
create index if not exists idx_subscriptions_plan on subscriptions (plan_id);

-- ---------------------------------------------------------------------------
-- Super admin guard
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_is_super_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.inventrax_role_id() = 'super_admin';
$$;

-- ---------------------------------------------------------------------------
-- Refresh store usage (call from cron or super admin UI)
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_refresh_store_usage(p_store_id text default null)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  n int := 0;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  for r in
    select s.id as store_id, s.tenant_id
    from stores s
    where p_store_id is null or s.id = p_store_id
  loop
    insert into store_usage (
      store_id, tenant_id,
      product_count, sale_count, purchase_count,
      customer_count, supplier_count, user_count, debt_count,
      revenue_cents, expense_cents, inventory_value_cents,
      updated_at
    )
    values (
      r.store_id, r.tenant_id,
      (select count(*)::int from products p where p.store_id = r.store_id),
      (select count(*)::int from sales sa where sa.store_id = r.store_id and sa.status != 'voided'),
      (select count(*)::int from purchases pu where pu.store_id = r.store_id),
      (select count(*)::int from customers c where c.store_id = r.store_id),
      (select count(*)::int from suppliers su where su.store_id = r.store_id),
      (select count(*)::int from profiles pr where pr.store_id = r.store_id and pr.is_active),
      (select count(*)::int from debts d where d.store_id = r.store_id),
      coalesce((select sum(total_cents)::bigint from sales sa where sa.store_id = r.store_id and sa.status != 'voided'), 0),
      coalesce((select sum(amount_cents)::bigint from expenses e where e.store_id = r.store_id), 0),
      coalesce((select sum((p.purchase_price_cents * p.quantity))::bigint from products p where p.store_id = r.store_id), 0),
      now()
    )
    on conflict (store_id) do update set
      product_count = excluded.product_count,
      sale_count = excluded.sale_count,
      purchase_count = excluded.purchase_count,
      customer_count = excluded.customer_count,
      supplier_count = excluded.supplier_count,
      user_count = excluded.user_count,
      debt_count = excluded.debt_count,
      revenue_cents = excluded.revenue_cents,
      expense_cents = excluded.expense_cents,
      inventory_value_cents = excluded.inventory_value_cents,
      updated_at = now();
    n := n + 1;
  end loop;
  return n;
end;
$$;

-- ---------------------------------------------------------------------------
-- Platform dashboard metrics (JSON for Flutter)
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- List stores for super admin
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_platform_list_stores(p_search text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  rows jsonb;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  select coalesce(jsonb_agg(row_to_json(t)), '[]'::jsonb)
  into rows
  from (
    select
      s.id as store_id,
      s.tenant_id,
      s.name as store_name,
      s.logo_url,
      s.country,
      s.currency_code,
      s.status as store_status,
      s.created_at,
      sub.status as subscription_status,
      sub.plan_id,
      sp.name as plan_name,
      owner.full_name as owner_name,
      owner.email as owner_email,
      owner.phone as owner_phone,
      coalesce(u.product_count, 0) as product_count,
      coalesce(u.sale_count, 0) as sale_count,
      coalesce(u.revenue_cents, 0) as revenue_cents,
      coalesce(st.total_bytes, 0) as storage_bytes,
      sp.storage_limit_bytes
    from stores s
    left join subscriptions sub on sub.tenant_id = s.tenant_id
    left join subscription_plans sp on sp.id = sub.plan_id
    left join lateral (
      select p.full_name, p.email, p.phone
      from profiles p
      where p.store_id = s.id and p.role_id = 'store_owner'
      order by p.created_at
      limit 1
    ) owner on true
    left join store_usage u on u.store_id = s.id
    left join storage_usage st on st.store_id = s.id
    where p_search is null
       or s.name ilike '%' || p_search || '%'
       or owner.email ilike '%' || p_search || '%'
       or owner.full_name ilike '%' || p_search || '%'
    order by s.created_at desc
    limit 200
  ) t;

  return rows;
end;
$$;

-- ---------------------------------------------------------------------------
-- Store detail for super admin
-- ---------------------------------------------------------------------------

create or replace function public.inventrax_platform_store_detail(p_store_id text)
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

  perform public.inventrax_refresh_store_usage(p_store_id);

  select jsonb_build_object(
    'store', (
      select row_to_json(x) from (
        select s.*, sub.status as subscription_status, sub.plan_id,
               sub.trial_ends_at, sub.current_period_end, sub.billing_cycle,
               sp.name as plan_name, sp.product_limit, sp.user_limit, sp.storage_limit_bytes
        from stores s
        left join subscriptions sub on sub.tenant_id = s.tenant_id
        left join subscription_plans sp on sp.id = sub.plan_id
        where s.id = p_store_id
        limit 1
      ) x
    ),
    'owner', (
      select row_to_json(x) from (
        select full_name, email, phone, created_at
        from profiles
        where store_id = p_store_id and role_id = 'store_owner'
        limit 1
      ) x
    ),
    'usage', (select row_to_json(u) from store_usage u where u.store_id = p_store_id),
    'storage', (select row_to_json(st) from storage_usage st where st.store_id = p_store_id)
  ) into result;

  return result;
end;
$$;

-- Update subscription (super admin)
create or replace function public.inventrax_platform_update_subscription(
  p_tenant_id text,
  p_plan_id text,
  p_status text,
  p_trial_days int default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  update subscriptions
  set
    plan_id = p_plan_id,
    plan_name = (select name from subscription_plans where id = p_plan_id),
    status = p_status,
    trial_ends_at = case
      when p_trial_days is not null then now() + (p_trial_days || ' days')::interval
      else trial_ends_at
    end,
    current_period_end = case
      when p_status = 'active' then now() + interval '30 days'
      else current_period_end
    end,
    updated_at = now()
  where tenant_id = p_tenant_id;

  insert into admin_activity_logs (id, admin_user_id, admin_email, action, target_type, target_id, metadata)
  values (
    gen_random_uuid()::text,
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    'subscription.update',
    'tenant',
    p_tenant_id,
    jsonb_build_object('plan_id', p_plan_id, 'status', p_status)
  );
end;
$$;

-- Suspend store
create or replace function public.inventrax_platform_set_store_status(
  p_store_id text,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tenant text;
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;

  update stores set status = p_status where id = p_store_id returning tenant_id into v_tenant;

  if p_status = 'suspended' then
    update subscriptions set status = 'suspended', updated_at = now() where tenant_id = v_tenant;
  end if;

  insert into admin_activity_logs (id, admin_user_id, admin_email, action, target_type, target_id, metadata)
  values (
    gen_random_uuid()::text,
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    'store.status',
    'store',
    p_store_id,
    jsonb_build_object('status', p_status)
  );
end;
$$;

-- Log admin action helper
create or replace function public.inventrax_admin_log(
  p_action text,
  p_target_type text,
  p_target_id text,
  p_metadata jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.inventrax_is_super_admin() then
    raise exception 'Forbidden';
  end if;
  insert into admin_activity_logs (id, admin_user_id, admin_email, action, target_type, target_id, metadata)
  values (
    gen_random_uuid()::text,
    auth.uid(),
    (select email from profiles where id = auth.uid()),
    p_action,
    p_target_type,
    p_target_id,
    p_metadata
  );
end;
$$;

grant execute on function public.inventrax_refresh_store_usage(text) to authenticated;
grant execute on function public.inventrax_platform_dashboard() to authenticated;
grant execute on function public.inventrax_platform_list_stores(text) to authenticated;
grant execute on function public.inventrax_platform_store_detail(text) to authenticated;
grant execute on function public.inventrax_platform_update_subscription(text, text, text, int) to authenticated;
grant execute on function public.inventrax_platform_set_store_status(text, text) to authenticated;
grant execute on function public.inventrax_admin_log(text, text, text, jsonb) to authenticated;

-- RLS
alter table subscription_plans enable row level security;
alter table store_usage enable row level security;
alter table storage_usage enable row level security;
alter table admin_activity_logs enable row level security;

drop policy if exists inventrax_subscription_plans_read on subscription_plans;
create policy inventrax_subscription_plans_read on subscription_plans
  for select to authenticated using (true);

drop policy if exists inventrax_subscription_plans_write on subscription_plans;
create policy inventrax_subscription_plans_write on subscription_plans
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

drop policy if exists inventrax_store_usage_super on store_usage;
create policy inventrax_store_usage_super on store_usage
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

drop policy if exists inventrax_storage_usage_super on storage_usage;
create policy inventrax_storage_usage_super on storage_usage
  for all to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

drop policy if exists inventrax_admin_logs_super on admin_activity_logs;
create policy inventrax_admin_logs_super on admin_activity_logs
  for select to authenticated
  using (public.inventrax_is_super_admin());

drop policy if exists inventrax_subscriptions_super_write on subscriptions;
create policy inventrax_subscriptions_super_write on subscriptions
  for update to authenticated
  using (public.inventrax_is_super_admin())
  with check (public.inventrax_is_super_admin());

drop trigger if exists trg_subscription_plans_updated_at on subscription_plans;
create trigger trg_subscription_plans_updated_at
  before update on subscription_plans
  for each row execute function public.inventrax_set_updated_at();
