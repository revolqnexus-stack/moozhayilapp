# 🔐 Generate Secrets Securely - Step by Step

**IMPORTANT**: Never share these secrets with anyone. Keep them secure in Railway only.

---

## ⚡ Quick Method (Recommended)

Open your terminal and run this **once**:

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Run it **6 times** and save each output:

1st run → **JWT_SECRET**  
2nd run → **JWT_REFRESH_SECRET**  
3rd run → **OTP_HASH_SECRET**  
4th run → **PII_ENCRYPTION_SECRET**  
5th run → **ADMIN_JWT_SECRET**  
6th run → **RAZORPAY_WEBHOOK_SECRET**

---

## 📝 Save Your Secrets (Offline)

Create a **local file** (NOT in Git) called `secrets.txt`:

```
JWT_SECRET=<paste 1st output here>
JWT_REFRESH_SECRET=<paste 2nd output here>
OTP_HASH_SECRET=<paste 3rd output here>
PII_ENCRYPTION_SECRET=<paste 4th output here>
ADMIN_JWT_SECRET=<paste 5th output here>
RAZORPAY_WEBHOOK_SECRET=<paste 6th output here>
```

**⚠️ Keep this file safe and NEVER commit it to Git!**

---

## 🚂 Add to Railway Dashboard

1. **Go to Railway**: https://railway.app/project/your-project-id
2. **Click your API service**
3. **Click "Variables" tab**
4. **Click "Raw Editor"** button
5. **Open** `RAILWAY_ENV_VARIABLES.txt` (in your project)
6. **Copy everything** and paste into Railway
7. **Replace** all `<GENERATE_AND_PASTE_HERE>` with your actual secrets from above
8. **Click "Save"**

---

## ✅ What Each Secret Does

| Secret | Purpose | Risk if leaked |
|--------|---------|----------------|
| **JWT_SECRET** | Signs user login tokens | Anyone can fake login as any user |
| **JWT_REFRESH_SECRET** | Signs refresh tokens | Anyone can stay logged in forever |
| **OTP_HASH_SECRET** | Hashes OTP codes | Attacker could guess OTPs |
| **PII_ENCRYPTION_SECRET** | Encrypts phone/address | Anyone can decrypt user data |
| **ADMIN_JWT_SECRET** | Signs admin login tokens | Anyone can fake admin access |
| **RAZORPAY_WEBHOOK_SECRET** | Verifies payment webhooks | Fake payment confirmations |

**Keep them secret. Keep them safe.** 🔒

---

## 🔄 If You Accidentally Leak a Secret

1. **Generate new secrets** (run the command again)
2. **Update Railway variables** immediately
3. **Redeploy** (Railway auto-redeploys on variable change)
4. **All users will need to login again** (old tokens are invalid)

---

## ⚠️ Security Best Practices

**DO** ✅:
- Generate secrets locally on your machine
- Keep secrets in Railway/secure vault only
- Use different secrets for staging vs production
- Rotate secrets every 6-12 months
- Use strong, random values (never use simple passwords)

**DON'T** ❌:
- Share secrets with anyone (including AI assistants!)
- Commit secrets to Git
- Reuse the same secret across different apps
- Use weak/predictable values like "secret123"
- Store secrets in code or config files

---

## 🎯 Alternative: PowerShell Method (Windows)

If you prefer PowerShell:

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

Run this **6 times** for each secret.

---

## 🎯 Alternative: Online Generator (Last Resort)

If you can't run Node.js:

1. Visit: https://generate-secret.vercel.app/32
2. Click "Generate" **6 times**
3. Save each output as described above

**Note**: Always prefer generating locally when possible.

---

## ✅ Checklist

After generating and adding secrets:

- [ ] Generated 6 random secrets using Node.js
- [ ] Saved secrets in local file (not in Git)
- [ ] Added all secrets to Railway variables
- [ ] Replaced all `<GENERATE_AND_PASTE_HERE>` placeholders
- [ ] Clicked "Save" in Railway
- [ ] Railway started redeploying
- [ ] Deleted local `secrets.txt` file (or moved to password manager)

---

## 🚀 What Happens Next

Once you save variables in Railway:

1. ✅ Railway redeploys your API automatically
2. ✅ Database migrations run
3. ✅ API starts with new secrets
4. ✅ Health check passes
5. ✅ You can create admin user

---

**Generate your secrets now, then follow the Railway setup steps!** 🔐
