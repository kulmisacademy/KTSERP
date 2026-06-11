-- Every store must have a cloud SMS wallet row (multi-tenant billing).

insert into store_sms_wallets (store_id, tenant_id, balance_remaining, balance_purchased, balance_used)
select s.id, s.tenant_id, 0, 0, 0
from stores s
where not exists (
  select 1 from store_sms_wallets w where w.store_id = s.id
);
