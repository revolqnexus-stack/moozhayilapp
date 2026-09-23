# Shared Render env push logic for staging and production targets.
param(
  [Parameter(Mandatory = $true)]
  [string]$EnvFile,
  [Parameter(Mandatory = $true)]
  [string]$ServiceName,
  [string]$ServiceId = "",
  [string]$ServiceHost = "",
  [hashtable]$Overrides = @{},
  [string[]]$ExtraKeys = @(),
  [switch]$SkipDeploy,
  [switch]$SkipHealthCheck
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$KeyFile = Join-Path $Root ".render-api-key"

$apiKey = $env:RENDER_API_KEY
if (-not $apiKey -and (Test-Path $KeyFile)) {
  $apiKey = (Get-Content $KeyFile -Raw).Trim()
}
if (-not $apiKey) {
  Write-Error "Missing Render API key (.render-api-key or RENDER_API_KEY)"
}
if (-not (Test-Path $EnvFile)) {
  Write-Error "Missing env file: $EnvFile"
}

$headers = @{
  Authorization  = "Bearer $apiKey"
  Accept         = "application/json"
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

$match = $null
if ($ServiceId) {
  $match = (Invoke-RenderApi -Method GET -Path "/services/$ServiceId")
}
if (-not $match) {
  $services = Invoke-RenderApi -Method GET -Path "/services?limit=100"
  $match = $services | ForEach-Object { $_.service } | Where-Object {
    $_.name -eq $ServiceName -or ($ServiceHost -and $_.serviceDetails.url -like "*$ServiceHost*")
  } | Select-Object -First 1
}
if (-not $match) {
  Write-Error "Could not find Render service '$ServiceName'"
}

$serviceId = $match.id
if (-not $ServiceHost) {
  $ServiceHost = ($match.serviceDetails.url -replace "^https?://", "").TrimEnd("/")
}

Write-Host "Target service: $($match.name) ($serviceId)"
Write-Host "URL: $($match.serviceDetails.url)"

$vars = @{}
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)=(.*)$') {
    $key = $Matches[1]
    $val = $Matches[2].Trim()
    if ($val -and $val -notmatch '^YOUR_|^<|^REPLACE_ME') {
      $vars[$key] = $val
    }
  }
}

foreach ($entry in $Overrides.GetEnumerator()) {
  $vars[$entry.Key] = [string]$entry.Value
}

$keysToPush = @(
  "NODE_ENV", "PORT", "TRUST_PROXY", "LOG_LEVEL",
  "DATABASE_URL", "REDIS_URL",
  "JWT_SECRET", "JWT_REFRESH_SECRET", "OTP_HASH_SECRET",
  "PII_ENCRYPTION_SECRET", "ADMIN_JWT_SECRET",
  "KYC_WEBHOOK_SECRET", "GOLD_RATE_WEBHOOK_SECRET",
  "PAYMENT_PROVIDER", "PAYMENT_PROVIDER_MODE",
  "RAZORPAY_KEY_ID", "RAZORPAY_KEY_SECRET", "RAZORPAY_WEBHOOK_SECRET",
  "SMS_PROVIDER_MODE", "MSG91_AUTH_KEY", "MSG91_OTP_TEMPLATE_ID",
  "KYC_PROVIDER_MODE", "KYC_PROVIDER_BASE_URL", "KYC_PROVIDER_API_KEY",
  "FIREBASE_MODE", "FIREBASE_PROJECT_ID", "FIREBASE_CLIENT_EMAIL", "FIREBASE_PRIVATE_KEY",
  "STORAGE_BACKEND", "S3_ENDPOINT", "S3_REGION", "S3_BUCKET",
  "S3_ACCESS_KEY_ID", "S3_SECRET_ACCESS_KEY", "S3_PUBLIC_BASE_URL", "S3_FORCE_PATH_STYLE",
  "PUBLIC_BASE_URL", "CORS_ALLOWED_ORIGINS", "ENABLE_DEMO_SEEDS", "WORKER_HEALTH_PORT",
  "MOOZHAYIL_STAGING_DATABASE_HOST", "MOOZHAYIL_STAGING_REDIS_HOST",
  "MOOZHAYIL_PRELAUNCH"
) + $ExtraKeys

Write-Host ""
Write-Host "Updating environment variables on Render..."
foreach ($key in ($keysToPush | Select-Object -Unique)) {
  if (-not $vars.ContainsKey($key)) { continue }
  Invoke-RenderApi -Method PUT -Path "/services/$serviceId/env-vars/$key" -Body @{ value = $vars[$key] } | Out-Null
  Write-Host "  updated $key"
}

if ($SkipDeploy) { return }

Write-Host ""
Write-Host "Triggering deploy..."
$deploy = Invoke-RenderApi -Method POST -Path "/services/$serviceId/deploys" -Body @{ clearCache = "do_not_clear" }
Write-Host "Deploy id: $($deploy.id)  status: $($deploy.status)"

if ($SkipHealthCheck) { return }

Write-Host "Waiting for health check (up to 3 min)..."
$healthUrl = "https://$ServiceHost/health"
for ($i = 0; $i -lt 18; $i++) {
  Start-Sleep -Seconds 10
  try {
    $health = Invoke-RestMethod -Uri $healthUrl -TimeoutSec 30
    if ($health.status -eq "ok") {
      Write-Host "Health OK - database: $($health.checks.database.status), redis: $($health.checks.redis.status)"
      return
    }
    Write-Host "  status: $($health.status) (retrying...)"
  } catch {
    Write-Host "  not ready yet ($($_.Exception.Message))"
  }
}

Write-Host "Deploy triggered but health not confirmed yet. Check Render dashboard logs."
