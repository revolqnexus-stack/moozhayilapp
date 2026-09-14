# 🚀 Deploy to Render.com - Step by Step

## ✅ You Already Have:
- ✅ Neon PostgreSQL database
- ✅ Upstash Redis
- ✅ Cloudflare account (need to set up R2)
- ✅ GitHub repo pushed
- ✅ Secrets generated

---

## Step 1: Set Up Cloudflare R2 Storage (5 minutes)

1. **Go to Cloudflare Dashboard:**
   ```
   https://dash.cloudflare.com/28247e5c8e5aca83c94a869bdfbd0b6d
   ```

2. **Create R2 Bucket:**
   - Click "R2" in sidebar
   - Click "Create bucket"
   - Name: `moozhayil-media`
   - Location: Automatic
   - Click "Create bucket"

3. **Get API Keys:**
   - Go to R2 → Settings → API Tokens
   - Click "Create API Token"
   - Name: "Moozhayil API Access"
   - Permissions: Object Read & Write
   - Click "Create API Token"
   - **COPY** the Access Key ID and Secret Access Key
   - Save them somewhere safe!

4. **Get Your Endpoint URL:**
   - It will be: `https://28247e5c8e5aca83c94a869bdfbd0b6d.r2.cloudflarestorage.com`

---

## Step 2: Sign Up for Render.com (2 minutes)

1. **Go to:** https://render.com
2. **Sign Up** with GitHub
3. **Authorize** Render to access your repos

---

## Step 3: Deploy Your API (10 minutes)

### A. Create Web Service

1. **Click "New +" → "Web Service"**

2. **Connect Repository:**
   - Find: `revolqnexus-stack/moozhayilapp`
   - Click "Connect"

3. **Configure Service:**
   ```
   Name: moozhayil-api
   Region: Singapore (closest to India)
   Branch: main
   Root Directory: apps/api
   Runtime: Node
   Build Command: npm ci && npm run build && npx prisma generate
   Start Command: npm run start:prod
   Plan: Starter ($7/month)
   ```

