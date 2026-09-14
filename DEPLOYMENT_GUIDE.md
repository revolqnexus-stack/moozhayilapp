# 🚀 Deployment Guide: Vercel + Managed Services

## ⚠️ Important: Vercel Limitations for Your Stack

**Vercel is NOT ideal for your backend** because:
- ❌ No long-running processes (Redis, background jobs)
- ❌ Serverless functions timeout after 10 seconds (60s max on Pro)
- ❌ No persistent WebSocket connections
- ❌ File uploads limited (no local storage)
- ❌ PostgreSQL connection pooling issues

### ✅ **Recommended Architecture Instead**

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Flutter App    │────→│  Node.js API     │────→│  PostgreSQL │
│  (Play/AppStore)│     │  (VPS/Cloud Run) │     │  (Neon.tech)│
└─────────────────┘     └──────────────────┘     └─────────────┘
                                │
                                ├──→ Redis (Upstash)
                                ├──→ S3 (AWS/Cloudflare R2)
                                └──→ Firebase (Push)
```

---

## 🎯 Best Hosting Option for You: **Digital Ocean App Platform**

Why? It's simpler than AWS/GCP but powerful enough:
- ✅ $5-12/month for backend
- ✅ Supports Node.js + Redis + PostgreSQL
- ✅ No serverless limitations
- ✅ Easy to scale
- ✅ Built-in SSL
- ✅ GitHub deployment

---

## 🗄️ Infrastructure Setup (Using Managed Services)

### 1️⃣ **PostgreSQL Database** → [Neon.tech](https://neon.tech) (FREE)

**Why Neon?**
- Free tier: 0.5 GB storage, 10 GB bandwidth/month
- Serverless PostgreSQL (auto-scales)
- Connection pooling built-in
- Perfect for production

**Setup Steps:**
```bash
1. Go to https://neon.tech
2. Sign up (free, no credit card)
3. Create new project: "moozhayil-production"
4. Copy connection string
5. Add to your environment:
   DATABASE_URL=postgresql://user:pass@ep-xxxx.us-east-2.aws.neon.tech/moozhayil?sslmode=require
```

**Alternatives:**
- **Supabase** (free tier): https://supabase.com
- **Railway** (if you change your mind): $5/month
- **Heroku Postgres**: $5/month

---

### 2️⃣ **Redis** → [Upstash](https://upstash.com) (FREE)

**Why Upstash?**
- Free tier: 10,000 commands/day
- Serverless Redis
- Perfect for sessions/caching

**Setup Steps:**
```bash
1. Go to https://upstash.com
2. Create account (free)
3. Create Redis database
4. Copy connection URL
5. Add to environment:
   REDIS_URL=rediss://default:xxxxx@eu2-worthy-xxxx.upstash.io:6379
```

**Alternatives:**
- **Redis Cloud**: Free 30 MB
- **Render Redis**: $7/month

---

### 3️⃣ **File Storage (S3)** → [Cloudflare R2](https://cloudflare.com/products/r2/) (CHEAP)

**Why R2?**
- 10 GB storage free
- No egress fees (unlike AWS S3)
- S3-compatible API

**Setup Steps:**
```bash
1. Go to https://dash.cloudflare.com
2. R2 → Create bucket: "moozhayil-media"
3. Get API tokens
4. Add to environment:
   STORAGE_BACKEND=s3
   S3_ENDPOINT=https://xxxxx.r2.cloudflarestorage.com
   S3_BUCKET=moozhayil-media
   S3_ACCESS_KEY_ID=xxxxx
   S3_SECRET_ACCESS_KEY=xxxxx
   S3_PUBLIC_BASE_URL=https://media.yourdomain.com
```

**Alternatives:**
- **AWS S3**: $0.023/GB (standard)
- **Backblaze B2**: First 10 GB free
- **DigitalOcean Spaces**: $5/month (250 GB)

---

### 4️⃣ **Backend API** → [Digital Ocean App Platform](https://www.digitalocean.com/products/app-platform)

**Why Digital Ocean?**
- $5/month basic plan
- No serverless limitations
- Supports Node.js, Redis, background workers
- Auto-deploy from GitHub

**Setup Steps:**

#### A. Prepare Your Code

Create `apps/api/package.json` with build script:
```json
{
  "scripts": {
    "build": "tsc -p tsconfig.json",
    "start": "node dist/server.js",
    "migrate": "node dist/scripts/migrate.js"
  }
}
```

#### B. Create `.do/app.yaml` in repo root:
```yaml
name: moozhayil-api
region: blr1  # Bangalore region (closest to India)
services:
  - name: api
    github:
      repo: your-username/moozhayil-gold-diamonds
      branch: main
      deploy_on_push: true
    source_dir: apps/api
    build_command: npm ci && npm run build
    run_command: npm run migrate && npm start
    environment_slug: node-js
    instance_size_slug: basic-xxs  # $5/month
    instance_count: 1
    http_port: 3080
    envs:
      - key: NODE_ENV
        value: production
      - key: DATABASE_URL
        value: ${DATABASE_URL}
        type: SECRET
      - key: REDIS_URL
        value: ${REDIS_URL}
        type: SECRET
      - key: RAZORPAY_KEY_ID
        value: ${RAZORPAY_KEY_ID}
        type: SECRET
      - key: RAZORPAY_KEY_SECRET
        value: ${RAZORPAY_KEY_SECRET}
        type: SECRET
    health_check:
      http_path: /health
