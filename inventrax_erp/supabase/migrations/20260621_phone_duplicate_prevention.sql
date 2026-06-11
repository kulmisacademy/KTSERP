-- Prevent duplicate store registration on the same phone number.

create or replace function public.inventrax_check_registration_phone(p_phone text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_e164 text := public.inventrax_normalize_somali_phone(p_phone);
begin
  if v_e164 is null then
    return jsonb_build_object(
      'status', 'invalid',
      'message', 'Enter a valid Somali mobile number (e.g. 61xxxxxxx)'
    );
  end if;

  if exists (
    select 1 from profiles
    where public.inventrax_normalize_somali_phone(phone) = v_e164
  ) then
    return jsonb_build_object(
      'status', 'taken',
      'message', 'This phone number is already registered.'
    );
  end if;

  return jsonb_build_object('status', 'available');
end;
$$;

grant execute on function public.inventrax_check_registration_phone(text) to authenticated;
grant execute on function public.inventrax_check_registration_phone(text) to anon;

-- Clear duplicate phones on newer profiles (keep earliest registration per E.164).
with ranked as (
  select
    id,
    row_number() over (
      partition by public.inventrax_normalize_somali_phone(phone)
      order by coalesce(created_at, now()) asc, id asc
    ) as rn
  from profiles
  where phone is not null
    and trim(phone) <> ''
    and public.inventrax_normalize_somali_phone(phone) is not null
)
update profiles p
set phone = null
from ranked r
where p.id = r.id
  and r.rn > 1;

create unique index if not exists idx_profiles_phone_e164_unique
  on profiles ((public.inventrax_normalize_somali_phone(phone)))
  where phone is not null and trim(phone) <> '';
