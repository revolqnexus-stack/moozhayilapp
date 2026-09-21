# Production Android release build for Moozhayil mobile app.
# Output: apps/mobile/build/app/outputs/bundle/release/app-release.aab

$ErrorActionPreference = "Stop"
$ApiBase = "https://moozhayilapp-fyz6.onrender.com/v1"

Push-Location "$PSScriptRoot\..\apps\mobile"
try {
  flutter build appbundle --release `
    --dart-define=API_BASE_URL=$ApiBase `
    --dart-define=PUSH_ENABLED=false
  Write-Host "`nRelease AAB: build\app\outputs\bundle\release\app-release.aab"
} finally {
  Pop-Location
}
