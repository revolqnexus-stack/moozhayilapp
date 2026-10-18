# Cloud stack — Neon + Upstash + Render + Emulator

Everything is wired to use the same backend.

## Live status

| Service | Role | URL / host |
|---------|------|------------|
| **Render** | API hosting | `https://moozhayilapp-fyz6.onrender.com` |
| **Neon** | PostgreSQL | Connected (health check ~100ms) |
| **Upstash** | Redis / jobs | Connected (health check ~230ms) |
| **Android emulator** | Mobile app | Uses Render API in debug mode |
| **Admin CRM** | Operator UI | `VITE_API_BASE` → Render |

Verify anytime:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-cloud-stack.ps1
powershell -ExecutionPolicy Bypass -File scripts/test-cloud-credentials.ps1
```

**After rotating Upstash token:** update `REDIS_URL` in Render dashboard (Environment tab) and re-run `scripts/sync-cloud-env.ps1` locally.

## Run the Android emulator (uses Render → Neon + Upstash)

```powershell
powershell -ExecutionPolicy Bypass -File scripts/run-android-emulator.ps1
```

Or manually:

```powershell
cd apps/mobile
flutter run --dart-define=API_BASE_URL=https://moozhayilapp-fyz6.onrender.com/v1 --dart-define=PUSH_ENABLED=false
```

Debug builds default to Render automatically (`apps/mobile/lib/core/config/api_config.dart`).

**Mock OTP in staging:** check Render logs for SMS mock output, or use documented test OTP flows in `RUN-MOBILE-APP.md`.

## Run local API against Neon + Upstash (optional)

Useful when debugging API code without redeploying to Render.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/sync-cloud-env.ps1
cd apps/api
npm run dev:cloud
```

Then point the emulator at your machine:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3080/v1 --dart-define=PUSH_ENABLED=false
```

## Run admin CRM

```powershell
cd apps/admin
npm run dev
```

Opens at `http://localhost:5180` and talks to Render (`apps/admin/.env`).

## One-shot helper

```powershell
# Verify only
powershell -File scripts/connect-cloud-stack.ps1

# Verify + start local API + admin in new windows
powershell -File scripts/connect-cloud-stack.ps1 -All

# Verify + launch emulator
powershell -File scripts/connect-cloud-stack.ps1 -Emulator
```

## Config reference

Public URLs (no secrets): `config/cloud-stack.json`  
Secrets template: `PRODUCTION_ENV.txt` → generates `apps/api/.env.cloud` (gitignored)
