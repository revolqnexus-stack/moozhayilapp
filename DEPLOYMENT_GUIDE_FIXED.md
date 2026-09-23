# 🚀 Moozhayil Deployment Guide - Railway + Vercel

## ✅ YES, Structure is Correct! But needs config files (now added).

---

## 🎯 RECOMMENDED DEPLOYMENT STACK

```
┌─────────────────────────────────────────────┐
│  BEST OPTION FOR YOUR MONOREPO              │
├─────────────────────────────────────────────┤
│  API + Worker:    Railway.app               │
│  Database:        Railway PostgreSQL        │
│  Redis:           Railway Redis             │
│  Admin Panel:     Vercel                    │
│  Object Storage:  AWS S3 or Cloudflare R2  │
└─────────────────────────────────────────────┘
```

**Why Railway?** Monorepo-friendly, auto PostgreSQL + Redis, easy deploys  
**Why Vercel?** Best for React/Vite apps, zero config  

---

## 📁 WHAT WE JUST FIXED

Created these files to fix deployment:

1. ✅ `apps/api/railway.toml` - Railway deployment config
2. ✅ `apps/api/nixpacks.toml` - Build configuration
3. ✅ `apps/admin/vercel.json` - Vercel SPA routing + security headers

---

## 🚀 DEPLOY API TO RAILWAY (Step-by-Step)

### Option A: Via Railway Dashboard (Easiest)

**1. Create Railway Account**
- Go to railway.app
- Sign up with GitHub

**2. Create New Project**
```
Click "New Project"
→ Select "Deploy from GitHub repo"
→ Connect your GitHub account
→ Select: moozhayil-gold-diamonds repo
```

**3. Configure API Service**
```
Railway will auto-detect the monorepo.

Root Directory: apps/api
Build Command: npm ci && npm run build
Start Command: npm run start:prod
```

**4. Add PostgreSQL**
```
Click "+ New"
→ Select "Database"
→ Select "PostgreSQL"
→ It will auto-provision and create DATABASE_URL variable
```

**5. Add Redis**
```
Click "+ New"
→ Select "Database"
→ Select "Redis"
→ It will auto-provision and create REDIS_URL variable
```

**6. Add Environment Variables**

Go to API service → Variables → Raw Editor:

```bash
# Core
NODE_ENV=production
PORT=3080
PUBLIC_BASE_URL=${{RAILWAY_PUBLIC_DOMAIN}}
CORS_ALLOWED_ORIGINS=https://your-admin.vercel.app
TRUST_PROXY=true

# Database (auto-set by Railway)
DATABASE_URL=${{DATABASE_URL}}

# Redis (auto-set by Railway)
REDIS_URL=${{REDIS_URL}}

# Secrets (generate these)
JWT_SECRET=<GENERATE_32_CHAR>
JWT_REFRESH_SECRET=<GENERATE_32_CHAR>
OTP_HASH_SECRET=<GENERATE_32_CHAR>
PII_ENCRYPTION_SECRET=<GENERATE_32_CHAR>
ADMIN_JWT_SECRET=<GENERATE_32_CHAR>

# Razorpay (your test keys for now)
PAYMENT_PROVIDER_MODE=test
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_SECRET
RAZORPAY_WEBHOOK_SECRET=<GENERATE>

# SMS (mock mode for now)
SMS_PROVIDER_MODE=mock
MSG91_AUTH_KEY=mock
MSG91_OTP_TEMPLATE_ID=mock

# Storage (local for now)
STORAGE_BACKEND=local
MEDIA_UPLOAD_DIR=/app/uploads

# Firebase (mock for now)
FIREBASE_MODE=mock
FIREBASE_PROJECT_ID=mock
FIREBASE_CLIENT_EMAIL=mock@mock.com
FIREBASE_PRIVATE_KEY=mock

# KYC (mock for now)
KYC_PROVIDER_MODE=mock
KYC_PROVIDER_BASE_URL=http://localhost
KYC_PROVIDER_API_KEY=mock

# Safety
ENABLE_DEMO_SEEDS=false
```

