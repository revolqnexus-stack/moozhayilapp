# Deprecated alias — pushes STAGING env only. Use push-render-staging-env.ps1 or push-render-production-env.ps1.
Write-Warning "push-render-env.ps1 targets STAGING only. Prefer scripts/push-render-staging-env.ps1"
& (Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "push-render-staging-env.ps1")
