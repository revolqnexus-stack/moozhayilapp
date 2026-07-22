# ⚡ QUICK START - Deploy in 15 Minutes

You've already set up Railway! Here's what to do **right now**:

---

## 📍 WHERE YOU ARE

```
✅ Railway project created
✅ PostgreSQL provisioned  
✅ Redis provisioned
✅ Database credentials obtained
✅ Secrets generated
✅ Code pushed to GitHub

→ Next: Configure API service & deploy
```

---

## 🚀 DO THIS NOW (3 Simple Steps)

### STEP 1: Configure Railway API Service (5 min)

1. **Open Railway Dashboard** → Your project
2. **Click on your API service** (or create "Empty Service" if needed)
3. **Settings tab**:
   - Name: `moozhayil-api`
   - Root Directory: `apps/api`
   - (Build/start commands auto-detect from railway.toml)

### STEP 2: Generate Secrets & Paste Environment Variables (5 min)

**First**, generate your secrets securely:

```bash
# Run this command 6 times in your terminal:
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Save all 6 outputs (see `GENERATE_SECRETS.md` for detailed guide).

**Then**, add to Railway:

1. **Click "Variables" tab**
2. **Click "Raw Editor"** button
3. **Open file**: `RAILWAY_ENV_VARIABLES.txt` (in this folder)
4. **Copy everything**, paste into Railway
5. **Replace all** `<GENERATE_AND_PASTE_HERE>` with your generated secrets
6. **Click "Save"**

Railway will start deploying automatically! ✨

### STEP 3: Run Migrations & Create Admin (5 min)

Wait for build to finish (watch Logs tab), then:

1. **Click "Shell" tab** on API service
2. **Run migrations**:
   ```bash
   npm run migrate:deploy
   ```
3. **Create admin user**:
   ```bash
   ADMIN_SEED_EMAIL=admin@moozhayil.com ADMIN_SEED_PASSWORD=Admin123!@# ADMIN_SEED_NAME=Admin ADMIN_SEED_ROLE=super_admin ADMIN_SEED_CONFIRM=yes npm run seed:admin
   ```

---

## ✅ TEST IT WORKS

Visit in browser: `https://YOUR-RAILWAY-URL.up.railway.app/v1/health`

Should see:
```json
{"status":"ok","timestamp":"...","checks":{"database":"ok","redis":"ok"}}
```

🎉 **Your API is LIVE!**

---

## 🎨 NEXT: Deploy Admin Panel (10 min)

### Quick Vercel Deploy:

1. Go to https://vercel.com → Sign up with GitHub
2. **New Project** → Import `moozhayil-gold-diamonds`
3. **Configure**:
   - Framework: **Vite**
   - Root Directory: **apps/admin**
   - Build Command: **npm run build**
   - Output Directory: **dist**
4. **Environment Variable**:
   ```
   VITE_API_BASE = https://your-railway-url.up.railway.app
   ```
5. **Deploy**

### Update CORS:

1. Copy your Vercel URL (e.g., `https://moozhayil-admin.vercel.app`)
2. Go back to **Railway** → API Variables
3. Find `CORS_ALLOWED_ORIGINS` and update:
   ```
   CORS_ALLOWED_ORIGINS=https://moozhayil-admin.vercel.app
   ```
4. Save (Railway redeploys)

---

## 🧪 TEST ADMIN

1. Visit your Vercel URL
2. Login:
   - Email: `admin@moozhayil.com`
   - Password: `Admin123!@#`

🎉 **Admin panel is LIVE!**

---

## 📱 WHAT ABOUT MOBILE APP?

Your mobile app works **right now** in the emulator! Just update the API URL:

```dart
// apps/mobile/lib/core/config/env.dart
// Change API_BASE_URL to your Railway URL
```

For **production release**, you need:
- Firebase config (push notifications)
- Release keystore (app signing)

But you can test everything locally with the live API!

---

## 🎯 FILES TO USE

1. **RAILWAY_ENV_VARIABLES.txt** ← Copy/paste this into Railway
2. **RAILWAY_SETUP_STEPS.md** ← Detailed step-by-step guide
3. **DEPLOY_NOW_CHECKLIST.md** ← Complete deployment guide
4. **REQUIRED_SERVICES_AND_APIS.md** ← All services you'll need

---

## ⚠️ WHAT'S STILL MOCK

Working but not real:
- **SMS OTP**: Logged to Railway logs (any code works)
- **Firebase Push**: No notifications sent
- **KYC**: Auto-approves everything
- **File Storage**: Local (lost on redeploy)

These work fine for testing! Upgrade when you're ready for customers.

---

## 💰 CURRENT COST

- Railway: **$5/month** (Hobby plan)
- Vercel: **Free**
- **Total: $5/month**

Everything else (Razorpay, SMS, etc.) is pay-per-use.

---

## 🚨 COMMON ISSUES

**Build fails**: Check railway.toml exists (we created it ✅)  
**Migration fails**: Run manually in Shell tab  
**Can't access API**: Check Railway gave you a Public Domain  
**Admin can't connect**: Check CORS_ALLOWED_ORIGINS matches exact Vercel URL  
**OTP doesn't work**: You're in mock mode - check Railway logs for OTP code

---

## ✅ YOU'RE READY!

Everything is configured. Just follow the 3 steps above.

**Total time: ~15 minutes from now to fully deployed!**

🚀 **Let's go!**
