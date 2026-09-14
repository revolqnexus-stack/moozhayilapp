# ✅ Deployment Checklist

## 📋 Pre-Deployment (You're Here!)

- [x] Neon PostgreSQL created
- [x] Upstash Redis created
- [x] Cloudflare account ready
- [x] GitHub repo pushed
- [x] Secrets generated
- [ ] Cloudflare R2 bucket created
- [ ] R2 API keys obtained

## 🚀 Deployment Steps

### 1. Cloudflare R2 (5 mins)
- [ ] Go to: https://dash.cloudflare.com/28247e5c8e5aca83c94a869bdfbd0b6d
- [ ] Create bucket: `moozhayil-media`
- [ ] Generate R2 API token
- [ ] Save Access Key ID & Secret

### 2. Render.com Setup (2 mins)
- [ ] Sign up: https://render.com
- [ ] Connect GitHub account
- [ ] Authorize repo access

### 3. Deploy API (10 mins)
- [ ] Create new Web Service
- [ ] Select `revolqnexus-stack/moozhayilapp` repo
- [ ] Configure:
  - Root: `apps/api`
  - Build: `npm ci && npm run build && npx prisma generate`
  - Start: `npm run start:prod`
- [ ] Add all environment variables (see PRODUCTION_ENV.txt)
- [ ] Deploy!

### 4. Database Setup (5 mins)
- [ ] Wait for deployment to finish
- [ ] Open Shell in Render
- [ ] Run: `npm run migrate:deploy`
- [ ] Run: `npm run seed:admin`
- [ ] Verify: Check health endpoint

### 5. Test (5 mins)
- [ ] Visit: `https://moozhayil-api.onrender.com/health`
- [ ] Should return: `{"status":"ok"}`
- [ ] Test login with admin credentials

### 6. Razorpay (5 mins)
- [ ] Login to Razorpay dashboard
- [ ] Get test keys (for now)
- [ ] Update Render environment variables
- [ ] Test payment creation

### 7. Flutter App (10 mins)
- [ ] Update API_BASE_URL to Render URL
- [ ] Test locally first
- [ ] Build release:
  - Android: `flutter build appbundle --release`
  - iOS: `flutter build ipa --release`

## 📱 App Store Submission

### Android (Google Play)
- [ ] Build signed AAB
- [ ] Create Play Console account ($25 one-time)
- [ ] Upload APK
- [ ] Fill store listing
- [ ] Submit for review

### iOS (App Store)
- [ ] Build signed IPA
- [ ] Create Apple Developer account ($99/year)
- [ ] Upload via Transporter
- [ ] Fill App Store Connect
- [ ] Submit for review

## 🔐 Production Hardening

- [ ] Get Razorpay LIVE keys
- [ ] Set up Razorpay webhooks
- [ ] Enable SMS provider (MSG91)
- [ ] Enable KYC provider
- [ ] Set up Firebase push notifications
- [ ] Configure custom domain (optional)
- [ ] Set up monitoring (Sentry)
- [ ] Enable database backups
- [ ] Test entire payment flow

## 📊 Current Status

**Infrastructure:** ✅ Ready
**API Deployment:** 🟡 Pending
**Flutter Apps:** 🟡 Pending
**App Stores:** ⚪ Not Started

---

## 🎯 Next Action

**RIGHT NOW:** Follow `DEPLOY_TO_RENDER.md` step by step

**Time Estimate:** 30-45 minutes total

**Cost:** $7/month (Render only, everything else FREE)
