-- Somali phone normalization + KULMIS ERP OTP SMS branding (sender KULMISERP).

update otp_apps set
  sms_sender_name = 'KULMISERP',
  otp_template_en = E'KULMIS ERP verification code: {{otp}}\n\nDo not share this code with anyone.',
  otp_template_so = E'KULMIS ERP:\nKoodhka xaqiijintaagu waa {{otp}}.\n\nHa la wadaagin qof kale.',
  otp_template_ar = E'KULMIS ERP:\nرمز التحقق الخاص بك هو {{otp}}'
where id = 'kulmis-erp';

-- E.164 storage: 252 + 9-digit local (6/7/9 prefix)
create or replace function public.normalize_phone(p_phone text)
returns text
language plpgsql
immutable
as $$
declare
  d text;
  local text;
begin
  d := regexp_replace(coalesce(p_phone, ''), '[^0-9]', '', 'g');
  if d = '' then
    return null;
  end if;
  if d like '00%' then
    d := substring(d from 3);
  end if;
  if d like '252%' and length(d) >= 12 then
    local := substring(d from 4);
  elsif d like '0%' and length(d) >= 9 then
    local := substring(d from 2);
  else
    local := d;
  end if;
  if local ~ '^[679][0-9]{8}$' then
    return '252' || local;
  end if;
  return d;
end;
$$;