```

#### C. Deploy:
```bash
1. Go to https://cloud.digitalocean.com/apps
2. Click "Create App"
3. Connect GitHub repo
4. Select "Use existing app spec" → upload .do/app.yaml
5. Add environment variables (secrets)
6. Deploy!
```

**Cost Breakdown:**
- Basic API: $5/month
- Background worker (optional): $5/month
- Total: **$10/month**

---

### 5️⃣ **Flutter Apps** → App Stores

**Android (Google Play):**
```bash
cd apps/mobile
flutter build appbundle --release
# Upload to Google Play Console
```

**iOS (App Store):**
```bash
flutter build ipa --release
# Upload via Xcode or Transporter
```

**API Endpoint in App:**
```dart
// apps/mobile/lib/core/config/api_config.dart
const API_BASE_URL = 'https://api.yourdomain.com';
```

---

## 🔐 Environment Variables Checklist

### **Backend (.env for Digital Ocean)**

```env
# Database
DATABASE_URL=postgresql://user:pass@neon.tech/moozhayil

# Redis
REDIS_URL=rediss://default:pass@upstash.io:6379

# Security
JWT_SECRET=<generate-32-char-random>
JWT_REFRESH_SECRET=<generate-32-char-random>
OTP_HASH_SECRET=<generate-32-char-random>
PII_ENCRYPTION_SECRET=<generate-32-char-random>
ADMIN_JWT_SECRET=<generate-32-char-random>

# Razorpay
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_live_xxxxx
RAZORPAY_KEY_SECRET=xxxxx
RAZORPAY_WEBHOOK_SECRET=xxxxx

# Storage
STORAGE_BACKEND=s3
S3_ENDPOINT=https://xxxxx.r2.cloudflarestorage.com
S3_BUCKET=moozhayil-media
S3_ACCESS_KEY_ID=xxxxx
S3_SECRET_ACCESS_KEY=xxxxx
S3_PUBLIC_BASE_URL=https://media.yourdomain.com

# Firebase (for push notifications)
FIREBASE_MODE=live
FIREBASE_PROJECT_ID=your-project
FIREBASE_CLIENT_EMAIL=firebase@project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"

# CORS
CORS_ALLOWED_ORIGINS=https://admin.yourdomain.com
PUBLIC_BASE_URL=https://api.yourdomain.com
TRUST_PROXY=true

# Providers
SMS_PROVIDER_MODE=live
MSG91_AUTH_KEY=xxxxx
MSG91_OTP_TEMPLATE_ID=xxxxx

KYC_PROVIDER_MODE=live
KYC_PROVIDER_BASE_URL=https://your-kyc-provider.com
KYC_PROVIDER_API_KEY=xxxxx
KYC_WEBHOOK_SECRET=<generate-32-char>

GOLD_RATE_WEBHOOK_SECRET=<generate-32-char>
```

### **Generate Secrets:**
```bash
# On Linux/Mac:
openssl rand -hex 32

