# 🎯 Setup Guide for Moozhayil Gold & Diamonds Client

**Dear Client,**

This guide will help you set up hosting for your jewelry e-commerce application. Once set up, the app will run automatically without needing the developer.

**Time needed:** 1 hour  
**Monthly cost:** $7-26  
**Technical skills:** None required (just follow steps)

---

## ✅ What You'll Get

- 📱 Mobile app on Google Play & App Store
- 💻 Backend running 24/7
- 💳 Razorpay payments working
- 📊 Admin dashboard
- 🔄 Automatic updates from GitHub

---

## 💳 Step 1: Prepare Your Credit/Debit Card

You'll need a credit or debit card for:
- **Render.com** ($7/month) - Required
- **Neon.tech** (Free tier, card optional)
- **Google Play** ($25 one-time)
- **Apple App Store** ($99/year)

**Note:** Hosting charges automatically every month. No manual payment needed.

---

## 🚀 Step 2: Set Up Hosting (Render.com)

### A. Create Account
1. Go to: https://render.com
2. Click "Sign Up"
3. Use your business email
4. Add your credit card when prompted

### B. Connect GitHub
1. Click "New +" → "Web Service"
2. Connect your GitHub account
3. Select repository: `revolqnexus-stack/moozhayilapp`
4. Click "Connect"

### C. Configure Service
Fill in these fields:
```
Name: moozhayil-api
Region: Singapore (closest to India)
Branch: main
Root Directory: apps/api
Build Command: npm ci && npm run build && npx prisma generate
Start Command: npm run start:prod
Instance Type: Starter ($7/month)
```

### D. Add Environment Variables
Your developer will provide a file called `PRODUCTION_ENV.txt`.

For each line in that file:
1. Click "Add Environment Variable"
2. Copy KEY (before the =)
3. Copy VALUE (after the =)
4. Click "Add"

Repeat for all ~30 variables.

### E. Deploy
1. Click "Create Web Service"
2. Wait 10 minutes for deployment
3. Note your URL: `https://moozhayil-api.onrender.com`

---

## 🗄️ Step 3: Set Up Database (Already Done!)

Your developer already set up:
- ✅ Neon.tech (PostgreSQL database)
- ✅ Upstash (Redis cache)

These are connected via environment variables.

---

## 📱 Step 4: Publish Mobile Apps

### Android (Google Play)
1. Create Google Play Developer account ($25 one-time)
2. Your developer provides `.aab` file
3. Upload to Play Console
4. Fill store listing:
   - App name: "Moozhayil Gold & Diamonds"
   - Description
   - Screenshots
   - Privacy policy URL
5. Submit for review (1-3 days)

### iOS (App Store)
1. Create Apple Developer account ($99/year)
2. Your developer provides `.ipa` file
3. Upload to App Store Connect
4. Fill store listing
5. Submit for review (1-3 days)

---

## 🔐 Step 5: Set Up Payment Gateway

### Razorpay
1. Create Razorpay account: https://razorpay.com
2. Complete business verification (GST, bank account)
3. Get LIVE API keys:
   - Settings → API Keys → Generate Key
4. Give keys to developer to update in Render
5. Set up bank account for settlements

**Test payments first with test keys before going live!**

---

## ✅ Step 6: Go Live Checklist

Before launching to customers:

- [ ] API is running (visit: `your-url.onrender.com/health`)
- [ ] Database is working (developer can verify)
- [ ] Razorpay test payment works
- [ ] Android app uploaded to Play Store
- [ ] iOS app uploaded to App Store
- [ ] Admin dashboard accessible
- [ ] Customer support ready

---

## 💰 Monthly Maintenance

### Auto-Paid (No Action Needed)
- Render: $7/month (auto-charged to your card)
- Neon: Free (or $19 if upgraded)
- Upstash: Free
- Cloudflare: Free

### Annual Renewals
- Domain name: ~$12/year
- Apple Developer: $99/year

---

## 🚨 What If Something Breaks?

### If Website/App Down:
1. Check Render dashboard - is service "Live"?
2. Check email for error notifications
3. Contact developer or hire new one

### If Payments Not Working:
1. Check Razorpay dashboard
2. Verify bank account is active
3. Check settlement schedule

### If Need Changes:
1. Hire Flutter developer
2. Give them GitHub access
3. They push changes → Auto-deploys to Render

---

## 📞 Support Contacts

- Render Support: support@render.com
- Razorpay Support: 1800-1234-5678
- Google Play: https://support.google.com/googleplay
- Apple: https://developer.apple.com/contact

---

## 🎓 Things to Know

### You DON'T Need to Know:
- ❌ How to code
- ❌ How servers work
- ❌ How databases work

### You DO Need to Know:
- ✅ How to login to Render dashboard
- ✅ How to check if service is "Live"
- ✅ How to restart service if it crashes
- ✅ Who to call if something breaks

---

## 💡 Cost Breakdown (First Year)

```
Setup Costs:
- Google Play account:    $25 (one-time)
- Apple Developer:        $99 (annual)
- Domain:                 $12 (annual)
──────────────────────────────
Setup Total:              $136

Monthly Costs:
- Render hosting:         $7
- (Everything else free)
──────────────────────────────
Monthly Total:            $7

FIRST YEAR TOTAL:         $136 + ($7 × 12) = $220
SUBSEQUENT YEARS:         $99 (Apple) + $12 (domain) + $84 (hosting) = $195/year
```

---

## ✅ Final Step: Test Everything

Before developer leaves:
1. ✅ Login to all accounts
2. ✅ Change all passwords
3. ✅ Test making a payment
4. ✅ Test admin dashboard
5. ✅ Download app from stores
6. ✅ Place a test order end-to-end

---

**Questions?** Ask your developer before they leave!

**Congratulations!** You now own a fully functional e-commerce platform! 🎉
