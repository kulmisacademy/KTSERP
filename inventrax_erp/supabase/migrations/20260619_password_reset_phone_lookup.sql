-- Normalize profile phones + reliable password-reset account lookup.

create or replace function public.inventrax_normalize_somali_phone(p_raw text)
returns text
language plpgsql
immutable
as $$
declare
  v_digits text;
  v_local text;
begin
  v_digits := regexp_replace(coalesce(p_raw, ''), '[^0-9]', '', 'g');
  if v_digits like '00%' then
    v_digits := substring(v_digits from 3);
  end if;
  if v_digits like '252%' and length(v_digits) >= 12 then
    v_local := substring(v_digits from 4);
  elsif v_digits like '0%' and length(v_digits) >= 9 then
    v_local := substring(v_digits from 2);
  else
    v_local := v_digits;
  end if;
  if v_local ~ '^[679][0-9]{8}$' then
    return '252' || v_local;
  end if;
  return null;
end;
$$;

create or replace function public.inventrax_find_profile_for_password_reset(
  p_phone text,
  p_email text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_email text := nullif(lower(trim(coalesce(p_email, ''))), '');
  v_e164 text := public.inventrax_normalize_somali_phone(p_phone);
  v_local text;
  v_profile record;
begin
  if v_email is not null then
    select id, email, phone into v_profile
    from profiles where lower(email) = v_email limit 1;
    if found then
      return jsonb_build_object(
        'id', v_profile.id,
        'email', v_profile.email,
        'phone', v_profile.phone
      );
    end if;
    return null;
  end if;

  if v_e164 is null then
    return null;
  end if;

  v_local := substring(v_e164 from 4);

  select id, email, phone into v_profile
  from profiles
  where public.inventrax_normalize_somali_phone(phone) = v_e164
     or phone in (v_e164, v_local, '0' || v_local)
  order by
    case when public.inventrax_normalize_somali_phone(phone) = v_e164 then 0 else 1 end,
    created_at desc
  limit 1;

  if not found then
    return null;
  end if;

  return jsonb_build_object(
    'id', v_profile.id,
    'email', v_profile.email,
    'phone', v_profile.phone
  );
end;
$$;

grant execute on function public.inventrax_find_profile_for_password_reset to service_role;

-- Backfill common phone formats to canonical E.164 digits.
update profiles
set phone = public.inventrax_normalize_somali_phone(phone)
where phone is not null
  and public.inventrax_normalize_somali_phone(phone) is not null
  and phone is distinct from public.inventrax_normalize_somali_phone(phone);
