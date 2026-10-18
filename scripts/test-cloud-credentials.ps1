# Tests Neon + Upstash from PRODUCTION_ENV.txt without printing secrets.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/test-cloud-credentials.ps1

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

$env:DATABASE_URL = $vars["DATABASE_URL"]
$env:REDIS_URL = $vars["REDIS_URL"]

$apiDir = Join-Path $Root "apps\api"
$env:NODE_PATH = Join-Path $apiDir "node_modules"
Push-Location $apiDir
node (Join-Path $Root "scripts\test-cloud-connectors.js")
$code = $LASTEXITCODE
Pop-Location

if ($code -ne 0) {
  Write-Error "Connector test failed (exit $code)"
}

Write-Host "Neon + Upstash: OK"
Write-Host "If Render still uses the old Upstash token, update REDIS_URL in the Render dashboard."
