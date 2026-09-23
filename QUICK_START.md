# ⚡ Razorpay Quick Start Guide

## 🎯 Test in 3 Steps (2 minutes)

### Step 1: Start Server
```bash
cd apps/api
npm run dev
```

### Step 2: Open Test Page
```
Open: apps/api/test-razorpay.html
```

### Step 3: Test Payment
- **Amount:** 500
- **Card:** 4111 1111 1111 1111
- **CVV:** 123
- **Expiry:** 12/26

---

## 🧪 Test Credentials

### Cards
```
✅ Success: 4111 1111 1111 1111 | CVV: 123 | Exp: 12/26
❌ Failure: 4012 0010 3714 1112 | CVV: 123 | Exp: 12/26
```

### UPI
```
✅ Success: success@razorpay
❌ Failure: failure@razorpay
```

### Keys (Already Configured)
```
KEY_ID:     rzp_test_YOUR_KEY_ID
KEY_SECRET: YOUR_RAZORPAY_SECRET
```

---

## 🔍 Verify Setup

```bash
cd apps/api
node verify-razorpay-setup.js
```

Expected output:
```
✅ Razorpay is properly configured!
🧪 Mode: TEST (safe for development)
🚀 Ready to test!
```

---

## 📡 API Endpoints

### Create Order
```bash
POST /api/orders
Authorization: Bearer {token}
```
Returns: `razorpay_order_id`

### Verify Payment
```bash
POST /api/payments/verify-razorpay
Authorization: Bearer {token}
```
Returns: `{ success: true }`

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| Server won't start | `npm install` then `npm run dev` |
| No credentials | Check `apps/api/.env` file exists |
| Modal doesn't open | Open browser console, check errors |
| Token missing | See TESTING_GUIDE.md for auth |

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| **INTEGRATION_SUMMARY.md** | Complete overview |
| **RAZORPAY_INTEGRATION.md** | Technical details |
| **TESTING_GUIDE.md** | Step-by-step testing |
| **RAZORPAY_SETUP_COMPLETE.md** | Setup summary |

---

## ✅ What's Working

- [x] Backend creates Razorpay orders
- [x] Frontend opens payment modal
- [x] Signature verification
- [x] Payment capture
- [x] Mobile app integration
- [x] Error handling
- [x] Test page ready

---

## 🎯 Next Steps

1. ✅ **Test now** - Use test page
2. 📱 **Mobile** - Test with Flutter app
3. 🔗 **Webhooks** - Configure in dashboard
4. 🚀 **Production** - Get live keys

---

## 🆘 Need Help?

1. **Quick fix:** Run `node verify-razorpay-setup.js`
2. **Testing:** Read `apps/api/TESTING_GUIDE.md`
3. **Technical:** Read `RAZORPAY_INTEGRATION.md`

---

## 🚀 Production Checklist

When ready for production:

- [ ] Get live keys from Razorpay Dashboard
- [ ] Update `.env`: `RAZORPAY_KEY_ID=rzp_live_...`
- [ ] Update `.env`: `RAZORPAY_KEY_SECRET=live_secret`
- [ ] Add webhook secret
- [ ] Test with ₹1 real payment
- [ ] Enable monitoring

---

**🎉 You're ready! Start testing now:**

```bash
cd apps/api && npm run dev
```

Then open `test-razorpay.html` in your browser.

---

*Integration Status: ✅ Complete*
*Test Mode: Active*
*Last Verified: January 2026*