# On Windows PowerShell:
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
```

---

## 🌐 Domain Setup

### **Option 1: Use DigitalOcean DNS**
1. Buy domain from Namecheap/GoDaddy
2. Point nameservers to DO:
   - ns1.digitalocean.com
   - ns2.digitalocean.com
   - ns3.digitalocean.com
3. In DO: Networking → Domains → Add domain
4. Create A records pointing to your app

### **Option 2: Use Cloudflare (Recommended)**
1. Add domain to Cloudflare (free)
2. Point nameservers to Cloudflare
3. Add CNAME record:
   ```
   api.yourdomain.com → your-app.ondigitalocean.app
   ```
4. Enable SSL (automatic)

---

## 📦 Complete Setup Checklist

### **Phase 1: Infrastructure (30 mins)**
- [ ] Sign up for Neon.tech → Get PostgreSQL URL
- [ ] Sign up for Upstash → Get Redis URL
- [ ] Sign up for Cloudflare R2 → Get S3 credentials
- [ ] Sign up for DigitalOcean → Connect GitHub

### **Phase 2: Configuration (20 mins)**
- [ ] Generate all secret keys (JWT, OTP, PII)
- [ ] Get live Razorpay keys from dashboard
- [ ] Set up Firebase project for push notifications
- [ ] Configure SMS provider (MSG91)
- [ ] Set up KYC provider

### **Phase 3: Database (15 mins)**
- [ ] Run migrations: `npm run migrate:deploy`
- [ ] Seed admin user: `npm run seed:admin`
- [ ] Verify database connection

### **Phase 4: Backend Deploy (10 mins)**
- [ ] Push code to GitHub
- [ ] Create DO app from GitHub
- [ ] Add all environment variables
- [ ] Deploy and test health endpoint

### **Phase 5: Flutter Apps (varies)**
- [ ] Update API_BASE_URL to production
- [ ] Build Android APK/Bundle
- [ ] Build iOS IPA
- [ ] Submit to Google Play
- [ ] Submit to App Store

### **Phase 6: Monitoring (20 mins)**
- [ ] Set up Sentry for error tracking
- [ ] Configure uptime monitoring (UptimeRobot - free)
- [ ] Set up database backups (Neon auto-backup)
- [ ] Test payment flow end-to-end
- [ ] Test push notifications

---

## 💰 Monthly Cost Breakdown

### **Free Tier (Good for testing):**
```
Neon PostgreSQL:    $0 (free tier)
Upstash Redis:      $0 (free tier)
Cloudflare R2:      $0 (10 GB free)
DigitalOcean:       $0 (trial credit)
Firebase:           $0 (free tier)
──────────────────────────
Total:              $0/month
```

### **Production (Recommended):**
```
Neon PostgreSQL:    $19/month (Launch plan - production ready)
Upstash Redis:      $0 (free tier sufficient)
Cloudflare R2:      ~$1/month (assuming 50 GB)
DigitalOcean API:   $5/month (Basic Droplet)
DO Worker:          $5/month (background jobs)
Firebase:           $0-25/month (based on usage)
Domain:             $12/year (~$1/month)
──────────────────────────
Total:              $31-56/month
```

### **Scale to 10K+ Users:**
```
Neon PostgreSQL:    $69/month (Scale plan)
Upstash Redis:      $10/month (Pro tier)
Cloudflare R2:      $5/month (200 GB)
DigitalOcean API:   $12/month (2x instances)
DO Worker:          $12/month (2x workers)
Firebase:           $50/month
──────────────────────────
Total:              $158/month
```

---

## 🚨 Alternative: If You Want Simplest Setup

### **Use Render.com** (Easiest, slightly pricier)

**Why Render?**
- All-in-one: PostgreSQL + Redis + API
- Auto-deploy from GitHub
- Free SSL
- $7/month for API + $7 for PostgreSQL

**Setup:**
```bash
1. Go to https://render.com
2. Connect GitHub repo
3. Create Web Service (Node.js)
   - Build: npm ci && npm run build
   - Start: npm run start:prod
4. Create PostgreSQL database ($7/month)
5. Create Redis instance ($7/month)
6. Add environment variables
7. Deploy!
```

**Cost:** $21/month (simpler than DO)

---

## 🔄 Flutter App Integration

Update your API base URL:

```dart
// apps/mobile/lib/core/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 
    String.fromEnvironment('API_URL', 
      defaultValue: 'https://api.yourdomain.com'
    );
}
```

Build with different environments:
```bash
# Development
flutter run --dart-define=API_URL=http://localhost:3080

# Production
flutter build appbundle --dart-define=API_URL=https://api.yourdomain.com
```

---

## 🎯 Recommended Path Forward

**For you, I recommend:**

1. **Start with FREE tier:**
   - Neon.tech (PostgreSQL) - FREE
   - Upstash (Redis) - FREE
   - Cloudflare R2 (Storage) - FREE
   - Render.com (API) - $7/month trial

2. **Once tested, move to:**
   - **DigitalOcean** ($10/month) for API
   - Keep Neon + Upstash + R2 (affordable)

3. **Total cost: $10-15/month** for production-ready setup

---

## 📞 Next Steps

1. **Right now - Test locally:**
```bash
cd apps/api
npm run dev
# Test Flutter app with localhost
```

2. **Set up free infrastructure** (Neon + Upstash)

3. **Deploy to Render** (easiest) or **DigitalOcean** (best value)

4. **Build & submit Flutter apps** to stores

Want me to help you set up any specific part? I can:
- Generate all the secret keys
- Create deployment configs
- Set up the database migrations
- Configure the Flutter app for production
