# Local Windows equivalent of vercel-build.sh (Vercel runs the .sh on Linux).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

flutter pub get

if (-not (Test-Path ".env")) {
  Write-Error ".env not found. Copy .env.example to .env and fill in Supabase values."
}

flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --dart-define-from-file=.env

Copy-Item -Force vercel.web.json build/web/vercel.json
if (-not (Test-Path "build/web/index.html")) { throw "build/web/index.html missing" }

Write-Host "Built: build/web (serve with any static host or Vercel outputDirectory)"
