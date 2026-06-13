# Deploy prebuilt Flutter web to kulmiserp (no remote Vercel build).
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$project = "kulmiserp"
$scope = "kulmisacademys-projects"

Write-Host "=== Flutter web build ===" -ForegroundColor Cyan
flutter pub get
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run --dart-define-from-file=.env
if (-not (Test-Path "build/web/index.html")) { throw "build/web/index.html missing" }

Write-Host "=== Prepare Vercel prebuilt output ===" -ForegroundColor Cyan
Remove-Item -Recurse -Force .vercel/output -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path .vercel/output/static | Out-Null
Copy-Item -Recurse -Force build/web/* .vercel/output/static/
Remove-Item -Force .vercel/output/static/vercel.json -ErrorAction SilentlyContinue

@'
{
  "version": 3,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
'@ | Set-Content -Path .vercel/output/config.json -Encoding utf8NoBOM

$size = (Get-ChildItem .vercel/output/static -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host ("Bundle size: {0:N1} MB" -f $size)

Write-Host "=== Deploy (prebuilt + archive, no remote build) ===" -ForegroundColor Cyan
vercel deploy --prebuilt --prod --yes --archive=tgz --project $project --scope $scope

Write-Host "Done. Open https://kulmiserp.vercel.app" -ForegroundColor Green
