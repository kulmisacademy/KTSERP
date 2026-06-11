-- Resend email OTP infrastructure (password reset + future transactional email).

create table if not exists public.email_otps (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  purpose text not null default 'password_reset',
  otp_hash text not null,
  reset_token_hash text,
  expires_at timestamptz not null,
  attempts int not null default 0,
  max_attempts int not null default 5,
  created_at timestamptz not null default now(),
  used_at timestamptz,
  verified_at timestamptz,
  last_sent_at timestamptz not null default now()
);

create index if not exists idx_email_otps_email_created
  on public.email_otps (lower(email), created_at desc);

create index if not exists idx_email_otps_purpose_email
  on public.email_otps (purpose, lower(email), created_at desc);

alter table public.email_otps enable row level security;

-- Service role only (edge functions).
revoke all on public.email_otps from anon, authenticated;

create or replace function public.inventrax_platform_email_otp_stats()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'sent_today',
      (select count(*)::int from email_otps
        where created_at >= date_trunc('day', now() at time zone 'utc')),
    'verified_today',
      (select count(*)::int from email_otps
        where verified_at is not null
          and verified_at >= date_trunc('day', now() at time zone 'utc')),
    'failed_today',
      (select count(*)::int from email_otps
        where attempts >= max_attempts
          and created_at >= date_trunc('day', now() at time zone 'utc')),
    'pending',
      (select count(*)::int from email_otps
        where used_at is null
          and verified_at is null
          and expires_at > now()
          and attempts < max_attempts)
  );
$$;

grant execute on function public.inventrax_platform_email_otp_stats() to authenticated;
