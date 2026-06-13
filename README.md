## InventraX ERP

InventraX is an **offline-first, multi-tenant ERP + POS** for retail (Somalia/East Africa first) built with:

- **Frontend**: Flutter + Riverpod + go_router
- **Offline DB**: Drift (SQLite)
- **Backend**: Supabase (Postgres + Auth + Realtime + Storage + Edge Functions)

The product requirements are captured in `InventraX_ERP_PRD.md`.

### Repo layout

- `InventraX_ERP_PRD.md`: Product requirements (source of truth)
- `inventrax_erp/`: Flutter application

### Run the app

```bash

cd inventrax_erp
flutter pub get
flutter run
```

### Vercel production deploy

**How it works:** GitHub Actions builds Flutter on Ubuntu, then uploads the static `build/web` folder to Vercel. Vercel must **NOT** run its own build (that causes 30–45 min “Building…” hangs).

#### One-time Vercel dashboard fix (do this once)

1. Open [vercel.com → kulmiserp → Settings → General](https://vercel.com/kulmisacademys-projects/kulmiserp/settings)
2. Under **Build & Development Settings**:
   - **Framework Preset:** Other
   - Turn **OFF** the override toggle for **Build Command** (must be empty — not `bash vercel-build.sh`)
   - Turn **OFF** override for **Output Directory**
   - Turn **OFF** override for **Install Command**
3. Under **Ignored Build Step**, set command to: `exit 0`
4. Save

#### GitHub secrets (Settings → Secrets → Actions)

| Secret | Required |
|--------|----------|
| `SUPABASE_URL` | Yes |
| `SUPABASE_ANON_KEY` | Yes |
| `VERCEL_TOKEN` | Yes — [create token](https://vercel.com/account/tokens) with **Full Account** |

Do **not** set `VERCEL_ORG_ID` / `VERCEL_PROJECT_ID` unless you know they are correct.

#### Local deploy

```powershell
cd inventrax_erp
.\vercel-deploy.ps1
```

Every push to `main` triggers automatic deploy via GitHub Actions.

Set these in Vercel project environment (and Supabase Edge Function secrets):

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
RESEND_API_KEY=
WAAFI_API_KEY=
SENTRY_DSN=
```

`vercel.json` in `inventrax_erp/` configures asset caching and the Flutter web build output (`build/web`).

### AI Business Insights (OpenAI)

Store sidebar: **AI Insights** (`/ai-insights`). Uses **local SQL aggregates only** — never sends raw transactions to OpenAI.

**Recommended (production):** Edge Function proxy — key stays on Supabase, not in the app.

1. Deploy the function and set secrets:

```bash
cd inventrax_erp
supabase db push
supabase secrets set OPENAI_API_KEY=sk-your-key-here
supabase secrets set OPENAI_MODEL=gpt-4o-mini
supabase functions deploy ai-insights
```

2. In `.env`, keep Supabase URL/anon key; **remove** `OPENAI_API_KEY` from the client (or set `AI_USE_EDGE_PROXY=true`, default).

```env
AI_USE_EDGE_PROXY=true
OPENAI_MODEL=gpt-4o-mini
```

**Monthly auto-report:** On first login each calendar month, the app generates an AI executive summary and pushes it to **Notifications** (tap to open AI Insights).

**Dev fallback:** Direct OpenAI from the app with `OPENAI_API_KEY` in `.env` and `AI_USE_EDGE_PROXY=false`.

Responses are **cached 6 hours** per question to reduce API cost.

AI responses follow the **Settings → Language** selection (English, Somali, Arabic). Redeploy `ai-insights` after pulling latest migrations.

### SMS (Hormuud — multi-tenant)

Stores send SMS through **KULMIS central gateway**; Hormuud API credentials never ship to client apps.

1. Register at [Hormuud Business](https://business.hormuud.com/) and note **API username/password** (profile → API Password).
2. Register your **sender ID** (store display name) in the Hormuud portal — required or sends fail with code `203`.
3. Deploy edge functions and set secrets:

```bash
cd inventrax_erp
supabase secrets set HORMUUD_SMS_USERNAME=your_api_username
supabase secrets set HORMUUD_SMS_PASSWORD=your_api_password
supabase functions deploy send-sms
supabase functions deploy sms-delivery
```

4. In Hormuud portal, set the **delivery report callback** to your `sms-delivery` function URL, e.g.  
   `https://<project-ref>.supabase.co/functions/v1/sms-delivery`

**API flow (server-side):** `POST /token` (password grant) → `POST /api/SendSMS` with Bearer token — per Hormuud SMS API documentation.

**In-app:** Debts → **SMS Center** (`/debts/sms`), quick **SMS** on debt rows, automated due-date reminders via background worker. Without Supabase/Hormuud secrets, debug builds simulate sends locally.

### Languages (i18n)

- **English**, **Somali**, **Arabic** — switch in **Settings → Localization → Language** (instant, no restart)
- Persists in **SharedPreferences** and local `store_settings.locale_code` (synced from Supabase `stores.locale_code` after `supabase db push`)
- **RTL** enabled automatically for Arabic
- ARB files: `inventrax_erp/lib/l10n/app_{en,so,ar}.arb` — add keys there, then `flutter gen-l10n`
- Sidebar, sync chip, AI Insights, settings, and errors use localized strings; other screens migrate incrementally via `context.l10n`

### What’s scaffolded so far

- App shell with **routing + theming**:
  - `/login` → `/onboarding` → `/dashboard` → `/pos`
- Placeholder screens matching the PRD’s module boundaries.

### User management (RBAC)

- **Roles**: Store Owner, Manager, Cashier, Accountant, Inventory Staff (+ Super Admin)
- **Permissions**: Full page + sub-page + action keys (`products.catalog.delete`, `accounting.ledger.view`, …) via `permission_registry.dart`
- **UI**: `/users` (list), `/users/create`, `/users/:id`, `/users/:id/permissions`
- **Backend**: Apply `inventrax_erp/supabase/migrations/20260529100000_inventrax_users_rbac.sql`
- **Create staff (Supabase)**: Deploy edge function `create-store-user`, then store owners can invite from the app

### QA & production validation

- **In-app**: Settings → **QA validation** (or `/settings/qa`) — automated integrity + performance checks and manual pre-launch checklist
- **Unit tests**: `flutter test test/qa/`
- **Large dataset seed** (local perf testing):

```bash
cd inventrax_erp
dart run tool/qa_seed.dart --products 10000 --sales 100000
```

### Recommended build order (V1)

- Auth + store isolation claims (`tenant_id`, `store_id`, `role`) — **done (RBAC layer)**
- Store onboarding (create store, set currency/tax/receipt header)
- Products + barcode + quick-add
- POS (cart, barcode workflow, receipt)
- Purchases → inventory movements
- Expenses + debts
- Reports export (PDF/Excel)
- Offline sync engine (queue + conflict rules) and plan enforcement

