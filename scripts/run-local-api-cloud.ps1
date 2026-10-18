# Sync PRODUCTION_ENV -> .env.cloud and start local API on Neon + Upstash.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/run-local-api-cloud.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

& (Join-Path $Root "scripts\sync-cloud-env.ps1")
Set-Location (Join-Path $Root "apps\api")
$env:MOOZHAYIL_ENV_FILE = ".env.cloud"
npm run dev
