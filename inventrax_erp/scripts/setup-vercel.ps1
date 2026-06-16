# One-time local setup: login, link project, print IDs for GitHub secrets.
$ErrorActionPreference = "Stop"
Set-Location (Split-Path $PSScriptRoot -Parent)

Write-Host "=== KULMIS ERP — Vercel setup ===" -ForegroundColor Cyan
Write-Host "This project is Flutter web (NOT Next.js)." -ForegroundColor Yellow
Write-Host ""

if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
  Write-Host "Installing Vercel CLI..."
  npm install -g vercel@latest
}

Write-Host "Step 1: Login (browser opens)"
vercel login

Write-Host ""
Write-Host "Step 2: Link to existing project 'kulmiserp'"
vercel link --yes --project kulmiserp

if (Test-Path ".vercel/project.json") {
  Write-Host ""
  Write-Host "=== Copy these to GitHub → Settings → Secrets → Actions ===" -ForegroundColor Green
  $link = Get-Content ".vercel/project.json" | ConvertFrom-Json
  Write-Host "VERCEL_ORG_ID     = $($link.orgId)"
  Write-Host "VERCEL_PROJECT_ID = $($link.projectId)"
  Write-Host ""
  Write-Host "VERCEL_TOKEN: create at https://vercel.com/account/tokens"
  Write-Host "SUPABASE_URL + SUPABASE_ANON_KEY: from your .env file"
} else {
  Write-Host "Link failed — run: vercel link" -ForegroundColor Red
}