4. **Click "Create Web Service"** (don't deploy yet - we need env vars)

### B. Add Environment Variables

Click "Environment" tab on left, then add these variables:

#### Basic Config:
```
NODE_ENV=production
PORT=3080
TRUST_PROXY=true
LOG_LEVEL=info
```

#### Database & Redis (Copy from your setup):
```
DATABASE_URL=postgresql://neondb_owner:npg_7SxQXUGVi0sq@ep-damp-bonus-axn314ol-pooler.c-4.us-east-2.aws.neon.tech/neondb?sslmode=require

REDIS_URL=redis://default:gQAAAAAAAkxUAAIgcDFiNTBkMGM5MDhlYTM0N2M3OWIxMTBiZGY2MTU1NWVhYg@crack-duck-150612.upstash.io:6379
```

#### Security Secrets (From PRODUCTION_ENV.txt):
```
JWT_SECRET=11d8ca10940c8e5129bfee6a6916fc4dae4300f6aae3c332214db13d576cf508
JWT_REFRESH_SECRET=23d42299dbf0282d278255319949ad9bfc6de609309b76c91e9922493d1c7aa8
OTP_HASH_SECRET=e7fc45e520eb6a8eb33a7c75d944b251db935bdc197d82d9f806930691e0ea1e
PII_ENCRYPTION_SECRET=0a48d4af223124ce38c7f955baa236c571408a59458516546cf47d78ac2e625b
ADMIN_JWT_SECRET=f9201d2e0d1c703f3f8754c711d5820fce909719cd952a343047e681563dab07
KYC_WEBHOOK_SECRET=d0aa61a2e142700fb7e593a00807bee96b957752c12d51439bdb6cac2f20fc80
GOLD_RATE_WEBHOOK_SECRET=57bc4ab2a4ab7cde1cee935fdf057c956fedb79a227c7a241630d1f59c9b4b18
```

#### Razorpay (Use your test keys for now):
```
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_HERE
RAZORPAY_KEY_SECRET=YOUR_SECRET_HERE
RAZORPAY_WEBHOOK_SECRET=3d3af9998e4f87ae5f7692b3a468cf53
```

#### Cloudflare R2 Storage (Use values from Step 1):
```
STORAGE_BACKEND=s3
S3_ENDPOINT=https://28247e5c8e5aca83c94a869bdfbd0b6d.r2.cloudflarestorage.com
S3_REGION=auto
S3_BUCKET=moozhayil-media
S3_ACCESS_KEY_ID=YOUR_R2_ACCESS_KEY_FROM_STEP1
S3_SECRET_ACCESS_KEY=YOUR_R2_SECRET_KEY_FROM_STEP1
S3_PUBLIC_BASE_URL=https://moozhayil-api.onrender.com/media
S3_FORCE_PATH_STYLE=false
```

#### CORS & URLs:
```
PUBLIC_BASE_URL=https://moozhayil-api.onrender.com
CORS_ALLOWED_ORIGINS=https://admin.yourdomain.com,https://yourdomain.com
```

#### Providers (Start with MOCK mode):
```
SMS_PROVIDER_MODE=mock
MSG91_AUTH_KEY=
MSG91_OTP_TEMPLATE_ID=

KYC_PROVIDER_MODE=mock
KYC_PROVIDER_BASE_URL=
KYC_PROVIDER_API_KEY=

FIREBASE_MODE=mock
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=

ENABLE_DEMO_SEEDS=false
WORKER_HEALTH_PORT=3001
```

### C. Deploy!

1. **Click "Save Changes"**
2. **Render will automatically deploy**
3. **Wait 5-10 minutes** for build to complete
4. **Check logs** for any errors

---

## Step 4: Run Database Migrations (5 minutes)

Once deployed:

1. **Go to your service** → "Shell" tab
2. **Run:**
   ```bash
   npm run migrate:deploy
   ```

3. **Seed admin user:**
   ```bash
   npm run seed:admin
   ```

4. **Check it worked:**
   ```bash
   npm run prisma:studio
   ```

---

## Step 5: Test Your API (2 minutes)

1. **Get your URL:** `https://moozhayil-api.onrender.com`

2. **Test health endpoint:**
   ```bash
   curl https://moozhayil-api.onrender.com/health
   ```

3. **Expected response:**
   ```json
   {"status":"ok"}
   ```

---

## Step 6: Update Flutter App (5 minutes)

1. **Open your Flutter project**

2. **Update API URL:**
   ```dart
   // In your API config file
   const API_BASE_URL = 'https://moozhayil-api.onrender.com';
   ```

3. **Or use build args:**
   ```bash
   flutter run --dart-define=API_URL=https://moozhayil-api.onrender.com
   ```

---

## Step 7: Get Live Razorpay Keys

1. **Go to:** https://dashboard.razorpay.com/
2. **Switch to "Live Mode"** (top left toggle)
3. **Settings → API Keys → Generate**
4. **Copy:**
   - Key ID (starts with `rzp_live_`)
   - Key Secret

5. **Update in Render:**
   - Go to Environment variables
   - Update `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`
   - Click "Save Changes"

---

## 🎉 You're Live!

Your API is now running at: `https://moozhayil-api.onrender.com`

### Next Steps:

1. **Test payment flow** with Razorpay test cards
2. **Build Flutter apps** with production API URL
3. **Submit to app stores**

---

## 💰 Monthly Cost

```
Render Web Service: $7/month
Neon PostgreSQL:    $0 (free tier)
Upstash Redis:      $0 (free tier)
Cloudflare R2:      $0 (free for 10GB)
─────────────────────────────
Total:              $7/month
```

---

## 🆘 Troubleshooting

### "Build failed"
- Check logs in Render dashboard
- Make sure `apps/api` is the root directory
- Verify build command includes `npx prisma generate`

### "Cannot connect to database"
- Check DATABASE_URL has `?sslmode=require` at the end
- Verify Neon database is not paused

### "Redis connection error"
- Check REDIS_URL format
- Upstash Redis URL should start with `redis://`

### "Migration failed"
- Run migrations manually in Shell tab
- Check database permissions

---

## 📞 Need Help?

Check deployment logs in Render dashboard. Most issues are:
1. Missing environment variable
2. Wrong DATABASE_URL format
3. Build command error

All your credentials are in: `PRODUCTION_ENV.txt`
