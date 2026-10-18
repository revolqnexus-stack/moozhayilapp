<#
.SYNOPSIS
  Creates (or reports) a CRM admin account in the production database.

.DESCRIPTION
  Reads DATABASE_URL from PRODUCTION_ENV.txt and runs apps/api scripts/seed-admin.ts.
  The password is prompted for interactively and never written to disk or history.

.EXAMPLE
  powershell -File scripts/create-prod-admin.ps1 -Email owner@moozhayil.com
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$Email,

  [string]$Name = "Moozhayil Owner",

  [ValidateSet("super_admin", "catalog_manager", "kyc_reviewer", "order_manager",
    "finance_manager", "support_agent", "auditor")]
  [string]$Role = "super_admin",

  # Generate a strong password and write it to CRM_ADMIN_CREDENTIALS.txt
  # instead of prompting interactively.
  [switch]$GeneratePassword,

  # Target the staging database instead of production.
  [switch]$Staging
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$cfg = Get-Content (Join-Path $Root "config/environments.json") -Raw | ConvertFrom-Json
$target = if ($Staging) { $cfg.staging } else { $cfg.production }

$EnvFile = Join-Path $Root $target.envFile
if (-not (Test-Path $EnvFile)) {
  Write-Error "Env file not found: $EnvFile"
}

$databaseUrl = $null
Get-Content $EnvFile | ForEach-Object {
  if ($_ -match '^\s*DATABASE_URL=(.*)$') { $databaseUrl = $Matches[1].Trim() }
}

if (-not $databaseUrl) {
  Write-Error "DATABASE_URL not found in $($target.envFile)"
}

$expectedHost = $target.neonDatabaseHost
if ($expectedHost -and $databaseUrl -notmatch [regex]::Escape($expectedHost)) {
  Write-Error "DATABASE_URL in $($target.envFile) does not point at the $($target.label) Neon host."
}

Write-Host ""
Write-Host "Creating admin account" -ForegroundColor Cyan
Write-Host "  Environment : $($target.label)"
Write-Host "  Email       : $Email"
Write-Host "  Role        : $Role"
Write-Host ""

$credentialsFile = Join-Path $Root "CRM_ADMIN_CREDENTIALS.txt"

if ($GeneratePassword) {
  $alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
  $bytes = New-Object byte[] 20
  [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  $plain = -join ($bytes | ForEach-Object { $alphabet[$_ % $alphabet.Length] })
  $plainConfirm = $plain
} else {
  $secure = Read-Host "Choose a password (min 8 chars, not echoed)" -AsSecureString
  $confirm = Read-Host "Confirm password" -AsSecureString

  $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
  $plainConfirm = [Runtime.InteropServices.Marshal]::PtrToStringBSTR(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm))
}

try {
  if ($plain -ne $plainConfirm) {
    Write-Error "Passwords do not match."
  }
  if ($plain.Length -lt 8) {
    Write-Error "Password must be at least 8 characters."
  }

  Push-Location (Join-Path $Root "apps/api")
  try {
    $env:DATABASE_URL = $databaseUrl
    $env:NODE_ENV = $target.nodeEnv
    $env:ADMIN_SEED_EMAIL = $Email
    $env:ADMIN_SEED_NAME = $Name
    $env:ADMIN_SEED_ROLE = $Role
    $env:ADMIN_SEED_PASSWORD = $plain
    $env:ADMIN_SEED_CONFIRM = "yes"

    npm run seed:admin
    if ($LASTEXITCODE -ne 0) {
      Write-Error "seed:admin failed with exit code $LASTEXITCODE"
    }

    if ($GeneratePassword) {
      @(
        "Moozhayil CRM admin credentials ($($target.label))",
        "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
        "",
        "Email    : $Email",
        "Password : $plain",
        "Role     : $Role",
        "",
        "Store this in a password manager and delete this file.",
        "This file is git-ignored - never commit it."
      ) | Set-Content -Path $credentialsFile -Encoding UTF8
      Write-Host "Password written to CRM_ADMIN_CREDENTIALS.txt" -ForegroundColor Yellow
    }
  } finally {
    Pop-Location
    Remove-Item Env:ADMIN_SEED_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:ADMIN_SEED_CONFIRM -ErrorAction SilentlyContinue
    Remove-Item Env:DATABASE_URL -ErrorAction SilentlyContinue
  }
} finally {
  $plain = $null
  $plainConfirm = $null
  [GC]::Collect()
}

Write-Host ""
Write-Host "Done. Sign in at the CRM with $Email" -ForegroundColor Green
