-- Remove SMS billing infrastructure (replaced by dashboard alerts + WhatsApp share).

drop function if exists public.inventrax_store_sms_wallet();
drop function if exists public.inventrax_deduct_sms_balance(text, int);
drop function if exists public.inventrax_deduct_sms_balance(text, integer, text);

drop table if exists public.sms_logs cascade;
drop table if exists public.sms_queue cascade;
drop table if exists public.sms_reminders cascade;
drop table if exists public.sms_templates cascade;
drop table if exists public.store_sms_settings cascade;
drop table if exists public.store_sms_wallets cascade;
drop table if exists public.sms_packages cascade;
