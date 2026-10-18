# 🔧 Set Up Cloudflare R2 (No Credit Card Required!)

## Good News! 
Cloudflare R2 is **FREE** up to 10GB and doesn't always require a credit card for basic usage.

---

## 📝 Step-by-Step Setup

### 1. Create R2 Bucket (5 minutes)

**Go to:** https://dash.cloudflare.com/28247e5c8e5aca83c94a869bdfbd0b6d/r2

1. Click **"Create bucket"**
2. Name: `moozhayil-media`
3. Location: **Automatic**
4. Click **"Create bucket"**

---

### 2. Generate API Token (3 minutes)

1. In R2 dashboard, click **"Manage R2 API Tokens"**
2. Click **"Create API Token"**
3. Fill in:
   ```
   Token name: Moozhayil API Access
   Permissions: Object Read & Write
   TTL: Forever (or 1 year)
   Specify bucket: moozhayil-media
   ```
4. Click **"Create API Token"**
5. **COPY IMMEDIATELY** (shown only once):
   - Access Key ID
   - Secret Access Key

---

### 3. Test Connection Locally

**Run this:**
```powershell
cd apps/api

# Set temporary environment variables (replace with YOUR keys)
$env:S3_ACCESS_KEY_ID="your_access_key_here"
$env:S3_SECRET_ACCESS_KEY="your_secret_key_here"

# Test R2 connection
node test-cloudflare-r2.js
```

**Expected output:**
```
🧪 Testing Cloudflare R2 Connection...
1️⃣ Testing credentials...
   ✅ Credentials valid!
2️⃣ Uploading test file...
   ✅ Upload successful!
3️⃣ Generating signed URL...
   ✅ Signed URL generated!
4️⃣ Reading file back...
   ✅ Content matches!

🎉 SUCCESS! R2 is configured correctly!
```

---

### 4. Add to Production ENV

Once tested, add these to your `PRODUCTION_ENV.txt`:

```env
STORAGE_BACKEND=s3
S3_ENDPOINT=https://28247e5c8e5aca83c94a869bdfbd0b6d.r2.cloudflarestorage.com
S3_REGION=auto
S3_BUCKET=moozhayil-media
S3_ACCESS_KEY_ID=your_access_key_here
S3_SECRET_ACCESS_KEY=your_secret_key_here
S3_PUBLIC_BASE_URL=https://pub-XXXXX.r2.dev
S3_FORCE_PATH_STYLE=false
```

---

## 🚀 Alternative: Skip R2 for Now

If you want to deploy **immediately without storage**, use local storage:

```env
STORAGE_BACKEND=local
KYC_UPLOAD_DIR=./uploads/kyc
MEDIA_UPLOAD_DIR=./uploads/media
```

⚠️ **Warning:** Local storage on Render will be wiped on every deploy!
Use this only for initial testing.

---

## 💡 What R2 is Used For

In your app:
- KYC documents (Aadhaar, PAN photos)
- Product images
- User profile pictures
- Banner images

**If you skip R2:** These features won't work until you add it.

---

## ✅ Ready?

1. **Got R2 keys?** → Test with `node test-cloudflare-r2.js`
2. **Skipping R2?** → Use `STORAGE_BACKEND=local` for now
3. **Can't access Cloudflare?** → Deploy without storage, add later

Pick your path and let's continue! 🚀
