# Security Remediation — Secret Exposure

This document tracks the secret inventory and rotation status after the Phase 1 audit.
**Never paste actual secret values into this file or any committed file.**

## Exposed credential categories (treat as compromised)

| Service | What was exposed | Rotation status |
|---------|------------------|-----------------|
| **Neon PostgreSQL** | Connection URL / password in tracked env files and docs | **Manual** — reset password in Neon console, update Render + local `PRODUCTION_ENV.txt` |
| **Upstash Redis** | Connection token in tracked env files | **Manual** — rotate token in Upstash console, update Render + local env |
| **JWT / session** | `JWT_SECRET`, `JWT_REFRESH_SECRET`, `ADMIN_JWT_SECRET` | **Rotated** on Render staging via `scripts/rotate-staging-secrets.mjs` |
| **OTP hashing** | `OTP_HASH_SECRET` | **Rotated** on Render staging |
| **PII encryption** | `PII_ENCRYPTION_SECRET` | **Preserved** — rotating breaks existing encrypted PII; plan migration before rotating |
| **Webhook HMAC** | `KYC_WEBHOOK_SECRET`, `GOLD_RATE_WEBHOOK_SECRET` | **Rotated** on Render staging |
| **Razorpay** | Test key ID + **secret** in docs and `RAILWAY_ENV_VARIABLES.txt` | **Manual** — regenerate test secret in Razorpay dashboard; use live keys only in production |
| **Firebase Admin** | Service account private key in tracked `PRODUCTION_ENV.txt` | **Rotated** — new key generated; delete old keys in Firebase Console → IAM |
| **Railway (legacy)** | Internal Postgres/Redis URLs in `RAILWAY_ENV_VARIABLES.txt` | **N/A if unused** — file removed from Git tracking |
| **Render API** | `.render-api-key` (local only, gitignored) | Rotate in Render dashboard if ever committed |

## Repository changes

- `PRODUCTION_ENV.txt`, `RAILWAY_ENV_VARIABLES.txt` — removed from Git index; use `*.example.txt` templates
- Documentation redacted — no real JWT/DB/Razorpay secrets in committed `.md` files
- `.gitignore` hardened — `apps/api/.env.cloud`, keystore files, firebase service account JSON
- `seed-admin-production.js` — no hardcoded DB URL or default password

## Git history scrub (required)

Secrets remain in old commits until history is rewritten:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/scrub-git-history.ps1
git push origin main --force-with-lease
```

All collaborators must re-clone or hard-reset after the force push.

## Staging impact when rotating

| Secret | Staging impact |
|--------|----------------|
| JWT secrets | All users logged out |
| OTP hash secret | In-flight OTP verifications fail |
| Firebase key | Push continues after redeploy |
| PII encryption | **Do not rotate** without data migration |
| Neon password | API down until Render env updated |
| Redis token | Brief queue/rate-limit disconnect |

## Safe local files (never commit)

- `PRODUCTION_ENV.txt`
- `apps/api/.env.cloud`
- `.render-api-key`
- `apps/api/firebase-service-account.json`
- `apps/mobile/android/key.properties`
- `*.jks` / upload keystore
