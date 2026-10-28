# StampMitra PAN verification

StampMitra checks run **server-side only** via `apps/api/src/modules/kyc/stampmitra.client.ts`.

| App route | StampMitra endpoint | Scope |
|-----------|---------------------|--------|
| `POST /v1/kyc/pan/verify` | `POST /v1/verify/pan` | `verification.pan.read` |
| `POST /v1/kyc/bank-account/verify` | `POST /v1/verify/bank-account` | `verification.bank-account.read` |

## Prove sandbox usage (needed before they issue `sk_live_`)

Production is mock KYC and **will not** call StampMitra. Send sandbox traffic from your laptop:

1. Put `STAMPMITRA_API_KEY=sk_test_...` in `apps/api/.env.local` (gitignored). Never in the Flutter app.
2. From the repo root:

```bash
node scripts/stampmitra-sandbox-ping.mjs
node scripts/stampmitra-sandbox-ping.mjs --pan ABCDE1234F --name "TEST USER"
```

3. A 200, 400, or 422 still counts as a received request. Screenshot the printed `requestId` for StampMitra.
4. Use their documented sandbox PAN if they gave you one. Do not use a real customer PAN.

## Local sandbox (full app flow)

1. Copy `STAMPMITRA_API_KEY=sk_test_xxx` from `.env.example`.
2. Put your sandbox key in `apps/api/.env.local` (gitignored).
3. Set `KYC_PROVIDER_MODE=live` in `.env` or `.env.local` (Aadhaar/selfie can stay mock until those vendors are wired).
4. From `apps/api`: `npm run dev` — startup fails fast if live KYC is on but `STAMPMITRA_API_KEY` is missing.
5. Complete PAN and bank steps in Profile → KYC (bank is optional — skip goes to selfie).

## Production

1. Complete StampMitra KYB and obtain `sk_live_…`.
2. Set `STAMPMITRA_API_KEY` on Render (or your host) — never in the Flutter app.
3. Keep `KYC_PROVIDER_MODE=live` and ensure wallet balance is topped up (402 surfaces as an ops alert in API logs via `requestId`).
4. Optional: IP allowlisting in the StampMitra dashboard for your API egress IP.

## Tests

```bash
cd apps/api
npm test -- stampmitra.client.test.ts
```

Integration KYC tests still use `KYC_PROVIDER_MODE=mock` and do not call StampMitra.
