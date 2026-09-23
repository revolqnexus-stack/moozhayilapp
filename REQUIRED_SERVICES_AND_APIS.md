# 🔑 Required Services & APIs - Complete List

Quick reference for every external service the app needs.

---

## 🎯 WHAT YOU HAVE vs WHAT YOU NEED

### ✅ Already Have:
- **Razorpay Test Keys**: obtain from Razorpay dashboard (never commit secrets)
- **Complete Codebase**: 95% feature-complete
- **Deployment Configs**: Railway + Vercel ready

### ⚠️ Need to Get:
- Razorpay **LIVE** keys (upgrade from test)
- MSG91 account (SMS OTP)
- Firebase project (push notifications)
- KYC provider account (Signzy/IDfy)
- AWS S3 or Cloudflare R2 (file storage)

---

## 📊 ALL SERVICES BREAKDOWN

| Service | Purpose | Required When | Cost | Provider |
|---------|---------|---------------|------|----------|
| **PostgreSQL** | Main database | Immediately | Railway auto-provisions | Railway |
| **Redis** | Cache + job queue | Immediately | Railway auto-provisions | Railway |
| **Razorpay** | Payments | Immediately | 2% per transaction | razorpay.com |
| **MSG91** | SMS OTP | Before customer login | ~₹0.15-0.20/SMS | msg91.com |
| **Firebase** | Push notifications | Before mobile app release | Free tier sufficient | firebase.google.com |
| **KYC Provider** | Aadhaar/PAN verification | Before customer KYC | ₹10-20/verification | signzy.com or idfy.com |
| **AWS S3** | Product images, KYC docs | After 50+ products | ~₹500/month | aws.amazon.com |
| **Sentry** | Error monitoring (optional) | Production | Free tier available | sentry.io |

---

## 1️⃣ RAZORPAY (Payments)

### What You Need:
1. **LIVE API Keys** (not test keys)
2. Webhook secret

### Where to Get:
1. Go to https://dashboard.razorpay.com
2. Complete **KYC verification** (required for LIVE mode)
   - Business documents
   - Bank account details
   - Takes 1-2 business days
3. Settings → API Keys → **Generate Live Keys**
4. Copy:
   - **Key ID**: `rzp_live_XXXXXXXXXXXXX`
   - **Key Secret**: `XXXXXXXXXXXXXXXXX`

### Configure in Railway:
```bash
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_live_YOUR_KEY
RAZORPAY_KEY_SECRET=YOUR_SECRET
RAZORPAY_WEBHOOK_SECRET=<generate with: openssl rand -base64 32>
```

### Set Up Webhook:
1. Razorpay Dashboard → Settings → Webhooks
2. Webhook URL:
```
https://your-api.railway.app/v1/webhooks/payment
```
3. Secret: (paste your `RAZORPAY_WEBHOOK_SECRET`)
4. Events:
   - ✅ `payment.captured`
   - ✅ `payment.failed`
   - ✅ `refund.processed`

### Cost:
- 2% per transaction (standard)
- No monthly fee
- Instant settlement available

---

## 2️⃣ MSG91 (SMS OTP)

### What You Need:
1. AUTH KEY (API key)
2. DLT Template ID (for OTP message)

### Where to Get:
1. Sign up at https://msg91.com
2. Complete **DLT Registration** (mandatory in India)
   - Register your business
   - Get DLT template approved for OTP message
   - Takes 2-3 business days

### Recommended OTP Template:
```
Your OTP for Moozhayil Gold & Diamonds is ##OTP##. Valid for 10 minutes. Do not share with anyone. - MOOZHAYIL
```

### Configure in Railway:
```bash
SMS_PROVIDER_MODE=live
MSG91_AUTH_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
MSG91_OTP_TEMPLATE_ID=XXXXXXXXXXXXXXXXXXXXXXXX
```

### Cost:
- ₹0.15-0.20 per SMS (depends on plan)
- Minimum recharge: ₹500
- Pay as you go

### Current Mock Behavior:
- OTPs logged to Railway logs
- All OTPs are `123456` in mock mode
- Check Railway logs for actual OTP in staging

---

