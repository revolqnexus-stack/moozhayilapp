# 🚀 DEPLOY RIGHT NOW - 3 Steps

Everything is ready. Just copy/paste and click save.

---

## STEP 1: Paste Variables into Railway (2 minutes)

1. **Open**: https://railway.app/project/6df8d1ef-653b-46a8-9e35-03646eee81f4

2. **Click** on your API service (moozhayil-gold-diamonds)

3. **Click** "Variables" tab

4. **Click** "Raw Editor" button (top right)

5. **Open the file**: `railway-secrets.txt` (in this folder)

6. **Copy EVERYTHING** from that file

7. **Paste** into Railway Raw Editor

8. **Click "Save"**

✅ Railway will automatically start deploying!

---

## STEP 2: Wait for Build (5 minutes)

1. **Click** "Logs" tab in Railway

2. **Watch** the build progress

3. **Wait for**: `✅ Build successful`

4. **Copy** your public URL (Railway shows it at the top)
   - Something like: `moozhayil-api-production.up.railway.app`

---

## STEP 3: Run Migrations & Create Admin (3 minutes)

1. **Click** "Shell" tab in Railway

2. **Run migrations**:
   ```bash
   npm run migrate:deploy
   ```
   Wait for: `✅ Migrations applied`

3. **Create admin user**:
   ```bash
   ADMIN_SEED_EMAIL=admin@moozhayil.com ADMIN_SEED_PASSWORD=Admin123!@# ADMIN_SEED_NAME=Admin ADMIN_SEED_ROLE=super_admin ADMIN_SEED_CONFIRM=yes npm run seed:admin
   ```
   Wait for: `✅ Admin user created`

---

## ✅ TEST IT WORKS

**Open in browser**: `https://YOUR-RAILWAY-URL.up.railway.app/v1/health`

Should see:
```json
{
  "status": "ok",
  "timestamp": "...",
  "checks": {
    "database": "ok",
    "redis": "ok"
  }
}
```

🎉 **YOUR API IS LIVE!**

---

## 🎨 NEXT: Deploy Admin to Vercel (10 minutes)

1. Go to https://vercel.com → Sign up with GitHub

2. **New Project** → Import `moozhayil-gold-diamonds`

3. **Configure**:
   - Framework: **Vite**
   - Root Directory: **apps/admin**
   - Build Command: **npm run build**
   - Output Directory: **dist**

4. **Add Environment Variable**:
   ```
   VITE_API_BASE = https://your-railway-url.up.railway.app
   ```

5. **Click Deploy**

6. **Copy your Vercel URL** (e.g., `moozhayil-admin.vercel.app`)

7. **Update CORS in Railway**:
   - Go back to Railway → Variables
   - Find `CORS_ALLOWED_ORIGINS`
   - Change to: `https://your-vercel-url.vercel.app`
   - Click Save

---

## 🧪 TEST ADMIN PANEL

1. **Visit**: `https://your-vercel-url.vercel.app`

2. **Login**:
   - Email: `admin@moozhayil.com`
   - Password: `Admin123!@#`

3. **Should see**: Dashboard with empty data

🎉 **ADMIN PANEL IS LIVE!**

---

## 📱 MOBILE APP

Your mobile app can now connect to the live API!

Just update the API URL in your Flutter app:
```dart
// apps/mobile/lib/core/config/env.dart
// Change API_BASE_URL to your Railway URL
```

Then run the emulator - it will connect to the live backend!

---

## ⚠️ WHAT'S MOCK (Working but not real)

- **SMS OTP**: Check Railway logs for OTP codes (any code works)
- **Firebase Push**: No notifications sent
- **KYC**: Auto-approves everything
- **File Storage**: Lost on redeploy (use S3 for production)

These work fine for testing! Upgrade when ready for customers.

---

## 💰 CURRENT COST

- Railway: **$5/month**
- Vercel: **Free**
- **Total: $5/month**

Everything else is pay-per-use when you add real services.

---

## ✅ YOU'RE READY

Open `railway-secrets.txt` and paste into Railway.

**Total time: ~10 minutes from now to fully deployed!** 🚀
