-- Store-level locale preference (synced with ERP language setting).
ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS locale_code TEXT NOT NULL DEFAULT 'en';

COMMENT ON COLUMN public.stores.locale_code IS 'UI language: en, so, ar';
