# Push STAGING env vars to Render staging service (mock providers, staging Neon/Redis).
# Run: powershell -ExecutionPolicy Bypass -File scripts/push-render-staging-env.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EnvConfig = Join-Path $Root "config/environments.json"
$cfg = Get-Content $EnvConfig -Raw | ConvertFrom-Json

$ServiceName = $cfg.staging.renderServiceName
$ServiceId = $cfg.staging.renderServiceId
$ServiceHost = ($cfg.staging.apiBase -replace "^https?://", "").TrimEnd("/")
$EnvFile = Join-Path $Root $cfg.staging.envFile

$overrides = @{
  NODE_ENV              = "staging"
  TRUST_PROXY           = "true"
  PUBLIC_BASE_URL       = "https://$ServiceHost"
  SMS_PROVIDER_MODE     = "mock"
  KYC_PROVIDER_MODE     = "mock"
  PAYMENT_PROVIDER_MODE = "mock"
  STORAGE_BACKEND       = "local"
  ENABLE_DEMO_SEEDS     = "true"
  CORS_ALLOWED_ORIGINS  = "http://localhost:5180,http://localhost:5173,https://$ServiceHost"
}

# Firebase stays live on staging when credentials exist.
$stagingVars = @{}
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_][A-Z0-9_]*)=(.*)$') {
    $stagingVars[$Matches[1]] = $Matches[2].Trim()
  }
}
if ($stagingVars["FIREBASE_PROJECT_ID"] -and $stagingVars["FIREBASE_CLIENT_EMAIL"] -and $stagingVars["FIREBASE_PRIVATE_KEY"]) {
  $overrides["FIREBASE_MODE"] = "live"
} else {
  $overrides["FIREBASE_MODE"] = "mock"
}

& (Join-Path $Root "scripts/push-render-env-core.ps1") `
  -EnvFile $EnvFile `
  -ServiceName $ServiceName `
  -ServiceId $ServiceId `
  -ServiceHost $ServiceHost `
  -Overrides $overrides
