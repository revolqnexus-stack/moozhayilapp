# Install Moozhayil APK over USB (shows real errors instead of endless "Installing...")
$ErrorActionPreference = "Stop"
$Apk = "c:\Users\eathe\app moozhayil\Moozhayil-prod-arm64-v2.apk"
if (-not (Test-Path $Apk)) {
  Write-Error "APK not found: $Apk"
}

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
if (-not (Test-Path $adb)) {
  Write-Error "adb not found. Install Android SDK platform-tools or Android Studio."
}

& $adb devices
$serial = (& $adb devices | Select-String "device$" | Select-Object -First 1)
if (-not $serial) {
  Write-Host ""
  Write-Host "No phone detected. On the phone:" -ForegroundColor Yellow
  Write-Host "  Settings > About phone > tap Build number 7 times"
  Write-Host "  Settings > Developer options > USB debugging ON"
  Write-Host "  Plug in USB, accept the RSA fingerprint prompt"
  exit 1
}

Write-Host "Installing $Apk ..."
& $adb install -r $Apk
if ($LASTEXITCODE -eq 0) {
  Write-Host "Installed OK." -ForegroundColor Green
} else {
  Write-Host "Install failed (see message above)." -ForegroundColor Red
}
