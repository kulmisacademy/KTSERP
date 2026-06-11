-- KULMIS ERP load-test seed (run on a dedicated staging store only).
-- Targets: 50k products, 1M sales, 10k customers.
-- Benchmark after seed: POS search <300ms, checkout <500ms, dashboard <2s.

-- 1) Pick or create a staging store id:
-- \set store_id 'your-staging-store-uuid'

-- 2) Products (50k) — batched insert example:
/*
insert into products (id, store_id, tenant_id, name, sku, price_cents, quantity, created_at, updated_at)
select
  gen_random_uuid()::text,
  :'store_id',
  (select tenant_id from stores where id = :'store_id'),
  'LoadTest Product ' || g,
  'LT-' || g,
  (random() * 50000)::int,
  (random() * 200)::int,
  now(),
  now()
from generate_series(1, 50000) g;
*/

-- 3) Customers (10k):
/*
insert into customers (id, store_id, tenant_id, name, phone, created_at, updated_at)
select
  gen_random_uuid()::text,
  :'store_id',
  (select tenant_id from stores where id = :'store_id'),
  'Customer ' || g,
  '+25261' || lpad(g::text, 7, '0'),
  now(),
  now()
from generate_series(1, 10000) g;
*/

-- 4) Sales (1M) — use batched chunks of 10k to avoid timeout:
/*
do $$
declare
  i int;
  batch int := 10000;
  total int := 1000000;
begin
  for i in 0..(total / batch - 1) loop
    insert into sales (id, store_id, tenant_id, total_cents, created_at, updated_at, status)
    select
      gen_random_uuid()::text,
      'your-staging-store-uuid',
      (select tenant_id from stores where id = 'your-staging-store-uuid'),
      (random() * 100000)::int,
      now() - (random() * interval '365 days'),
      now(),
      'completed'
    from generate_series(1, batch);
    raise notice 'Inserted batch %', i + 1;
    commit;
  end loop;
end $$;
*/

-- 5) Flutter benchmark checklist (manual):
--    - POS catalog search with 50k local products after sync
--    - Checkout single-item sale 20x, median latency
--    - Dashboard cold load after login
--    - AI insights first question with streaming enabled

-- 6) Concurrent users: use k6 or Artillery against Supabase REST + edge functions
--    with 100 VUs on read-heavy endpoints (products list, dashboard RPC).
