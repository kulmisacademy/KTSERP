-- =============================================================================
-- KULMIS ERP: Create Super Admin profile (fixes "No store linked to this account")
-- Run in: Supabase Dashboard → SQL Editor → Run
-- Prerequisite: User exists under Authentication → Users with this email
-- =============================================================================

DO $$
DECLARE
  v_email text := 'engapdirahmaan152@gmail.com';
  v_user_id uuid;
  v_tenant_id text := 'platform-tenant';
  v_store_id text := 'platform-store';
  v_sub_id text;
  v_name text;
BEGIN
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE lower(email) = lower(v_email);

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No Auth user for %. Create user in Authentication → Users first (Auto Confirm ON).', v_email;
  END IF;

  v_name := coalesce(
    nullif(trim(v_email), ''),
    split_part(v_email, '@', 1)
  );

  INSERT INTO tenants (id, name, country, currency_code, status)
  VALUES (v_tenant_id, 'KULMIS ERP Platform', '', 'USD', 'active')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO stores (id, tenant_id, name, business_type, country, currency_code, status)
  VALUES (v_store_id, v_tenant_id, 'Platform HQ', 'Platform', '', 'USD', 'active')
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO profiles (id, tenant_id, store_id, role_id, full_name, email, is_active)
  VALUES (
    v_user_id,
    v_tenant_id,
    v_store_id,
    'super_admin',
    'Platform Owner',
    v_email,
    true
  )
  ON CONFLICT (id) DO UPDATE SET
    role_id = 'super_admin',
    tenant_id = excluded.tenant_id,
    store_id = excluded.store_id,
    is_active = true;

  IF NOT EXISTS (SELECT 1 FROM subscriptions WHERE tenant_id = v_tenant_id) THEN
    v_sub_id := gen_random_uuid()::text;
    INSERT INTO subscriptions (id, tenant_id, plan_name, status, trial_ends_at)
    VALUES (
      v_sub_id,
      v_tenant_id,
      'Enterprise',
      'active',
      now() + interval '365 days'
    );
  END IF;

  RAISE NOTICE 'Super admin ready for % (user_id: %)', v_email, v_user_id;
END $$;

-- Verify
SELECT p.id, p.email, p.role_id, p.tenant_id, p.store_id, p.is_active
FROM profiles p
WHERE lower(p.email) = lower('engapdirahmaan152@gmail.com');