**7. Deploy**
```
Railway auto-deploys on git push.
Or click "Deploy" button.

Wait for build to complete.
Check logs for errors.
```

**8. Test API**
```bash
# Get your Railway URL from dashboard
curl https://your-app.up.railway.app/v1/health

# Should return:
{"status":"ok","timestamp":"...","checks":{"database":"ok","redis":"ok"}}
```

**9. Run Migrations & Seed Admin**

Click on API service → "Shell" tab:

```bash
# Run migrations:
npm run migrate:deploy

# Seed first admin:
ADMIN_SEED_EMAIL=admin@moozhayil.com \
ADMIN_SEED_PASSWORD=Admin123!@# \
ADMIN_SEED_NAME=Admin \
ADMIN_SEED_ROLE=super_admin \
ADMIN_SEED_CONFIRM=yes \
npm run seed:admin
```

**10. Add Worker Service**

```
Click "+ New" → "Empty Service"
Name: moozhayil-worker
Root Directory: apps/api
Build Command: npm ci && npm run build
Start Command: npm run worker:start
Port: 3081

Add same environment variables as API service.
```

---

### Option B: Via Railway CLI (For Nerds)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Create project
railway init

# Link to service
cd apps/api
railway link

# Set variables (add all from above)
railway variables set NODE_ENV=production
railway variables set DATABASE_URL=...
# ... etc

# Deploy
railway up

# View logs
railway logs
```

---

## 🎨 DEPLOY ADMIN TO VERCEL

**1. Create Vercel Account**
- Go to vercel.com
- Sign up with GitHub

**2. Import Project**
```
Click "New Project"
→ Import from GitHub
→ Select: moozhayil-gold-diamonds
→ Vercel auto-detects monorepo
```

**3. Configure Build**
```
Framework Preset: Vite
Root Directory: apps/admin
Build Command: npm run build
Output Directory: dist
Install Command: npm ci
```

**4. Add Environment Variable**
```
VITE_API_BASE=https://your-api.up.railway.app
```

**5. Deploy**
```
Click "Deploy"
Wait for build.
Visit deployed URL.
```

**6. Test Admin**
```
1. Visit: https://your-admin.vercel.app
2. Login: admin@moozhayil.com / Admin123!@#
3. Should see dashboard
```

---

## 🐛 COMMON ERRORS & FIXES

### Railway Errors

**Error: `Cannot find module 'xxx'`**
```bash
# Fix: Make sure package.json has all dependencies
cd apps/api
npm ci
# Check if missing deps, add to package.json
```

**Error: `Prisma Client not generated`**
```bash
# Fix: Added postinstall script
# package.json already has: "postinstall": "prisma generate"
# Railway will auto-run this
```

**Error: `Database connection failed`**
```bash
# Fix: Check DATABASE_URL format
# Should be: postgresql://user:pass@host:port/db?sslmode=require
# Railway auto-adds sslmode=disable, change to require:
DATABASE_URL=postgresql://...?sslmode=require
```

**Error: `Migration failed`**
```bash
# Fix: Railway might not have run migrations
# Manual run via Shell:
railway shell
npm run migrate:deploy
```

**Error: `Port already in use`**
```bash
# Fix: Railway sets PORT automatically
# Your code reads: process.env.PORT || 3080
# This is correct. No fix needed.
```

### Vercel Errors

**Error: `No routes found`**
```bash
# Fix: vercel.json already created with SPA rewrite
# Push the new vercel.json file
```

**Error: `VITE_API_BASE not defined`**
```bash
# Fix: Add in Vercel dashboard
Settings → Environment Variables
VITE_API_BASE = https://your-railway-url
Redeploy
```

**Error: `TypeScript errors`**
```bash
# Fix: Run typecheck locally first
cd apps/admin
npm run typecheck
# Fix errors, then redeploy
```

---

## 📊 ALTERNATIVE: ALL-AWS SETUP (If Railway/Vercel Fail)

### Why AWS?
- More control
- Better for large scale
- More expensive
- More complex

### AWS Stack:

```
┌─────────────────────────────────────┐
│  API:             ECS Fargate       │
│  Database:        RDS PostgreSQL    │
│  Redis:           ElastiCache       │
│  Images:          S3 + CloudFront   │
│  Admin:           S3 + CloudFront   │
└─────────────────────────────────────┘
```

**Cost:** ~$50-100/month vs Railway's $5-10/month

### AWS Deployment Steps:

**1. RDS PostgreSQL**
```bash
aws rds create-db-instance \
  --db-instance-identifier moozhayil-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.3 \
  --master-username admin \
  --master-user-password YourPassword \
  --allocated-storage 20
