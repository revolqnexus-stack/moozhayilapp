# 📦 Moozhayil App - Handover Documentation

## 🎯 Overview
This document allows anyone to maintain the Moozhayil Gold & Diamonds application after the original developer leaves.

---

## 🏗️ System Architecture

```
Users' Phones (Android/iOS)
        ↓
Flutter Mobile App (from app stores)
        ↓
Backend API (Render.com)
        ↓
Database (Neon.tech PostgreSQL)
Redis (Upstash)
Storage (Cloudflare R2)
```

---

## 💰 Monthly Costs

| Service | Cost | Purpose |
|---------|------|---------|
| Render.com | $7 | API hosting |
| Neon.tech | $0-19 | Database |
| Upstash | $0 | Redis cache |
| Cloudflare | $0 | File storage |
| **Total** | **$7-26/month** | |

---

## 🔑 Critical Accounts & Access

### 1. **GitHub Repository**
- URL: https://github.com/revolqnexus-stack/moozhayilapp
- Contains: All source code
- Auto-deploys: Yes (connected to Render)

### 2. **Render.com** (API Hosting)
- URL: https://dashboard.render.com
- Service Name: moozhayil-api
- What it does: Runs the backend 24/7
- If down: Check dashboard for errors

### 3. **Neon.tech** (Database)
- URL: https://neon.tech
- Database: moozhayil
- What it stores: Users, orders, products, payments

### 4. **Upstash** (Redis)
- URL: https://upstash.com
- What it does: Caches data, manages background jobs

### 5. **Cloudflare** (Storage)
- URL: https://dash.cloudflare.com
- Bucket: moozhayil-media
- What it stores: Product images, KYC documents

### 6. **Razorpay** (Payments)
- URL: https://dashboard.razorpay.com
- What it does: Processes customer payments
- Important: Check this weekly for settlement issues

### 7. **Google Play Console**
- URL: https://play.google.com/console
- What it does: Android app distribution

### 8. **Apple App Store Connect**
- URL: https://appstoreconnect.apple.com
- What it does: iOS app distribution

---

## 🚨 Emergency Procedures

### **If App is Down:**

1. **Check Render.com Status**
   - Login → Check "Live" status
   - Look at "Logs" for errors
   - If crashed → Click "Manual Deploy"

2. **Check Database**
   - Login to Neon.tech
   - Ensure database is not paused
   - Free tier pauses after inactivity

3. **Check Redis**
   - Login to Upstash
   - Verify connection is active

### **If Payments Not Working:**

1. **Check Razorpay Dashboard**
   - Login → Check "Live Mode" is ON
   - Verify API keys are valid
   - Check settlement account

2. **Check Backend Logs**
   - Render → Logs
   - Search for "RAZORPAY" errors

### **If Database Full:**

1. Upgrade Neon plan ($19/month)
2. Or clean old data (with caution!)

---

## 🔄 How to Update the App

### **Backend Updates** (Automatic)
```
Code pushed to GitHub → Render auto-deploys → Live in 5 minutes
```

### **Flutter App Updates**
1. Get code from GitHub
2. Make changes
3. Build new version:
   ```bash
   flutter build appbundle --release  # Android
   flutter build ipa --release        # iOS
   ```
4. Upload to Google Play / App Store
5. Users get update automatically

---

## 📞 Who to Contact

### **Technical Issues:**
- Render Support: support@render.com
- Neon Support: https://neon.tech/docs/community
- Razorpay Support: 1800-123-456-7890

### **Hire a Developer:**
If you need changes, hire a Flutter/Node.js developer with:
- Flutter experience (for mobile app)
- Node.js/TypeScript (for backend)
- PostgreSQL/Prisma (for database)

Show them this documentation + GitHub repo.

---

## 💾 Backup Procedures

### **Database Backups** (Automatic)
- Neon: Automated daily backups (7 days retention)
- Manual: Dashboard → Backup → Download

### **Code Backups**
- GitHub: All code versioned
- Download: Click "Code" → "Download ZIP"

---

## 🔐 Security

### **Passwords to Change Immediately:**
1. Render.com account password
2. Razorpay dashboard password
3. GitHub access (add your email as owner)

### **Never Share Publicly:**
- Database URL
- Redis URL
- Razorpay API keys
- Any passwords

---

## 📊 Monitoring

### **What to Check Weekly:**
1. Render Dashboard - Is API "Live"?
2. Razorpay Dashboard - Any failed payments?
3. Google Play Console - Any app crashes?
4. App Store Connect - Any reviews mentioning bugs?

### **What to Check Monthly:**
1. Hosting bill paid?
2. Domain renewed?
3. Database size (upgrade if near limit)

---

## 🎓 Learn More

- Flutter Docs: https://flutter.dev/docs
- Node.js Docs: https://nodejs.org/docs
- Prisma Docs: https://prisma.io/docs
- Render Docs: https://render.com/docs

---

## ✅ Handover Checklist

- [ ] All account credentials documented
- [ ] Credit card set up for auto-payment
- [ ] GitHub access transferred
- [ ] Render.com account in client's name
- [ ] Razorpay account in client's name
- [ ] Google Play Console access
- [ ] App Store Connect access
- [ ] Test app end-to-end after handover
- [ ] Emergency contact list provided

---

## 📝 Environment Variables (Backup)

Keep these safe - needed if you ever re-deploy:

```
[Copy from PRODUCTION_ENV.txt]
```

---

**Last Updated:** [Date]  
**Created By:** [Your Name]  
**Client:** Moozhayil Gold & Diamonds
