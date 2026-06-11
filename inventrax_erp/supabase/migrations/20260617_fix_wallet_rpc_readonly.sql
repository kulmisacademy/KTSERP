-- Fix: STABLE wallet RPCs cannot call INSERT (PostgREST read-only transaction error 25006).

create or replace function public.inventrax_store_sms_wallet()
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text;
  v_wallet store_sms_wallets%rowtype;
begin
  if v_tenant is null then raise exception 'Not authenticated'; end if;
  select store_id into v_store from profiles where id = auth.uid();
  if v_store is null then raise exception 'No store profile'; end if;

  select * into v_wallet from store_sms_wallets where store_id = v_store;

  return jsonb_build_object(
    'store_id', v_store,
    'tenant_id', v_tenant,
    'balance_remaining', coalesce(v_wallet.balance_remaining, 0),
    'balance_purchased', coalesce(v_wallet.balance_purchased, 0),
    'balance_used', coalesce(v_wallet.balance_used, 0),
    'updated_at', v_wallet.updated_at
  );
end;
$$;

create or replace function public.inventrax_store_billing_snapshot()
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_tenant text := public.inventrax_tenant_id();
  v_store text;
  v_sub record;
  v_wallet record;
  v_settings record;
  v_days int;
begin
  if v_tenant is null then
    raise exception 'Not authenticated';
  end if;

  select store_id into v_store from profiles where id = auth.uid();
  if v_store is null then
    raise exception 'No store profile';
  end if;

  select * into v_settings from billing_settings where id = 'global';

  select s.*, sp.name as plan_name, sp.monthly_price_cents, sp.yearly_price_cents,
         sp.features, sp.trial_days as plan_trial_days
  into v_sub
  from subscriptions s
  left join subscription_plans sp on sp.id = s.plan_id
  where s.tenant_id = v_tenant
  order by s.created_at desc
  limit 1;

  select * into v_wallet from store_sms_wallets where store_id = v_store;

  v_days := null;
  if v_sub.trial_ends_at is not null and v_sub.status = 'trialing' then
    v_days := greatest(0, extract(day from (v_sub.trial_ends_at - now()))::int);
  elsif v_sub.current_period_end is not null then
    v_days := greatest(0, extract(day from (v_sub.current_period_end - now()))::int);
  end if;

  return jsonb_build_object(
    'store_id', v_store,
    'tenant_id', v_tenant,
    'subscription', jsonb_build_object(
      'id', v_sub.id,
      'plan_id', v_sub.plan_id,
      'plan_name', v_sub.plan_name,
      'status', v_sub.status,
      'billing_cycle', v_sub.billing_cycle,
      'trial_ends_at', v_sub.trial_ends_at,
      'current_period_end', v_sub.current_period_end,
      'days_remaining', v_days,
      'monthly_price_cents', v_sub.monthly_price_cents,
      'yearly_price_cents', v_sub.yearly_price_cents,
      'features', v_sub.features
    ),
    'sms_wallet', jsonb_build_object(
      'balance_remaining', coalesce(v_wallet.balance_remaining, 0),
      'balance_purchased', coalesce(v_wallet.balance_purchased, 0),
      'balance_used', coalesce(v_wallet.balance_used, 0)
    ),
    'billing_settings', jsonb_build_object(
      'default_trial_days', coalesce(v_settings.default_trial_days, 14),
      'grace_period_days', coalesce(v_settings.grace_period_days, 3),
      'waafi_enabled', coalesce(v_settings.waafi_enabled, true)
    )
  );
end;
$$;
