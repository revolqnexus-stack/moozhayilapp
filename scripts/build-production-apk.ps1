# Production sideload APK (arm64 only, ~23 MB). Play Store uses build-production-android.ps1 (AAB).
param(
  [string]$ApiBase = "",
  [string]$OutName = "Moozhayil-prod-arm64-v9.apk"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$MobileRoot = Join-Path $Root "apps\mobile"

if (-not $ApiBase) {
  $cfg = Get-Content (Join-Path $Root "config/environments.json") -Raw | ConvertFrom-Json
  $ApiBase = $cfg.production.apiV1
}

$gsJsonPath = Join-Path $MobileRoot "android\app\google-services.json"
$gs = Get-Content $gsJsonPath -Raw | ConvertFrom-Json
$FirebaseProjectId = $gs.project_info.project_id
$FirebaseMessagingSenderId = $gs.project_info.project_number
$FirebaseAppId = $gs.client[0].client_info.mobilesdk_app_id
$FirebaseApiKey = $gs.client[0].api_key[0].current_key

if (-not (Test-Path (Join-Path $MobileRoot "android\key.properties"))) {
  Write-Error "Missing android/key.properties. Run scripts/build-production-android.ps1 -CreateKeystore once."
}

Push-Location $MobileRoot
try {
  flutter build apk --release `
    --split-per-abi `
    --target-platform android-arm64 `
    --dart-define=API_BASE_URL=$ApiBase `
    --dart-define=PUSH_ENABLED=true `
    --dart-define=FIREBASE_PROJECT_ID=$FirebaseProjectId `
    --dart-define=FIREBASE_API_KEY=$FirebaseApiKey `
    --dart-define=FIREBASE_APP_ID=$FirebaseAppId `
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FirebaseMessagingSenderId

  $built = Join-Path $MobileRoot "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
  $dest = Join-Path (Split-Path -Parent $Root) $OutName
  Copy-Item -Force $built $dest
  Write-Host "`nSideload APK: $dest"
  Write-Host "Gradle output: $built"
} finally {
  Pop-Location
}
