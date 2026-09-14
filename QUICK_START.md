# 🚀 Quick Start: From Zero to Production

## ✅ What's Already Done

1. ✅ **Razorpay integrated** in backend API
2. ✅ **Flutter app updated** to use new verification endpoint
3. ✅ **Deployment configs created** for DigitalOcean & Render
4. ✅ **Secret generator** script ready

---

## 🎯 Your Next Steps (Choose Your Path)

### **Path A: Test Locally First** (Recommended)

```bash
# 1. Generate secrets
node generate-secrets.js

# 2. Start local database (if you have Docker)
docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:15
docker run -d --name redis -p 6379:6379 redis:7

# 3. Update apps/api/.env with:
#    - DATABASE_URL=postgresql://postgres:postgres@localhost:5432/moozhayil
#    - REDIS_URL=redis://localhost:6379
#    - Copy secrets from .secrets-generated.txt

# 4. Run migrations
cd apps/api
npm run prisma:migrate
npm run seed:admin

# 5. Start API
npm run dev

# 6. Test Flutter app
cd ../mobile
flutter run --dart-define=API_URL=http://localhost:3080
```

---

### **Path B: Deploy to Production Now**

## 🌟 Easiest Option: **Render.com** (All-in-One)

### Step 1: Sign Up (2 mins)
```
Go to: https://render.com
Sign up with GitHub
```

### Step 2: Create Services (10 mins)

#### A. PostgreSQL Database
```
1. Click "New +" → PostgreSQL
2. Name: moozhayil-db
3. Database: moozhayil
4. User: moozhayil
5. Region: Singapore (closest to India)
6. Plan: Starter ($7/month) or Free (slower)
7. Create Database
8. Copy "External Database URL"
```

#### B. Redis (Use Upstash - FREE)
```
1. Go to: https://upstash.com
2. Sign up
3. Create Redis Database
4. Region: AWS AP-Southeast-1 (Singapore)
5. Copy connection URL (starts with rediss://)
```

#### C. S3 Storage (Use Cloudflare R2)
```
1. Go to: https://dash.cloudflare.com
2. R2 Object Storage → Create bucket: "moozhayil-media"
3. Settings → R2 API tokens → Create API token
4. Copy:
   - Access Key ID
   - Secret Access Key
   - Endpoint URL
```

### Step 3: Deploy API (5 mins)

```bash
# Push your code to GitHub first
git add .
git commit -m "feat: add Razorpay integration"
git push origin main
```

Then in Render:
```
1. Click "New +" → Web Service
2. Connect your GitHub repo
3. Name: moozhayil-api
4. Region: Singapore
5. Branch: main
6. Root Directory: apps/api
7. Runtime: Node
8. Build Command: npm ci && npm run build && npx prisma generate
9. Start Command: npm run start:prod
10. Plan: Starter ($7/month)
```

### Step 4: Add Environment Variables

Click "Environment" tab and add these:

#### Generated Secrets (run `node generate-secrets.js`):
```
JWT_SECRET=<from generated>
JWT_REFRESH_SECRET=<from generated>
OTP_HASH_SECRET=<from generated>
PII_ENCRYPTION_SECRET=<from generated>
ADMIN_JWT_SECRET=<from generated>
KYC_WEBHOOK_SECRET=<from generated>
GOLD_RATE_WEBHOOK_SECRET=<from generated>
```

#### Database & Redis:
```
DATABASE_URL=<from Render PostgreSQL>
REDIS_URL=<from Upstash>
```

#### Razorpay:
```
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=<your secret>
RAZORPAY_WEBHOOK_SECRET=<from generated>
```

#### Storage (Cloudflare R2):
```
STORAGE_BACKEND=s3
S3_ENDPOINT=https://xxxxx.r2.cloudflarestorage.com
S3_BUCKET=moozhayil-media
S3_ACCESS_KEY_ID=<from Cloudflare>
S3_SECRET_ACCESS_KEY=<from Cloudflare>
S3_PUBLIC_BASE_URL=https://media.yourdomain.com
S3_REGION=auto
S3_FORCE_PATH_STYLE=false
```

