# One command: verify Render+Neon+Upstash, sync local cloud env, optional local API + admin + emulator.
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/connect-cloud-stack.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/connect-cloud-stack.ps1 -LocalApi
#   powershell -ExecutionPolicy Bypass -File scripts/connect-cloud-stack.ps1 -Emulator

param(
  [switch]$LocalApi,
  [switch]$Admin,
  [switch]$Emulator,
  [switch]$All
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if ($All) {
  $LocalApi = $true
  $Admin = $true
}

& (Join-Path $Root "scripts\verify-cloud-stack.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if ($LocalApi -or $All) {
  & (Join-Path $Root "scripts\sync-cloud-env.ps1")
  Write-Host ""
  Write-Host "Starting local API on port 3080 (Neon + Upstash)..."
  Start-Process powershell -ArgumentList @(
    "-NoExit", "-Command",
    "Set-Location '$Root'; powershell -File scripts/run-local-api-cloud.ps1"
  )
}

if ($Admin -or $All) {
  Write-Host "Starting admin CRM (points at Render via apps/admin/.env)..."
  Start-Process powershell -ArgumentList @(
    "-NoExit", "-Command",
    "Set-Location '$Root\apps\admin'; npm run dev"
  )
}

if ($Emulator -or $All) {
  & (Join-Path $Root "scripts\run-android-emulator.ps1")
}

if (-not ($LocalApi -or $Admin -or $Emulator -or $All)) {
  Write-Host ""
  Write-Host "Cloud stack is connected. Next steps:"
  Write-Host "  Emulator:  powershell -File scripts/run-android-emulator.ps1"
  Write-Host "  Local API: powershell -File scripts/sync-cloud-env.ps1  then  cd apps/api && npm run dev:cloud"
  Write-Host "  Admin:     cd apps/admin && npm run dev"
}
