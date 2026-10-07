# Build admin CRM with production API URL and deploy to Vercel.
# Requires: npx vercel login (once), linked project in apps/admin/.vercel

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Admin = Join-Path $Root "apps\admin"
$cfg = Get-Content (Join-Path $Root "config\environments.json") -Raw | ConvertFrom-Json
$apiBase = $cfg.production.apiBase
if (-not $apiBase) { Write-Error "production.apiBase missing in config/environments.json" }

Write-Host "VITE_API_BASE=$apiBase"
Push-Location $Admin
try {
  if (-not (Test-Path "node_modules")) { npm ci }
  $env:VITE_API_BASE = $apiBase
  npm run build
  npx vercel deploy --prod --yes
} finally {
  Pop-Location
}

Write-Host ""
Write-Host "CRM: $($cfg.production.adminCrmOrigin)"
Write-Host "Ensure Render CORS includes that origin: scripts/push-render-production-env.ps1 -ProductionExceptKyc -SkipDeploy"
