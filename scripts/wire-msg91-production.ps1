# Wire MSG91 OTP on production Render (prelaunch + live SMS only).
# Requires PRODUCTION_ENV.txt:
#   MSG91_AUTH_KEY=<from MSG91 dashboard API>
#   MSG91_OTP_TEMPLATE_ID=6abb8a19a03188ad0c03da42
#
# DLT reference (not sent to Render): config/dlt-production.json

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvFile = Join-Path $Root "PRODUCTION_ENV.txt"

if (-not (Test-Path $EnvFile)) {
  Write-Error "Missing PRODUCTION_ENV.txt"
}

$vars = @{}
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)=(.*)$') {
    $vars[$Matches[1]] = $Matches[2].Trim()
  }
}

if (-not $vars["MSG91_OTP_TEMPLATE_ID"]) {
  $dlt = Join-Path $Root "config/dlt-production.json"
  if (Test-Path $dlt) {
    $cfg = Get-Content $dlt -Raw | ConvertFrom-Json
    Write-Host "MSG91_OTP_TEMPLATE_ID missing in env file; expected: $($cfg.msg91OtpTemplateId)"
  }
  Write-Error "Set MSG91_OTP_TEMPLATE_ID in PRODUCTION_ENV.txt"
}

if (-not $vars["MSG91_AUTH_KEY"] -or $vars["MSG91_AUTH_KEY"].Length -lt 8) {
  Write-Host ""
  Write-Host "MSG91_AUTH_KEY is missing in PRODUCTION_ENV.txt."
  Write-Host "MSG91 -> API -> copy Authkey into PRODUCTION_ENV.txt (line MSG91_AUTH_KEY=)."
  Write-Host "Then re-run: powershell -ExecutionPolicy Bypass -File scripts/wire-msg91-production.ps1"
  Write-Host ""
  exit 1
}

$dlt = Join-Path $Root "config/dlt-production.json"
if (Test-Path $dlt) {
  $cfg = Get-Content $dlt -Raw | ConvertFrom-Json
  if ($vars["MSG91_DLT_PE_ID"] -eq $cfg.brandDltId) {
    Write-Error "PRODUCTION_ENV MSG91_DLT_PE_ID is brandDltId; use peId $($cfg.peId). Match MSG91 SMS -> Sender Id -> MZHYIL PE field."
  }
  if (-not $vars["MSG91_DLT_PE_ID"]) {
    Write-Host "Optional in PRODUCTION_ENV.txt (Render push uses config): MSG91_DLT_PE_ID=$($cfg.peId)"
  }
  if (-not $vars["MSG91_DLT_TE_ID"]) {
    Write-Host "Optional in PRODUCTION_ENV.txt (Render push uses config): MSG91_DLT_TE_ID=$($cfg.airtelDltTemplateId)"
  }
}

& (Join-Path $Root "scripts/push-render-production-env.ps1") -Prelaunch -LiveSms

Write-Host ""
Write-Host "Prod API: https://moozhayilapp-prod.onrender.com"
Write-Host "Test: POST /v1/auth/otp/request with your phone (app or API client)."
Write-Host "If SMS still fails, check MSG91 Logs and Airtel PE-TM chain (config/dlt-production.json)."
