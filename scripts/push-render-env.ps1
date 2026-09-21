# Push Neon + Upstash (and other) env vars to Render via API, then redeploy.
#
# One-time setup:
#   1. Render Dashboard -> Account Settings -> API Keys -> Create
#   2. Save key to:  moozhayil-gold-diamonds/.render-api-key  (gitignored)
#      OR set env:   $env:RENDER_API_KEY = "rnd_..."
#
# Run:
#   powershell -ExecutionPolicy Bypass -File scripts/push-render-env.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/push-render-env.ps1 -ServiceName moozhayilapp

param(
  [string]$ServiceName = "moozhayilapp",
  [string]$ServiceHost = "moozhayilapp-fyz6.onrender.com",
  [switch]$SkipDeploy
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$KeyFile = Join-Path $Root ".render-api-key"
$EnvFile = Join-Path $Root "PRODUCTION_ENV.txt"

$apiKey = $env:RENDER_API_KEY
if (-not $apiKey -and (Test-Path $KeyFile)) {
  $apiKey = (Get-Content $KeyFile -Raw).Trim()
}

if (-not $apiKey) {
  Write-Error @"
Missing Render API key.
Create one at: https://dashboard.render.com/u/settings#api-keys
Then either:
  - Save it to .render-api-key in the repo root, OR
  - `$env:RENDER_API_KEY = 'rnd_...'
"@
}

if (-not (Test-Path $EnvFile)) {
  Write-Error "Missing PRODUCTION_ENV.txt"
}

$headers = @{
  Authorization = "Bearer $apiKey"
  Accept        = "application/json"
  "Content-Type" = "application/json"
}

function Invoke-RenderApi {
  param([string]$Method, [string]$Path, [object]$Body = $null)
  $uri = "https://api.render.com/v1$Path"
  if ($Body) {
    return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body ($Body | ConvertTo-Json -Depth 5)
  }
  return Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
}

Write-Host "Listing Render services..."
$services = Invoke-RenderApi -Method GET -Path "/services?limit=100"
$match = $services | ForEach-Object { $_.service } | Where-Object {
  $_.name -like "*$ServiceName*" -or $_.serviceDetails.url -like "*$ServiceHost*"
} | Select-Object -First 1

if (-not $match) {
  Write-Host "Available services:"
  $services | ForEach-Object { Write-Host "  - $($_.service.name)  $($_.service.serviceDetails.url)" }
  Write-Error "Could not find service matching '$ServiceName' or '$ServiceHost'"
}

$serviceId = $match.id
Write-Host "Target service: $($match.name) ($serviceId)"
Write-Host "URL: $($match.serviceDetails.url)"

$vars = @{}
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)=(.*)$') {
    $key = $Matches[1]
    $val = $Matches[2].Trim()
    if ($val -and $val -notmatch '^YOUR_|^<') {
      $vars[$key] = $val
    }
  }
}

# Render-specific overrides (keep mock providers until live keys exist)
$vars["PUBLIC_BASE_URL"] = "https://$ServiceHost"
$vars["NODE_ENV"] = "staging"
$vars["TRUST_PROXY"] = "true"
$vars["SMS_PROVIDER_MODE"] = "mock"
$vars["KYC_PROVIDER_MODE"] = "mock"
$vars["FIREBASE_MODE"] = "mock"
$vars["STORAGE_BACKEND"] = "local"
$vars["CORS_ALLOWED_ORIGINS"] = "http://localhost:5180,http://localhost:5173,https://$ServiceHost"

$keysToPush = @(
  "NODE_ENV", "PORT", "TRUST_PROXY", "LOG_LEVEL",
  "DATABASE_URL", "REDIS_URL",
  "JWT_SECRET", "JWT_REFRESH_SECRET", "OTP_HASH_SECRET",
  "PII_ENCRYPTION_SECRET", "ADMIN_JWT_SECRET",
  "KYC_WEBHOOK_SECRET", "GOLD_RATE_WEBHOOK_SECRET",
  "PAYMENT_PROVIDER", "PAYMENT_PROVIDER_MODE",
  "RAZORPAY_KEY_ID", "RAZORPAY_KEY_SECRET", "RAZORPAY_WEBHOOK_SECRET",
  "SMS_PROVIDER_MODE", "KYC_PROVIDER_MODE", "FIREBASE_MODE",
  "STORAGE_BACKEND", "PUBLIC_BASE_URL", "CORS_ALLOWED_ORIGINS",
  "ENABLE_DEMO_SEEDS", "WORKER_HEALTH_PORT"
)

Write-Host ""
Write-Host "Updating environment variables on Render..."
foreach ($key in $keysToPush) {
  if (-not $vars.ContainsKey($key)) { continue }
  $body = @{ value = $vars[$key] }
  Invoke-RenderApi -Method PUT -Path "/services/$serviceId/env-vars/$key" -Body $body | Out-Null
  Write-Host "  updated $key"
}

if ($SkipDeploy) {
  Write-Host "SkipDeploy set - not triggering redeploy."
  exit 0
}

Write-Host ""
Write-Host "Triggering deploy..."
$deploy = Invoke-RenderApi -Method POST -Path "/services/$serviceId/deploys" -Body @{ clearCache = "do_not_clear" }
Write-Host "Deploy id: $($deploy.id)  status: $($deploy.status)"

Write-Host "Waiting for health check (up to 3 min)..."
$healthUrl = "https://$ServiceHost/health"
for ($i = 0; $i -lt 18; $i++) {
  Start-Sleep -Seconds 10
  try {
    $health = Invoke-RestMethod -Uri $healthUrl -TimeoutSec 30
    if ($health.status -eq "ok") {
      Write-Host "Health OK - database: $($health.checks.database.status), redis: $($health.checks.redis.status)"
      exit 0
    }
    Write-Host "  status: $($health.status) (retrying...)"
  } catch {
    Write-Host "  not ready yet ($($_.Exception.Message))"
  }
}

Write-Host "Deploy triggered but health not confirmed yet. Check Render dashboard logs."
