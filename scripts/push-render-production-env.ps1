# Push PRODUCTION env vars to Render production service (live providers only).
# Expected: deploy may fail until MSG91/Razorpay/R2/KYC live credentials are configured.
# Run: powershell -ExecutionPolicy Bypass -File scripts/push-render-production-env.ps1

param(
  [switch]$SkipDeploy,
  [switch]$SkipHealthCheck,
  [switch]$Prelaunch
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvConfig = Join-Path $Root "config/environments.json"
$cfg = Get-Content $EnvConfig -Raw | ConvertFrom-Json

if (-not $cfg.production.renderServiceId) {
  Write-Error "Production Render service not created yet. Run: node scripts/create-production-render-service.mjs"
}

$ServiceName = $cfg.production.renderServiceName
$ServiceId = $cfg.production.renderServiceId
$ServiceHost = if ($cfg.production.apiBase) {
  ($cfg.production.apiBase -replace "^https?://", "").TrimEnd("/")
} else { "" }
$EnvFile = Join-Path $Root $cfg.production.envFile

$stagingHost = $cfg.staging.neonDatabaseHost
$stagingRedis = $cfg.staging.redisHost

$prodVars = @{}
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)=(.*)$') {
    $prodVars[$Matches[1]] = $Matches[2].Trim()
  }
}

if ($stagingHost -and $prodVars["DATABASE_URL"] -match "@$([regex]::Escape($stagingHost))") {
  Write-Error "PRODUCTION_ENV DATABASE_URL still points at staging Neon host ($stagingHost)"
}
if ($stagingRedis -and $prodVars["REDIS_URL"] -match "@$([regex]::Escape($stagingRedis))") {
  Write-Error "PRODUCTION_ENV REDIS_URL still points at staging Redis host ($stagingRedis)"
}

$overrides = @{
  NODE_ENV                         = if ($Prelaunch) { "staging" } else { "production" }
  TRUST_PROXY                      = "true"
  SMS_PROVIDER_MODE                = if ($Prelaunch) { "mock" } else { "live" }
  KYC_PROVIDER_MODE                = if ($Prelaunch) { "mock" } else { "live" }
  PAYMENT_PROVIDER_MODE            = if ($Prelaunch) { "mock" } else { "live" }
  FIREBASE_MODE                    = "live"
  STORAGE_BACKEND                  = "s3"
  ENABLE_DEMO_SEEDS                = if ($Prelaunch) { "true" } else { "false" }
  MOOZHAYIL_STAGING_DATABASE_HOST  = $stagingHost
  MOOZHAYIL_STAGING_REDIS_HOST     = $stagingRedis
  MOOZHAYIL_PRELAUNCH              = if ($Prelaunch) { "true" } else { "false" }
}

if ($ServiceHost) {
  $overrides["PUBLIC_BASE_URL"] = "https://$ServiceHost"
  $overrides["CORS_ALLOWED_ORIGINS"] = "https://$ServiceHost"
}

$params = @{
  EnvFile          = $EnvFile
  ServiceName      = $ServiceName
  ServiceId        = $ServiceId
  ServiceHost      = $ServiceHost
  Overrides        = $overrides
  SkipHealthCheck  = $true
}
if ($SkipDeploy) { $params["SkipDeploy"] = $true }

& (Join-Path $Root "scripts/push-render-env-core.ps1") @params

Write-Host ""
if ($Prelaunch) {
  Write-Host "Prelaunch mode pushed — prod infra with mock providers so legal pages boot for Razorpay verification."
} else {
  Write-Host "Production env pushed. Service will refuse to start until live provider credentials pass production guards."
}
