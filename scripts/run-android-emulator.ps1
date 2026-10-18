# Launch Android emulator and run Flutter app against Render (Neon + Upstash backend).
# Usage: powershell -ExecutionPolicy Bypass -File scripts/run-android-emulator.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigPath = Join-Path $Root "config\cloud-stack.json"
$config = Get-Content $ConfigPath | ConvertFrom-Json
$MobileDir = Join-Path $Root "apps\mobile"
$apiUrl = $config.renderApiV1

Write-Host "Verifying cloud stack..."
& (Join-Path $Root "scripts\verify-cloud-stack.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Set-Location $MobileDir

$emulators = flutter emulators 2>&1 | Out-String
if ($emulators -match "Moozhayil") {
  Write-Host "Launching Moozhayil_Preview emulator..."
  flutter emulators --launch Moozhayil_Preview
}
elseif ($emulators -match "Pixel|Medium|API") {
  $match = [regex]::Match($emulators, '(?m)^(\S+)\s+')
  if ($match.Success) {
    $id = $match.Groups[1].Value
    Write-Host "Launching emulator: $id"
    flutter emulators --launch $id
  }
}
else {
  Write-Host "No emulator found. Connect a device or create an AVD in Android Studio."
}

Write-Host "Waiting 25s for emulator boot..."
Start-Sleep -Seconds 25

Write-Host "Starting Flutter with API: $apiUrl"
flutter run --dart-define=API_BASE_URL=$apiUrl --dart-define=PUSH_ENABLED=false