#### Other Settings:
```
NODE_ENV=production
PORT=3080
TRUST_PROXY=true
PUBLIC_BASE_URL=https://your-app.onrender.com
CORS_ALLOWED_ORIGINS=https://your-admin-domain.com

SMS_PROVIDER_MODE=mock  # Change to 'live' when ready
MSG91_AUTH_KEY=
MSG91_OTP_TEMPLATE_ID=

KYC_PROVIDER_MODE=mock  # Change to 'live' when ready
KYC_PROVIDER_BASE_URL=
KYC_PROVIDER_API_KEY=

FIREBASE_MODE=mock  # Change to 'live' when ready
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=

ENABLE_DEMO_SEEDS=false
LOG_LEVEL=info
```

### Step 5: Deploy!

```
Click "Create Web Service"
Wait 5-10 minutes for deployment
Check logs for any errors
Visit: https://your-app.onrender.com/health
```

---

## 📱 Deploy Flutter Apps

### Android

```bash
cd apps/mobile

# 1. Update API URL in .env or config
echo 'API_BASE_URL=https://your-app.onrender.com' > .env

# 2. Build release
flutter build appbundle --release --dart-define=API_URL=https://your-app.onrender.com

# 3. Sign APK (you need keystore - see Android docs)
# Located at: build/app/outputs/bundle/release/app-release.aab

# 4. Upload to Google Play Console
```

### iOS

```bash
# 1. Open in Xcode
open ios/Runner.xcworkspace

# 2. Update API URL in configuration

# 3. Build archive
flutter build ipa --release --dart-define=API_URL=https://your-app.onrender.com

# 4. Upload via Transporter or Xcode
# Located at: build/ios/archive/Runner.xcarchive
```

---

## 🔧 Post-Deployment Checklist

### Immediately After Deploy:

- [ ] Test health endpoint: `https://your-api.com/health`
- [ ] Run database migrations: 
  ```bash
  # In Render shell
  npm run migrate:deploy
  npm run seed:admin
  ```
- [ ] Test login: `POST /api/auth/login`
- [ ] Test Razorpay order creation
- [ ] Test payment verification

### In Razorpay Dashboard:

- [ ] Get live API keys (Settings → API Keys)
- [ ] Configure webhook: `https://your-api.com/api/webhooks/razorpay`
- [ ] Enable payment methods (Cards, UPI, Netbanking)
- [ ] Test with test cards
- [ ] Switch to live mode when ready

### For Production:

- [ ] Set up custom domain (optional)
- [ ] Configure SSL (automatic on Render)
- [ ] Set up monitoring (Sentry, UptimeRobot)
- [ ] Enable database backups
- [ ] Test payment flow end-to-end
- [ ] Submit Flutter apps to stores

---

## 💰 Total Monthly Cost

### Option 1: Render + Free Services
```
Render Web Service:      $7/month
Render PostgreSQL:       $7/month (or FREE tier)
Upstash Redis:           $0 (free tier)
Cloudflare R2:           $0-1/month
──────────────────────────────
Total:                   $14-15/month
```

### Option 2: DigitalOcean (Better Value)
```
DO App Platform:         $5/month
DO Worker (optional):    $5/month
Neon PostgreSQL:         $0-19/month
Upstash Redis:           $0 (free tier)
Cloudflare R2:           $0-1/month
──────────────────────────────
Total:                   $10-30/month
```

---

## 🆘 Troubleshooting

### "Cannot connect to database"
```bash
# Check DATABASE_URL format:
postgresql://user:pass@host:5432/dbname?sslmode=require

# Test connection:
psql $DATABASE_URL
```

### "Redis connection failed"
```bash
# Check REDIS_URL format:
rediss://default:pass@host:port

# Test connection:
redis-cli -u $REDIS_URL ping
```

### "Build failed on Render"
```bash
# Common issues:
1. Check Node version in package.json engines
2. Ensure build command includes: npx prisma generate
3. Check logs in Render dashboard
```

### "Razorpay not working"
```bash
# Check:
1. RAZORPAY_KEY_ID is correct
2. RAZORPAY_KEY_SECRET is set
3. PAYMENT_PROVIDER=razorpay (not cashfree)
4. Test with test keys first
```

---

## 📞 Need Help?

Check these files:
- **Full deployment guide**: `DEPLOYMENT_GUIDE.md`
- **Razorpay docs**: `RAZORPAY_INTEGRATION.md`
- **Generate secrets**: Run `node generate-secrets.js`

---

## ✨ You're All Set!

Your app is now:
- ✅ Razorpay integrated
- ✅ Flutter app updated
- ✅ Ready to deploy
- ✅ Production configurations ready

**Next:** Choose your hosting (Render recommended for simplicity) and deploy!
