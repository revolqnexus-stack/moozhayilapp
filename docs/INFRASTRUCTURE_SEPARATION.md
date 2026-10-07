# Staging / Production Infrastructure Separation

## Architecture

| Layer | Staging | Production |
|-------|---------|------------|
| Render service | `moozhayilapp` | `moozhayilapp-prod` |
| Neon branch | `production` (default) | `moozhayil-prod` |
| Upstash Redis | `crack-duck-150612` (staging) | `moozhayil-prod` (dedicated) |
| Env file | `STAGING_ENV.txt` | `PRODUCTION_ENV.txt` |
| Provider modes | mock SMS/KYC/payments OK | live only — startup fails otherwise |

## Scripts

```powershell
# 1. Wire Neon branch URLs into env files
node scripts/setup-step2-infrastructure.mjs

# 2. Apply schema to production Neon branch
node scripts/run-prod-migrations.mjs

# 3. Generate production-only JWT/webhook secrets
node scripts/generate-production-secrets.mjs

# 4. Create production Upstash Redis (requires .upstash-credentials.json)
node scripts/create-production-redis.mjs

# 4b. Cloudflare R2 (bucket + public URL via setup; S3 keys via dashboard or wire script)
node scripts/setup-production-r2.mjs
# If API token creation is blocked, create R2 API token in Cloudflare dashboard then:
# S3_ACCESS_KEY_ID=... S3_SECRET_ACCESS_KEY=... node scripts/wire-production-r2.mjs

# 5. Create production Render service
node scripts/create-production-render-service.mjs

# 6. Push env (staging untouched unless you run staging script)
powershell -File scripts/push-render-staging-env.ps1
powershell -File scripts/push-render-production-env.ps1
```

## Production startup guards (`apps/api/src/config/env.ts`)

Production refuses to start when:

- Any provider mode is `mock`
- Razorpay test keys or placeholder credentials are present
- `STORAGE_BACKEND` is not `s3`
- `DATABASE_URL` or `REDIS_URL` host matches `MOOZHAYIL_STAGING_*` env vars
- Live provider credentials are missing

Production deploy is expected to fail until MSG91, Razorpay live, R2, and KYC credentials are configured.

India SMS (MSG91): set `MSG91_DLT_PE_ID` and `MSG91_DLT_TE_ID` from `config/dlt-production.json` (Principal Entity `1001435730734881903`, not Brand DLT `1016720216615695729`). `push-render-production-env.ps1` applies DLT overrides from that file on every push.

## Staging preservation

- Staging Render service env is only updated via `push-render-staging-env.ps1`
- `STAGING_ENV.txt` keeps staging Neon endpoint and Redis
- Staging health: `https://moozhayilapp-fyz6.onrender.com/health`
