#!/usr/bin/env bash
set -euo pipefail

# Install Flutter on Vercel (Linux) — not preinstalled.
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
fi
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --enable-web --no-analytics
flutter precache --web
flutter pub get

# pubspec.yaml bundles `.env` as an asset; create it from Vercel project env vars.
cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL:-}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}
APP_NAME=${APP_NAME:-InventraX ERP}
APP_ENV=${APP_ENV:-production}
API_TIMEOUT=${API_TIMEOUT:-30000}
ENABLE_LOGS=${ENABLE_LOGS:-false}
SENTRY_DSN=${SENTRY_DSN:-}
POSTHOG_API_KEY=${POSTHOG_API_KEY:-}
POSTHOG_HOST=${POSTHOG_HOST:-https://app.posthog.com}
AI_USE_EDGE_PROXY=${AI_USE_EDGE_PROXY:-true}
OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o-mini}
EOF

# Bundle CanvasKit locally — gstatic.com is blocked on some networks.
flutter build web --release --no-web-resources-cdn --dart-define-from-file=.env
