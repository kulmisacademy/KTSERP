#!/usr/bin/env bash
set -euxo pipefail

# Vercel Linux build — Flutter is not preinstalled.
FLUTTER_DIR="${FLUTTER_DIR:-/tmp/flutter}"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  FLUTTER_TAR="flutter_linux_3.41.1-stable.tar.xz"
  FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"
  curl -fsSL "$FLUTTER_URL" -o /tmp/flutter.tar.xz
  rm -rf "$FLUTTER_DIR"
  mkdir -p "$FLUTTER_DIR"
  tar -xf /tmp/flutter.tar.xz -C "$FLUTTER_DIR" --strip-components=1
fi
export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "ERROR: Set SUPABASE_URL and SUPABASE_ANON_KEY in Vercel Environment Variables."
  exit 1
fi

cat > .env <<EOF
SUPABASE_URL=${SUPABASE_URL}
SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
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

flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --dart-define-from-file=.env

cp vercel.web.json build/web/vercel.json
test -f build/web/index.html

echo "Build OK — $(du -sh build/web | cut -f1) in build/web"
