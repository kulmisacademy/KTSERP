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
    { "src": "^/canvaskit/.*", "headers": { "cache-control": "public, max-age=31536000, immutable" }, "continue": true },
    { "src": ".*\\.(?:woff2?|ttf|otf)$", "headers": { "cache-control": "public, max-age=31536000, immutable" }, "continue": true },
    { "src": "^/(?:assets|icons)/.*", "headers": { "cache-control": "public, max-age=86400, must-revalidate" }, "continue": true },
    { "src": ".*\\.(?:png|jpg|jpeg|gif|webp|svg|ico)$", "headers": { "cache-control": "public, max-age=86400, must-revalidate" }, "continue": true },
    { "src": "^/(?:index\\.html|flutter_service_worker\\.js|flutter_bootstrap\\.js|main\\.dart\\.js|flutter\\.js|version\\.json|manifest\\.json)$", "headers": { "cache-control": "no-cache, must-revalidate" }, "continue": true },
    { "handle": "filesystem" },
    { "src": "/(.*)", "headers": { "cache-control": "no-cache, must-revalidate" }, "dest": "/index.html" }
  ]
}
'@ | Set-Content -Path .vercel/output/config.json -Encoding UTF8

$size = (Get-ChildItem .vercel/output/static -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host ("Bundle size: {0:N1} MB" -f $size)

Write-Host "=== Deploy (upload only, no remote Flutter build) ===" -ForegroundColor Cyan
# Hobby teams block deploys when git commit author != team owner. Stage outside repo .git.
$staging = Join-Path $env:TEMP "inventrax-vercel-$(Get-Random)"
New-Item -ItemType Directory -Force -Path "$staging/.vercel/output/static" | Out-Null
Copy-Item -Recurse -Force .vercel/output/static/* "$staging/.vercel/output/static/"
Copy-Item -Force .vercel/output/config.json "$staging/.vercel/output/config.json"
Copy-Item -Force .vercel/project.json "$staging/.vercel/project.json"
Push-Location $staging
try {
  $log = vercel deploy --prebuilt --prod --yes --archive=tgz --project $project --scope $scope 2>&1
  $log | ForEach-Object { Write-Host $_ }
  if ($log -match "must have access to the team") {
    throw "Vercel blocked deploy: git author must match Vercel team owner on Hobby plan."
  }
} finally {
  Pop-Location
  Remove-Item -Recurse -Force $staging -ErrorAction SilentlyContinue
}

Write-Host "Done. Open https://kulmiserp.vercel.app" -ForegroundColor Green
