# Staging Android APK for QA (mock OTP 123456, push disabled).
# Output: apps/mobile/build/app/outputs/flutter-apk/app-release.apk

$ErrorActionPreference = "Stop"
$ApiBase = "https://moozhayilapp-fyz6.onrender.com/v1"

Push-Location "$PSScriptRoot\..\apps\mobile"
try {
  flutter build apk --release `
    --dart-define=API_BASE_URL=$ApiBase `
    --dart-define=PUSH_ENABLED=false
  Write-Host "`nStaging APK: build\app\outputs\flutter-apk\app-release.apk"
} finally {
  Pop-Location
}