```

**2. ElastiCache Redis**
```bash
aws elasticache create-cache-cluster \
  --cache-cluster-id moozhayil-redis \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

**3. S3 Bucket**
```bash
aws s3 mb s3://moozhayil-media
aws s3 website s3://moozhayil-admin --index-document index.html
```

**4. Build & Push to ECR**
```bash
cd apps/api

# Build Docker image
docker build -t moozhayil-api .

# Push to ECR
aws ecr create-repository --repository-name moozhayil-api
docker tag moozhayil-api:latest <account-id>.dkr.ecr.region.amazonaws.com/moozhayil-api:latest
docker push <account-id>.dkr.ecr.region.amazonaws.com/moozhayil-api:latest
```

**5. ECS Task Definition**
```json
{
  "family": "moozhayil-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [{
    "name": "api",
    "image": "<account-id>.dkr.ecr.region.amazonaws.com/moozhayil-api:latest",
    "portMappings": [{"containerPort": 3080}],
    "environment": [
      {"name": "NODE_ENV", "value": "production"},
      {"name": "DATABASE_URL", "value": "postgresql://..."}
    ]
  }]
}
```

**6. Create ECS Service**
```bash
aws ecs create-service \
  --cluster moozhayil \
  --service-name api \
  --task-definition moozhayil-api \
  --desired-count 1 \
  --launch-type FARGATE
```

**This is MUCH more complex. Stick with Railway unless you need it.**

---

## 🎯 RECOMMENDED APPROACH

### For Getting Started (NOW):
```
✅ Railway (API + DB + Redis)
✅ Vercel (Admin)
✅ Local storage (STORAGE_BACKEND=local)
✅ Mock SMS (SMS_PROVIDER_MODE=mock)
✅ Razorpay test mode
```

### For Production (LATER):
```
Migrate to:
- AWS S3 for images
- MSG91 for real SMS
- Razorpay live keys
- KYC provider
- Firebase for push
```

---

## 🔥 QUICK START COMMAND

```bash
# 1. Generate secrets
for i in {1..5}; do openssl rand -base64 32; done

# 2. Copy these to Railway variables

# 3. Deploy API
git add apps/api/railway.toml apps/api/nixpacks.toml
git commit -m "Add Railway config"
git push origin main
# Railway auto-deploys

# 4. Deploy Admin
git add apps/admin/vercel.json
git commit -m "Add Vercel config"
git push origin main
# Import on Vercel dashboard

# 5. Test
curl https://your-api.up.railway.app/v1/health
open https://your-admin.vercel.app
```

---

## ✅ CHECKLIST

After deployment:

```bash
□ Railway project created
□ PostgreSQL provisioned
□ Redis provisioned
□ API service deployed
□ Worker service deployed
□ Environment variables set
□ Migrations run
□ Admin user seeded
□ Health check passing
□ Vercel project created
□ Admin panel deployed
□ Admin login works
□ Can create product in admin
```

---

## 🆘 STILL GETTING ERRORS?

**Share the specific error message and I'll fix it!**

Common issues:
1. Monorepo root directory not set correctly
2. Missing environment variables
3. Database migration not run
4. Build command wrong
5. Port configuration

**Railway Logs:** Dashboard → Service → Logs tab  
**Vercel Logs:** Dashboard → Deployment → Function Logs

---

**The structure IS correct. The config files were just missing. Now it will deploy!** 🚀
