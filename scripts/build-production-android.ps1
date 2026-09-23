# Production Android App Bundle for Google Play.
# Prerequisites:
#   1. android/key.properties + upload keystore (.jks)
#   2. Real google-services.json from Firebase
#   3. Replace placeholders below with production values

param(
  [string]$ApiBase = "https://moozhayilapp-fyz6.onrender.com/v1",
  [string]$FirebaseProjectId = "REPLACE_ME",
  [string]$FirebaseApiKey = "REPLACE_ME",
  [string]$FirebaseAppId = "REPLACE_ME",
  [string]$FirebaseMessagingSenderId = "REPLACE_ME",
  [switch]$PushDisabled
)

$ErrorActionPreference = "Stop"
$pushEnabled = if ($PushDisabled) { "false" } else { "true" }

Push-Location "$PSScriptRoot\..\apps\mobile"
try {
  if (-not (Test-Path "android\key.properties")) {
    Write-Error "Missing android/key.properties — copy key.properties.example and add your upload keystore."
  }

  flutter build appbundle --release `
    --dart-define=API_BASE_URL=$ApiBase `
    --dart-define=PUSH_ENABLED=$pushEnabled `
    --dart-define=FIREBASE_PROJECT_ID=$FirebaseProjectId `
    --dart-define=FIREBASE_API_KEY=$FirebaseApiKey `
    --dart-define=FIREBASE_APP_ID=$FirebaseAppId `
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FirebaseMessagingSenderId

  Write-Host "`nPlay Store AAB: build\app\outputs\bundle\release\app-release.aab"
} finally {
  Pop-Location
}