## 3️⃣ FIREBASE (Push Notifications)

### What You Need:
1. Project ID
2. Service Account JSON (for backend)
3. FCM config (for mobile app)

### Where to Get:
1. Go to https://console.firebase.google.com
2. Create new project: "Moozhayil Production"
3. Add Android app:
   - Package name: `com.moozhayil.app` (check `AndroidManifest.xml`)
   - Download `google-services.json`
4. Get service account:
   - Project Settings → Service Accounts
   - Generate new private key
   - Download JSON file

### Configure in Railway (Backend):
```bash
FIREBASE_MODE=live
FIREBASE_PROJECT_ID=moozhayil-production
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@moozhayil-production.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nXXXXX\n-----END PRIVATE KEY-----
```

### Configure in Mobile App:
Place `google-services.json` at:
```
apps/mobile/android/app/google-services.json
```

Or use dart-defines (already supported):
```bash
flutter build apk --release \
  --dart-define=FIREBASE_PROJECT_ID=moozhayil-production \
  --dart-define=FIREBASE_API_KEY=XXXX \
  --dart-define=FIREBASE_APP_ID=1:XXXX:android:XXXX \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=XXXX \
  --dart-define=PUSH_ENABLED=true
```

### Cost:
- **FREE** up to 1M messages/month
- You'll likely stay in free tier

### Current Mock Behavior:
- No push notifications sent
- Notifications stored in database only
- Users see in-app notification list

---

## 4️⃣ KYC PROVIDER (Aadhaar/PAN Verification)

### Recommended Providers:
1. **Signzy** (signzy.com) - Most popular
2. **IDfy** (idfy.com) - Good alternative
3. **Karza** (karza.in) - Enterprise option

### What You Need:
1. API Base URL
2. API Key / Bearer Token
3. Webhook secret (optional)

### Configure in Railway:
```bash
KYC_PROVIDER_MODE=live
KYC_PROVIDER_BASE_URL=https://api.signzy.tech/v2
KYC_PROVIDER_API_KEY=YOUR_API_KEY
KYC_WEBHOOK_SECRET=<generate with: openssl rand -base64 32>
```

### API Endpoints Required:
Your provider must support (or you must proxy):
1. **Aadhaar OTP Send**: `POST /aadhaar/send-otp`
2. **Aadhaar OTP Verify**: `POST /aadhaar/verify-otp`
3. **PAN Verify**: `POST /pan/verify`
4. **Selfie Liveness**: `POST /selfie/verify`

### Cost:
- ₹10-20 per verification
- Pay as you go
- Minimum recharge: ₹5,000

### Current Mock Behavior:
- All KYC verifications auto-approve
- Admin still manually reviews
- No external API calls

---

## 5️⃣ AWS S3 (File Storage)

### What You Need:
1. S3 Bucket
2. IAM Access Keys
3. CloudFront distribution (optional but recommended)

### Where to Get:
1. Sign up at https://aws.amazon.com
2. Create S3 bucket:
   - Name: `moozhayil-media-production`
   - Region: `ap-south-1` (Mumbai)
   - Block public access: OFF (for product images)
3. Create IAM user:
   - Permissions: `s3:PutObject`, `s3:GetObject`, `s3:DeleteObject`
   - Generate access keys
4. Optional: Create CloudFront distribution
   - Origin: Your S3 bucket
   - Cache policy: CachingOptimized

### Configure in Railway:
```bash
STORAGE_BACKEND=s3
S3_BUCKET=moozhayil-media-production
S3_REGION=ap-south-1
S3_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXX
S3_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
S3_PUBLIC_BASE_URL=https://d1234567890.cloudfront.net
# S3_ENDPOINT - leave empty for AWS
# S3_FORCE_PATH_STYLE=false
```

### Cost:
- Storage: ~₹2/GB/month
- Transfer: ~₹6/GB (first 10TB/month)
- Estimated: ₹500-1000/month for 50GB + traffic

### Alternative: Cloudflare R2
- Cheaper than S3
- No egress fees
- Similar API
- https://cloudflare.com/products/r2

