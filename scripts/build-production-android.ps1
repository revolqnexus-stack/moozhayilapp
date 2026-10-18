# Production Android App Bundle for Google Play.
# Prerequisites:
#   1. android/key.properties + upload keystore (.jks)
#   2. Real google-services.json from Firebase
#   3. Replace placeholders below with production values

param(
  [string]$ApiBase = "",
  [string]$FirebaseProjectId = "",
  [string]$FirebaseApiKey = "",
  [string]$FirebaseAppId = "",
  [string]$FirebaseMessagingSenderId = "",
  [switch]$PushDisabled,
  [switch]$CreateKeystore
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$MobileRoot = Join-Path $Root "apps\mobile"
$AndroidRoot = Join-Path $MobileRoot "android"
$KeyProps = Join-Path $AndroidRoot "key.properties"
$KeystorePath = Join-Path $AndroidRoot "moozhayil-upload.jks"

if (-not $ApiBase) {
  $cfg = Get-Content (Join-Path $Root "config/environments.json") -Raw | ConvertFrom-Json
  if (-not $cfg.production.apiV1) {
    Write-Error "Production API URL not set. Run create-production-render-service.mjs or pass -ApiBase."
  }
  $ApiBase = $cfg.production.apiV1
}

$gsJsonPath = Join-Path $MobileRoot "android\app\google-services.json"
if (Test-Path $gsJsonPath) {
  $gs = Get-Content $gsJsonPath -Raw | ConvertFrom-Json
  if (-not $FirebaseProjectId) { $FirebaseProjectId = $gs.project_info.project_id }
  if (-not $FirebaseMessagingSenderId) { $FirebaseMessagingSenderId = $gs.project_info.project_number }
  if (-not $FirebaseAppId) { $FirebaseAppId = $gs.client[0].client_info.mobilesdk_app_id }
  if (-not $FirebaseApiKey) { $FirebaseApiKey = $gs.client[0].api_key[0].current_key }
}

foreach ($name in @("FirebaseProjectId","FirebaseApiKey","FirebaseAppId","FirebaseMessagingSenderId")) {
  if (-not (Get-Variable -Name $name).Value) {
    Write-Error "Missing Firebase value $name (google-services.json or -Firebase* param)."
  }
}

$pushEnabled = if ($PushDisabled) { "false" } else { "true" }

if ($CreateKeystore -or -not (Test-Path $KeyProps)) {
  if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Error "keytool not found. Install JDK 17+ and ensure keytool is on PATH."
  }
  $storePass = $null
  if ((Test-Path $KeystorePath) -and -not (Test-Path $KeyProps)) {
    Remove-Item $KeystorePath -Force
    Write-Host "Removed orphan keystore (no key.properties). Regenerating."
  }
  if (-not (Test-Path $KeystorePath)) {
    $storePass = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object { [char]$_ })
    $dname = "CN=Moozhayil Gold and Diamonds, OU=Mobile, O=MOOZHAYIL JEWELLERY, L=Kerala, ST=Kerala, C=IN"
    & keytool -genkeypair -v `
      -keystore $KeystorePath `
      -alias moozhayil `
      -keyalg RSA -keysize 2048 -validity 10000 `
      -storepass $storePass -keypass $storePass `
      -dname $dname | Out-Null
    Write-Host "Created upload keystore: $KeystorePath"
    Write-Host "BACK UP this file and passwords - required for all future Play Store updates."
  }
  if (-not (Test-Path $KeyProps)) {
    if (-not $storePass) {
      Write-Error "key.properties missing. Restore KEYSTORE_BACKUP.txt or delete .jks and run with -CreateKeystore."
    }
    @(
      "storeFile=moozhayil-upload.jks",
      "storePassword=$storePass",
      "keyAlias=moozhayil",
      "keyPassword=$storePass"
    ) | Set-Content -Path $KeyProps -Encoding UTF8
    $credBackup = Join-Path $AndroidRoot "KEYSTORE_BACKUP.txt"
    @(
      'MOOZHAYIL Play upload keystore - gitignored. Keep offline backup.'
      "Keystore: $KeystorePath"
      'Alias: moozhayil'
      "Store password: $storePass"
      "Key password: $storePass"
    ) | Set-Content -Path $credBackup -Encoding UTF8
    Write-Host "Wrote $KeyProps and $credBackup - do not commit."
  }
}

Push-Location $MobileRoot
try {
  if (-not (Test-Path "android\key.properties")) {
    Write-Error "Missing android/key.properties - run with -CreateKeystore once."
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
