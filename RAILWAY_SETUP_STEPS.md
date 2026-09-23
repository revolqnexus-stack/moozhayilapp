# 🚂 Railway Setup - Next Steps

You've already created Railway project and provisioned PostgreSQL + Redis! Here's what to do next.

---

## ✅ WHAT YOU HAVE

- ✅ Railway account created
- ✅ PostgreSQL database provisioned
- ✅ Redis cache provisioned
- ✅ Database credentials obtained
- ✅ Security secrets generated

---

## 🎯 NEXT STEPS (15 minutes)

### Step 1: Configure API Service in Railway

1. **Go to Railway Dashboard** → Your Project
2. **Click on API service** (or create one if it doesn't exist)
3. **Go to Settings tab**:
   - **Root Directory**: `apps/api`
   - **Build Command**: (should auto-detect from railway.toml)
   - **Start Command**: (should auto-detect from railway.toml)
   - **Health Check Path**: `/v1/health`

### Step 2: Add Environment Variables

1. **Click on "Variables" tab**
2. **Click "Raw Editor"** button
3. **Open the file**: `RAILWAY_ENV_VARIABLES.txt` (in your project root)
4. **Copy EVERYTHING** from that file
5. **Paste into Railway** Raw Editor
6. **Click "Save"**

Railway will automatically start deploying!

### Step 3: Wait for Build to Complete

1. **Go to "Logs" tab**
2. Watch the build progress
3. Wait for: `✅ Build successful`
4. Railway will show you the **public URL** (e.g., `moozhayil-api-production.up.railway.app`)

### Step 4: Get Your Public URL

1. **In Railway Dashboard** → API service
2. **Go to Settings** → **Networking**
3. **Copy the Public Domain** (something like: `moozhayil-api-production.up.railway.app`)

### Step 5: Update PUBLIC_BASE_URL (Important!)

1. **Go back to Variables tab**
2. **Find** `PUBLIC_BASE_URL`
3. **Update it** if it doesn't look right - it should be using `${{RAILWAY_PUBLIC_DOMAIN}}`
4. If Railway shows the actual URL, it should look like:
   ```
   PUBLIC_BASE_URL=https://moozhayil-api-production.up.railway.app
   ```

### Step 6: Run Database Migrations

**Option A: Using Railway Shell (Easiest)**
1. Click on API service → **"Shell"** tab
2. Type:
   ```bash
   npm run migrate:deploy
   ```
3. Press Enter
4. Wait for: `✅ Migrations applied successfully`

**Option B: It might auto-run**
- Your `start:prod` script already runs migrations
- Check the logs to see if migrations ran automatically

### Step 7: Create First Admin User

1. In Railway **Shell** tab, run:
   ```bash
   ADMIN_SEED_EMAIL=admin@moozhayil.com ADMIN_SEED_PASSWORD=Admin123!@# ADMIN_SEED_NAME=Admin ADMIN_SEED_ROLE=super_admin ADMIN_SEED_CONFIRM=yes npm run seed:admin
   ```

2. You should see:
   ```
   ✅ Admin user created successfully
   Email: admin@moozhayil.com
   ```

### Step 8: Test API Health Check

1. Open your browser
2. Visit: `https://YOUR-RAILWAY-URL.up.railway.app/v1/health`
3. You should see:
   ```json
   {
     "status": "ok",
     "timestamp": "2024-01-...",
     "checks": {
       "database": "ok",
       "redis": "ok"
     }
   }
   ```

✅ **If you see this, your API is LIVE!** 🎉

---

## 🔧 OPTIONAL: Add Worker Service

The worker handles background jobs (sending notifications, processing refunds, etc.).

1. **In Railway Dashboard**, click **"+ New"** → **"Empty Service"**
2. **Name it**: `moozhayil-worker`
3. **Settings**:
   - **Root Directory**: `apps/api`
   - **Build Command**: `npm ci && npm run build`
   - **Start Command**: `npm run worker:start`
4. **Variables**: Copy the **exact same variables** from API service
   - Go to API service → Variables → Raw Editor → Copy all
   - Go to Worker service → Variables → Raw Editor → Paste
5. **Deploy**

---

## 🎨 NEXT: Deploy Admin Panel to Vercel

Once your Railway API is live, you can deploy the admin panel.

### Quick Vercel Setup:

1. **Go to** https://vercel.com
2. **Sign up** with GitHub
3. **Click "New Project"**
4. **Import** `moozhayil-gold-diamonds` repo
5. **Configure**:
   - Framework: Vite
   - Root Directory: `apps/admin`
   - Build Command: `npm run build`
   - Output Directory: `dist`
6. **Add Environment Variable**:
   ```
   VITE_API_BASE=https://YOUR-RAILWAY-URL.up.railway.app
   ```
7. **Deploy**

Vercel will give you a URL like: `moozhayil-admin.vercel.app`

### Update CORS in Railway:

1. **Go back to Railway** → API service → Variables
2. **Find** `CORS_ALLOWED_ORIGINS`
3. **Update to**:
   ```
   CORS_ALLOWED_ORIGINS=https://moozhayil-admin.vercel.app
   ```
   (use your actual Vercel URL, no trailing slash)
4. **Save** (Railway will redeploy)

---

## 🧪 TEST EVERYTHING

### 1. API Health
```bash
curl https://YOUR-RAILWAY-URL.up.railway.app/v1/health
```
✅ Should return `{"status":"ok"}`

### 2. Admin Login
1. Visit: `https://your-admin.vercel.app`
2. Login:
   - Email: `admin@moozhayil.com`
   - Password: `Admin123!@#`
3. ✅ Should see dashboard

### 3. Create Test Product
1. Admin → Catalogue → Products → Create
2. Fill in details
3. ✅ Product should save successfully

---

## 🚨 TROUBLESHOOTING

### Issue: Build fails with "Cannot find module"
**Solution**: 
- Check that `apps/api/railway.toml` exists ✅ (we created it)
- Try: Settings → Clear Build Cache → Redeploy

### Issue: "Prisma Client not generated"
**Solution**: 
- Already handled by `postinstall` script in package.json ✅
- Should auto-run during build

### Issue: Migration fails
**Solution**:
```bash
# In Railway Shell:
npx prisma generate
npm run migrate:deploy
```

### Issue: Can't access API from browser
**Solution**:
- Check that Railway gave your service a **Public Domain**
- Go to: Settings → Networking → Generate Domain (if missing)

### Issue: Admin can't connect to API
**Solution**:
- Check `CORS_ALLOWED_ORIGINS` in Railway variables
- Must match EXACT Vercel URL (no trailing slash)
- Example: `https://moozhayil-admin.vercel.app` ✅
- NOT: `https://moozhayil-admin.vercel.app/` ❌

### Issue: OTP not working
**Solution**:
- You're in mock mode - OTPs are logged to Railway logs
- Check: Railway → API service → Logs
- Search for: "OTP" to find the code
- Any OTP code will work in mock mode

---

## 📊 YOUR CURRENT SETUP

```
✅ GitHub Repo: moozhayil-gold-diamonds (pushed)
✅ Railway Project: Created
✅ PostgreSQL: postgresql://USER:PASSWORD@HOST:5432/railway
✅ Redis: redis://default:hxnlfMRDMdQPfzrvvGnbjOAcPtHTebeU@redis.railway.internal:6379
✅ Security Secrets: Generated (in RAILWAY_ENV_VARIABLES.txt)
⏳ API Service: Need to configure & deploy
⏳ Admin Panel: Need to deploy to Vercel
⏳ Razorpay: Need to upgrade to LIVE keys
```

---

## 🎯 COMPLETION CHECKLIST

Railway Setup:
- [ ] API service configured (root directory: apps/api)
- [ ] Environment variables pasted
- [ ] Build completed successfully
- [ ] Public URL obtained
- [ ] Database migrations run
- [ ] Admin user seeded
- [ ] Health check passing
- [ ] Worker service added (optional)

Vercel Setup:
- [ ] Project imported
- [ ] Build settings configured
- [ ] VITE_API_BASE added
- [ ] Deployment successful
- [ ] CORS updated in Railway
- [ ] Admin login works

---

## 🚀 YOU'RE ALMOST THERE!

Follow the steps above in order. Each step takes 1-3 minutes.

**Total time: ~15 minutes to get fully deployed!**

---

## 🆘 NEED HELP?

If you see any errors:
1. **Check Railway Logs**: Dashboard → Service → Logs tab
2. **Check the error message** carefully
3. **Common fix**: Most issues are typos in environment variables

**Let's get this deployed!** 🎉
