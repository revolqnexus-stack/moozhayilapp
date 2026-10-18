# Razorpay Integration - Quick Testing Guide

## Quick Start (5 minutes)

### Step 1: Start the API Server

```bash
cd apps/api
npm install  # First time only
npm run dev
```

The server should start on `http://localhost:3080`

### Step 2: Open Test Page

Open this file in your browser:
```
apps/api/test-razorpay.html
```

Or use a local web server:
```bash
# Option 1: Python
cd apps/api
python -m http.server 8000
# Then open: http://localhost:8000/test-razorpay.html

# Option 2: Node.js http-server
npx http-server apps/api -p 8000
# Then open: http://localhost:8000/test-razorpay.html

# Option 3: VS Code Live Server extension
# Right-click test-razorpay.html → Open with Live Server
```

### Step 3: Get an Auth Token

You need a valid JWT token. Options:

#### Option A: Use Mobile App (Easiest)
1. Build and run the Flutter mobile app
2. Sign in with your phone number
3. Token is stored automatically

#### Option B: Create a Test User via API

```bash
# 1. Request OTP
curl -X POST http://localhost:3080/api/auth/request-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+919876543210"}'

# 2. Check console logs for OTP (development mode logs it)
# Look for: "OTP for +919876543210: 123456"

# 3. Verify OTP and get token
curl -X POST http://localhost:3080/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+919876543210",
    "otp": "123456"
  }'

# Response will include:
# {
#   "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "refresh_token": "..."
# }
```

#### Option C: Use Mock Development Token

For development only, you can bypass auth by modifying the test page:

```javascript
// In test-razorpay.html, comment out token requirement:
// if (!token) { ... }
```

### Step 4: Test Payment

1. Enter amount (e.g., 500 for ₹500)
2. Paste your JWT token
3. Click "Pay Now"
4. Use test card: `4111 1111 1111 1111`
5. CVV: `123`, Expiry: `12/26`

## Test Scenarios

### Successful Payment

```
Card: 4111 1111 1111 1111
CVV: 123
Expiry: 12/26
```

**Expected Flow:**
1. ✅ Order created on backend
2. ✅ Razorpay modal opens
3. ✅ Payment processed
4. ✅ Signature verified
5. ✅ Payment captured
6. ✅ Success message shown

### Failed Payment

```
Card: 4012 0010 3714 1112
CVV: 123
Expiry: 12/26
```

**Expected Flow:**
1. ✅ Order created on backend
2. ✅ Razorpay modal opens
3. ❌ Payment fails
4. ✅ Error message shown
5. ✅ Order remains unpaid

### User Cancels Payment

1. Open payment modal
2. Click "X" or back button
3. ✅ Modal closes
4. ✅ "Payment cancelled" message shown
5. ✅ Order remains unpaid

## API Testing (Command Line)

### Test Order Creation

```bash
# Replace YOUR_TOKEN with actual JWT token
export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Create a test order
curl -X POST http://localhost:3080/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {
        "product_id": "existing-product-id",
        "quantity": 1
      }
    ],
    "delivery_address_id": "existing-address-id",
    "use_gold_balance": false
  }'
```

**Expected Response:**
```json
{
  "order": {
    "id": "order-uuid",
    "order_number": "MZ20260001",
    "status": "pending_payment",
    ...
  },
  "payment_required": true,
  "payment_session_id": "txn-uuid",
  "razorpay_order_id": "order_Mxxxxxxxxxxxx",
  "razorpay_key_id": "rzp_test_YOUR_KEY_ID",
  "payment_amount_paise": 50000
}
```

### Test Payment Verification

```bash
# After completing payment in Razorpay modal, you'll receive:
# - razorpay_order_id
# - razorpay_payment_id
# - razorpay_signature

curl -X POST http://localhost:3080/api/payments/verify-razorpay \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "razorpay_order_id": "order_Mxxxxxxxxxxxx",
    "razorpay_payment_id": "pay_Nxxxxxxxxxxxx",
    "razorpay_signature": "abcd1234..."
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "already_captured": false,
  "payment_id": "txn-uuid"
}
```

## Troubleshooting

### "Missing access token" Error

**Problem:** No JWT token provided or invalid token

**Solution:**
1. Follow Step 3 above to get a valid token
2. Ensure token is not expired (15 min lifetime)
3. Check token format: `Bearer eyJ...`

### "Payment method does not exist"

**Problem:** Trying to create an order without products/addresses

