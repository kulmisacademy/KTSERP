# Local Windows equivalent of vercel-build.sh (Vercel runs the .sh on Linux).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

flutter pub get

if (-not (Test-Path ".env")) {
  Write-Error ".env not found. Copy .env.example to .env and fill in Supabase values."
}

flutter build web --release --no-web-resources-cdn --dart-define-from-file=.env

Write-Host "Built: build/web (serve with any static host or Vercel outputDirectory)"
