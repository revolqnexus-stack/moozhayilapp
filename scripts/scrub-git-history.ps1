# Remove secret-bearing files from entire Git history.
# WARNING: Rewrites history — coordinate with all collaborators before force-pushing.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts/scrub-git-history.ps1
#   powershell -ExecutionPolicy Bypass -File scripts/scrub-git-history.ps1 -Force
#   git push origin main --force-with-lease

param([switch]$Force)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$paths = @(
  "PRODUCTION_ENV.txt",
  "RAILWAY_ENV_VARIABLES.txt",
  "railway-secrets.txt",
  ".secrets-generated.txt"
)

Write-Host "This will rewrite Git history to remove secret files:"
$paths | ForEach-Object { Write-Host "  - $_" }
Write-Host ""

if (-not $Force) {
  Write-Host "Press Ctrl+C to abort, or Enter to continue..."
  Read-Host | Out-Null
}

foreach ($p in $paths) {
  git filter-branch --force --index-filter "git rm --cached --ignore-unmatch $p" --prune-empty HEAD
  if ($LASTEXITCODE -ne 0) {
    Write-Error "filter-branch failed for $p"
  }
}

Write-Host ""
Write-Host "History scrub complete. Next steps:"
Write-Host "  1. git push origin main --force-with-lease"
Write-Host "  2. Ask collaborators to re-clone or reset to the new main"
Write-Host "  3. Rotate any secrets that were ever in history (see SECURITY_REMEDIATION.md)"
