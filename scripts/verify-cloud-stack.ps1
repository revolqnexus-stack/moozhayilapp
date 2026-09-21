# Verifies Render API is up and connected to Neon + Upstash.
# Usage: powershell -ExecutionPolicy Bypass -File scripts/verify-cloud-stack.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ConfigPath = Join-Path $Root "config\cloud-stack.json"
$config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "Checking $($config.healthUrl) ..."
$response = Invoke-RestMethod -Uri $config.healthUrl -TimeoutSec 60

Write-Host ""
Write-Host "Overall:  $($response.status)"
Write-Host "Database: $($response.checks.database.status) ($($response.checks.database.latency_ms) ms)"
Write-Host "Redis:    $($response.checks.redis.status) ($($response.checks.redis.latency_ms) ms)"
Write-Host ""
Write-Host "Mobile API (v1): $($config.renderApiV1)"
Write-Host "Admin CRM:       set VITE_API_BASE=$($config.renderApiBase)"

if ($response.status -ne "ok") {
  exit 1
}
