#!/usr/bin/env bash
# One-time: stop Vercel from running Flutter build on the server (GitHub Actions builds locally).
set -euo pipefail

PROJECT="${VERCEL_PROJECT_NAME:-kulmiserp}"
TEAM_ID="${VERCEL_TEAM_ID:-team_UP4pmRBtBm27E8FYQE2JZuhI}"
TOKEN="${VERCEL_TOKEN:?Set VERCEL_TOKEN from https://vercel.com/account/tokens}"

echo "Patching Vercel project '$PROJECT' (team $TEAM_ID)..."
curl -sf -X PATCH "https://api.vercel.com/v9/projects/${PROJECT}?teamId=${TEAM_ID}" \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "buildCommand": "",
    "installCommand": "",
    "outputDirectory": null,
    "framework": null,
    "commandForIgnoringBuildStep": "exit 0"
  }' | jq '{name, buildCommand, installCommand, outputDirectory, framework, commandForIgnoringBuildStep}'

echo "Done. Remote build disabled — deploys upload static files only."
