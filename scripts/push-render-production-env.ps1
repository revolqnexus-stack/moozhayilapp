# Push PRODUCTION env vars to Render production service (live providers only).
# Expected: deploy may fail until MSG91/Razorpay/R2/KYC live credentials are configured.
# Run: powershell -ExecutionPolicy Bypass -File scripts/push-render-production-env.ps1

param(
  [switch]$SkipDeploy,
  [switch]$SkipHealthCheck,
  [switch]$Prelaunch,
  # Prelaunch keeps payments/KYC mock but allows real MSG91 OTP when keys are set.
  [switch]$LiveSms,
  # Prelaunch + real Razorpay orders (test or live keys in PRODUCTION_ENV).
  [switch]$LivePayments,
  # Full production (NODE_ENV=production, live SMS/payments/Firebase) but mock KYC for APK launch.
  [switch]$ProductionExceptKyc
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

if ($ProductionExceptKyc -and $Prelaunch) {
  Write-Error "Use -ProductionExceptKyc OR -Prelaunch, not both."
}

$smsMode = "live"
$paymentMode = "live"
$kycMode = "live"
$nodeEnv = "production"
$prelaunchFlag = "false"
$allowMockKyc = "false"
$demoSeeds = "false"

if ($ProductionExceptKyc) {
  $kycMode = "mock"
  $allowMockKyc = "true"
} elseif ($Prelaunch) {
  $nodeEnv = "staging"
  $prelaunchFlag = "true"
  $demoSeeds = "true"
  $kycMode = "mock"
  if (-not $LiveSms) { $smsMode = "mock" }
  if (-not $LivePayments) { $paymentMode = "mock" }
}

$dltPath = Join-Path $Root "config/dlt-production.json"
$dltCfg = $null
if (Test-Path $dltPath) {
  $dltCfg = Get-Content $dltPath -Raw | ConvertFrom-Json
}

if ($ProductionExceptKyc -or $LiveSms) {
  if (-not $prodVars["MSG91_AUTH_KEY"] -or $prodVars["MSG91_AUTH_KEY"].Length -lt 8) {
    Write-Error "Live SMS requires MSG91_AUTH_KEY in PRODUCTION_ENV.txt."
  }
  if (-not $prodVars["MSG91_OTP_TEMPLATE_ID"] -and -not $dltCfg.msg91OtpTemplateId) {
    Write-Error "Live SMS requires MSG91_OTP_TEMPLATE_ID in PRODUCTION_ENV.txt or config/dlt-production.json."
  }
  $peCheck = if ($prodVars["MSG91_DLT_PE_ID"]) { $prodVars["MSG91_DLT_PE_ID"] } elseif ($dltCfg) { $dltCfg.peId } else { "" }
  if ($peCheck -eq "1016720216615695729") {
    Write-Error "MSG91_DLT_PE_ID is Brand DLT ID; use Principal Entity peId $($dltCfg.peId) from config/dlt-production.json (and MSG91 sender PE field)."
  }
}

if ($ProductionExceptKyc -or $LivePayments) {
  if (-not $prodVars["RAZORPAY_KEY_ID"] -or -not $prodVars["RAZORPAY_KEY_SECRET"]) {
    Write-Error "Live payments require RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET in PRODUCTION_ENV.txt"
  }
}

$overrides = @{
  NODE_ENV                         = $nodeEnv
  TRUST_PROXY                      = "true"
  SMS_PROVIDER_MODE                = $smsMode
  KYC_PROVIDER_MODE                = $kycMode
  PAYMENT_PROVIDER_MODE            = $paymentMode
  FIREBASE_MODE                    = "live"
  STORAGE_BACKEND                  = "s3"
  ENABLE_DEMO_SEEDS                = $demoSeeds
  MOOZHAYIL_STAGING_DATABASE_HOST  = $stagingHost
  MOOZHAYIL_STAGING_REDIS_HOST     = $stagingRedis
  MOOZHAYIL_PRELAUNCH              = $prelaunchFlag
  MOOZHAYIL_ALLOW_MOCK_KYC         = $allowMockKyc
}

if ($ServiceHost) {
  $overrides["PUBLIC_BASE_URL"] = "https://$ServiceHost"
  $corsOrigins = @("https://$ServiceHost")
  if ($cfg.production.adminCrmOrigin) {
    $corsOrigins += $cfg.production.adminCrmOrigin.TrimEnd("/")
  }
  $overrides["CORS_ALLOWED_ORIGINS"] = ($corsOrigins -join ",")
}

if ($dltCfg) {
  $overrides["MSG91_DLT_PE_ID"] = [string]$dltCfg.peId
  $overrides["MSG91_DLT_TE_ID"] = [string]$dltCfg.airtelDltTemplateId
  if ($dltCfg.msg91OtpTemplateId) {
    $overrides["MSG91_OTP_TEMPLATE_ID"] = [string]$dltCfg.msg91OtpTemplateId
  }
  if ($dltCfg.header) {
    $overrides["MSG91_SENDER_ID"] = [string]$dltCfg.header
  }
  Write-Host "DLT overrides from config/dlt-production.json: PE=$($dltCfg.peId) TE=$($dltCfg.airtelDltTemplateId)"
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
if ($ProductionExceptKyc) {
  Write-Host "Production (except KYC) pushed - NODE_ENV=production, live OTP/Razorpay/Firebase, mock KYC for APK."
} elseif ($Prelaunch -and $LiveSms -and $LivePayments) {
  Write-Host "Prelaunch + LiveSms + LivePayments pushed - real OTP and Razorpay; KYC still mock."
} elseif ($Prelaunch -and $LiveSms) {
  Write-Host "Prelaunch + LiveSms pushed - real OTP via MSG91; payments/KYC still mock."
} elseif ($Prelaunch -and $LivePayments) {
  Write-Host "Prelaunch + LivePayments pushed - Razorpay live; SMS/KYC still mock unless -LiveSms."
} elseif ($Prelaunch) {
  Write-Host "Prelaunch mode pushed - prod infra with mock providers so legal pages boot for Razorpay verification."
} else {
  Write-Host "Production env pushed. Service will refuse to start until live provider credentials pass production guards."
}