**Solution:**
1. Create products first via admin panel
2. Create user address via mobile app or API
3. Use valid UUIDs in test requests

### "Razorpay credentials are not configured"

**Problem:** Backend can't find Razorpay keys

**Solution:**
1. Check `apps/api/.env` file exists
2. Verify these lines are present:
   ```
   RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
   RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_SECRET
   PAYMENT_PROVIDER=razorpay
   PAYMENT_PROVIDER_MODE=live
   ```
3. Restart the API server: `npm run dev`

### Razorpay Modal Doesn't Open

**Problem:** JavaScript error or network issue

**Solution:**
1. Open browser DevTools (F12)
2. Check Console tab for errors
3. Verify `checkout.js` loaded:
   - Network tab → Filter: `checkout.razorpay.com`
   - Should see 200 OK response
4. Check CORS settings in backend `.env`:
   ```
   CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3080,http://localhost:8000
   ```

### "Invalid signature" Error

**Problem:** Signature verification failed

**Solution:**
1. Ensure backend has correct `RAZORPAY_KEY_SECRET`
2. Don't modify signature from Razorpay response
3. Check network tab - signature should match exactly
4. Restart API server after `.env` changes

### Payment Stuck in "Processing"

**Problem:** Verification endpoint not called

**Solution:**
1. Check if `handler` callback is triggered
2. Verify token is still valid (not expired)
3. Check network tab for `/verify-razorpay` call
4. Look for JavaScript errors in console

## Development Tips

### Mock Mode

For faster development without real payments:

```bash
# In apps/api/.env
PAYMENT_PROVIDER_MODE=mock
```

This will:
- Skip actual Razorpay API calls
- Auto-capture payments immediately
- Use mock order IDs
- Skip signature verification

⚠️ **Only use in development!**

### Debug Logging

Enable detailed logs:

```bash
# In apps/api/.env
LOG_LEVEL=debug
```

Then check console output for detailed flow:
```
[payment] Creating Razorpay order: amount=50000, receipt=order-uuid
[payment] Razorpay order created: order_Mxxxxxxxxxxxx
[payment] Verifying signature: orderId=order_M..., paymentId=pay_N...
[payment] Signature valid, capturing payment
[payment] Payment captured: txn-uuid
```

### Database Inspection

Check payment records:

```bash
# Connect to database
psql postgresql://postgres:postgres@localhost:5432/moozhayil

# Check orders
SELECT id, order_number, status, total_amount_paise 
FROM "Order" 
ORDER BY created_at DESC 
LIMIT 10;

# Check payment transactions
SELECT id, status, amount_paise, provider_order_id, provider_payment_id
FROM "PaymentTransaction"
ORDER BY created_at DESC
LIMIT 10;
```

## Next Steps

Once basic testing works:

1. **Test with Mobile App**
   - Run Flutter app: `cd apps/mobile && flutter run`
   - Complete full checkout flow
   - Test error scenarios

2. **Test Webhooks** (Optional)
   - Set up ngrok: `ngrok http 3080`
   - Configure webhook in Razorpay Dashboard
   - Add webhook secret to `.env`
   - Test webhook events

3. **Production Checklist**
   - [ ] Replace test keys with live keys
   - [ ] Add RAZORPAY_WEBHOOK_SECRET
   - [ ] Test with real card (1 rupee)
   - [ ] Set PAYMENT_PROVIDER_MODE=live
   - [ ] Enable proper error monitoring
   - [ ] Test refund flow

## Support

If you encounter issues:

1. **Check API logs** - most errors are logged
2. **Review this guide** - covers common issues
3. **Check Razorpay Dashboard** - see actual payment status
4. **Test with curl** - isolate frontend vs backend issues

## Quick Reference

### Test Card Numbers

| Purpose | Number | CVV | Expiry |
|---------|--------|-----|--------|
| ✅ Success | 4111 1111 1111 1111 | 123 | 12/26 |
| ❌ Failure | 4012 0010 3714 1112 | 123 | 12/26 |

### Test UPI IDs

- ✅ Success: `success@razorpay`
- ❌ Failure: `failure@razorpay`

### Key Endpoints

- `POST /api/auth/request-otp` - Request OTP
- `POST /api/auth/verify-otp` - Verify OTP, get token
- `POST /api/orders` - Create order (returns razorpay_order_id)
- `POST /api/payments/verify-razorpay` - Verify payment signature

### Environment Variables

```bash
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_SECRET
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
```