### Current Mock Behavior:
- Files saved to Railway container at `/app/uploads`
- **Files lost on redeploy!**
- Fine for staging, not for production

---

## 6️⃣ OPTIONAL: SENTRY (Error Monitoring)

### What You Need:
1. DSN (Data Source Name)

### Where to Get:
1. Sign up at https://sentry.io
2. Create project: "Moozhayil API"
3. Copy DSN from settings

### Configure in Railway:
```bash
SENTRY_DSN=https://xxxxx@xxxxx.ingest.sentry.io/xxxxx
SENTRY_ENVIRONMENT=production
```

### Cost:
- **FREE** up to 5,000 events/month
- Pro: $26/month for 50k events

### Current Status:
- Sentry middleware already wired in code
- Just needs DSN to activate

---

## 🔐 SECURITY SECRETS TO GENERATE

Run this 5 times:
```bash
openssl rand -base64 32
```

Use outputs for:
1. `JWT_SECRET`
2. `JWT_REFRESH_SECRET`
3. `OTP_HASH_SECRET`
4. `PII_ENCRYPTION_SECRET`
5. `ADMIN_JWT_SECRET`

Also generate:
```bash
openssl rand -base64 32  # RAZORPAY_WEBHOOK_SECRET
openssl rand -base64 32  # KYC_WEBHOOK_SECRET (if needed)
openssl rand -base64 32  # GOLD_RATE_WEBHOOK_SECRET (if needed)
```

---

## 📱 MOBILE APP CONFIGURATION

### Required Before Play Store Release:
1. **Firebase** (push notifications)
2. **API URL** (Railway public URL)
3. **Release signing keys** (Android keystore)

### Build Command:
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://your-api.railway.app/v1 \
  --dart-define=PUSH_ENABLED=true \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=FIREBASE_PROJECT_ID=moozhayil-production \
  --dart-define=FIREBASE_API_KEY=XXXX \
  --dart-define=FIREBASE_APP_ID=1:XXXX:android:XXXX \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=XXXX
```

### Signing:
1. Generate keystore:
```bash
keytool -genkey -v -keystore moozhayil-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias moozhayil
```

2. Create `apps/mobile/android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=moozhayil
storeFile=../../moozhayil-release.jks
```

3. **NEVER commit keystore or key.properties to Git!**

---

## 🎯 DEPLOYMENT PRIORITY

### Phase 1: Deploy Now (Mock Services OK)
1. ✅ Railway (API + Worker + DB + Redis)
2. ✅ Vercel (Admin)
3. ⚠️ Razorpay **LIVE** keys

### Phase 2: Before Customer Testing
4. ✅ MSG91 (SMS OTP)
5. ✅ KYC Provider (Aadhaar/PAN)

### Phase 3: Before Mobile Release
6. ✅ Firebase (Push)
7. ✅ AWS S3 (Storage)

### Phase 4: Optional
8. 🔧 Sentry (Monitoring)
9. 🔧 CloudFront (CDN)

---

## 📊 TOTAL ESTIMATED MONTHLY COSTS

### Staging (Mock Services):
- Railway: $5/month
- Vercel: Free
- **Total: $5/month**

### Production (Real Traffic, 1000 orders/month):
- Railway: $20-50/month
- Vercel: Free
- Razorpay: 2% of GMV (₹2000 on ₹1L GMV)
- MSG91: ₹500-2000/month
- AWS S3: ₹500/month
- Firebase: Free
- KYC: ₹10-20/verification = ₹10k-20k for 1000 verifications
- **Total: ~₹15,000-25,000/month (~$180-300)**

Most cost is variable (KYC, Razorpay fees) based on transaction volume.

---

## ✅ QUICK CHECKLIST

Before going live:
- [ ] Razorpay LIVE keys configured
- [ ] Razorpay webhook set up
- [ ] MSG91 account + DLT template
- [ ] Firebase project created
- [ ] KYC provider account
- [ ] AWS S3 bucket created
- [ ] All security secrets generated
- [ ] CloudFront set up (optional)
- [ ] Sentry configured (optional)

---

**Railway and Vercel are ready to deploy NOW. Other services can be configured incrementally.** 🚀
