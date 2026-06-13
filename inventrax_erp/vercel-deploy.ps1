# Deploy prebuilt Flutter web to kulmiserp (no remote Vercel build).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$project = "kulmiserp"
$scope = "kulmisacademys-projects"
$teamId = "team_UP4pmRBtBm27E8FYQE2JZuhI"

Write-Host "=== Flutter web build ===" -ForegroundColor Cyan
flutter pub get
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --dart-define-from-file=.env
if (-not (Test-Path "build/web/index.html")) { throw "build/web/index.html missing" }

Write-Host "=== Prepare Vercel prebuilt output ===" -ForegroundColor Cyan
Remove-Item -Recurse -Force .vercel/output -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path .vercel/output/static | Out-Null
Copy-Item -Recurse -Force build/web/* .vercel/output/static/
Remove-Item -Force .vercel/output/static/vercel.json -ErrorAction SilentlyContinue
'{"version":3,"routes":[{"handle":"filesystem"},{"src":"/(.*)","dest":"/index.html"}]}' |
  Set-Content -Path .vercel/output/config.json -Encoding utf8NoBOM

$size = (Get-ChildItem .vercel/output/static -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host ("Bundle size: {0:N1} MB" -f $size)

Write-Host "=== Deploy (upload only, no remote Flutter build) ===" -ForegroundColor Cyan
$log = vercel deploy --prebuilt --prod --yes --archive=tgz --no-wait --project $project --scope $scope 2>&1
$log | ForEach-Object { Write-Host $_ }
$url = ($log | Select-String -Pattern 'https://[a-zA-Z0-9._-]+\.vercel\.app' -AllMatches | ForEach-Object { $_.Matches } | Select-Object -Last 1).Value
if (-not $url) { throw "Deploy did not return a URL. See log above." }

Write-Host "Uploaded: $url" -ForegroundColor Yellow
Write-Host "Waiting for Vercel to finish (max 5 min)..." -ForegroundColor Cyan
vercel inspect $url --wait --timeout 5m --scope $scope

Write-Host "Done. Open https://kulmiserp.vercel.app" -ForegroundColor Green
