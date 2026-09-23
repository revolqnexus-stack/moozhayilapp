# Razorpay Integration Guide

## Overview

This project has **full Razorpay Standard Web Checkout** integration with:
- ✅ Backend API endpoints for order creation and payment verification
- ✅ Signature verification using HMAC-SHA256
- ✅ Flutter mobile app integration with `razorpay_flutter`
- ✅ Test HTML page for web testing
- ✅ Proper error handling and security measures

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Client    │         │   Backend    │         │  Razorpay    │
│ (Web/Mobile)│         │   API        │         │   Server     │
└─────────────┘         └──────────────┘         └──────────────┘
       │                        │                        │
       │ 1. Create Order        │                        │
       ├───────────────────────>│                        │
       │                        │ 2. Create Razorpay     │
       │                        │    Order               │
       │                        ├───────────────────────>│
       │                        │<───────────────────────┤
       │ 3. Return order_id     │                        │
       │<───────────────────────┤                        │
       │                        │                        │
       │ 4. Open Razorpay       │                        │
       │    Checkout Modal      │                        │
       ├───────────────────────────────────────────────>│
       │                        │                        │
       │ 5. User completes      │                        │
       │    payment             │                        │
       │<───────────────────────────────────────────────┤
       │                        │                        │
       │ 6. Verify Signature    │                        │
       ├───────────────────────>│                        │
       │                        │ 7. Verify HMAC         │
       │                        │    signature           │
       │                        │ 8. Capture payment     │
       │ 9. Success Response    │                        │
       │<───────────────────────┤                        │
```

## Backend Implementation

### 1. Environment Variables

Located in: `apps/api/.env`

```bash
# Payment provider selection
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live  # Use 'live' for test/production keys, 'mock' for development

# Razorpay credentials (test mode)
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_SECRET
RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_here
```

⚠️ **Security Notes:**
- `.env` is in `.gitignore` - credentials are never committed
- `RAZORPAY_KEY_SECRET` is ONLY used on backend
- `RAZORPAY_KEY_ID` is exposed to frontend (safe - it's public)

### 2. Core Backend Files

#### Payment Client: `apps/api/src/modules/payments/razorpay.client.ts`

Handles all Razorpay API interactions:

```typescript
// Create order
export async function createRazorpayOrder(input: {
  amountPaise: number;
  receipt: string;
}): Promise<{ providerOrderId: string; amountPaise: number }>

// Capture payment
export async function captureRazorpayPayment(
  providerOrderId: string
): Promise<{ providerPaymentId: string; status: "captured" | "failed" }>

// Verify signature (checkout)
export function verifyRazorpayCheckoutSignature(input: {
  orderId: string;
  paymentId: string;
  signature: string;
}): boolean

// Verify webhook signature
export function verifyRazorpayWebhookSignature(
  payload: string,
  signature: string | undefined
): boolean
```

#### API Endpoints: `apps/api/src/modules/payments/payments.routes.ts`

```
POST /api/payments/verify-razorpay    - Verify payment signature
POST /api/payments/reconcile           - Admin: manual reconciliation
GET  /api/payments/methods             - List saved payment methods
POST /api/payments/methods             - Save payment method
DELETE /api/payments/methods/:id       - Remove payment method
```

### 3. Order Flow Integration

When creating orders or contributions, the system automatically:

1. Creates a Razorpay order via `paymentProviderClient.createOrder()`
2. Returns the `razorpay_order_id` and `razorpay_key_id` to the client
3. Client opens Razorpay checkout with these values
4. On success, client calls `/api/payments/verify-razorpay`
5. Backend verifies signature using HMAC-SHA256
6. If valid, captures the payment and updates order status

**Key Files:**
- `apps/api/src/modules/orders/orders.service.ts` - Order creation
- `apps/api/src/modules/contributions/contributions.service.ts` - Scheme contributions
- `apps/api/src/modules/payments/payment_completion.service.ts` - Payment capture logic

## Frontend Implementation

### 1. Web Test Page

**File:** `apps/api/test-razorpay.html`

To test the integration:

1. Start the API server:
   ```bash
   cd apps/api
   npm run dev
   ```

2. Open the test page:
   ```bash
   # Open in browser:
   file:///path/to/moozhayil-gold-diamonds/apps/api/test-razorpay.html
   ```

3. Get an auth token:
   - Use the mobile app or admin panel to login
   - Copy the JWT token from the response

4. Enter amount and token, click "Pay Now"

5. Use Razorpay test cards:
   - **Success:** `4111 1111 1111 1111` | CVV: `123` | Expiry: `12/26`
   - **Failure:** `4012 0010 3714 1112` | CVV: `123` | Expiry: `12/26`

### 2. Mobile App (Flutter)

**Key Files:**
- `apps/mobile/lib/core/services/razorpay_service.dart` - Razorpay integration service
- `apps/mobile/lib/features/orders/screens/checkout_screen.dart` - Order checkout
- `apps/mobile/lib/features/goals/screens/contribute_screen.dart` - Contribution payments

**Flow:**
```dart
// 1. Create order via API
final response = await ordersService.create(...);

// 2. Extract Razorpay details
final keyId = response.razorpayKeyId;
final orderId = response.razorpayOrderId;
final amount = response.paymentAmountPaise;

// 3. Open Razorpay checkout
final razorpayCheckout = RazorpayCheckout();
final result = await razorpayService.pay(
  context: context,
  checkout: razorpayCheckout,
  keyId: keyId,
  razorpayOrderId: orderId,
  amountPaise: amount,
  paymentSessionId: response.paymentSessionId,
);

// 4. Handle result
if (result is RazorpaySuccess) {
  // Payment verified on backend
  // Order status updated automatically
}
```

## Security Implementation

### 1. Signature Verification

**Algorithm:** HMAC-SHA256

```typescript
// Checkout signature verification
const message = `${orderId}|${paymentId}`;
const expected = createHmac("sha256", RAZORPAY_KEY_SECRET)
  .update(message)
  .digest("hex");

// Timing-safe comparison
return timingSafeEqual(
  Buffer.from(expected, "utf8"),
  Buffer.from(signature, "utf8")
);
```

### 2. Idempotency

Orders and payments use idempotency keys to prevent duplicate charges:

```typescript
const idempotencyKey = `order_payment:${orderId}`;
```

### 3. Amount Validation

- Minimum amount: 100 paise (₹1.00)
- All amounts stored in paise (integer) to avoid floating-point errors
- Backend validates amounts before creating Razorpay orders

### 4. Error Handling

```typescript
// Client-side
try {
  const rzp = new Razorpay(options);
  rzp.on('payment.failed', function (response) {
    console.error('Payment failed:', response.error);
    showError(response.error.description);
  });
  rzp.open();
} catch (error) {
  // Handle modal open failure
}

// Backend
if (!verifySignature(...)) {
  throw new AppError(400, "INVALID_SIGNATURE", 
    "Payment signature verification failed");
}
```

## Testing

### Test Credentials

```bash
# Test Key ID (public - safe to expose)
rzp_test_YOUR_KEY_ID

# Test Secret (private - never expose)
YOUR_RAZORPAY_SECRET
```

### Test Cards

| Purpose | Card Number | CVV | Expiry |
|---------|-------------|-----|--------|
| Success | 4111 1111 1111 1111 | 123 | 12/26 |
| Failure | 4012 0010 3714 1112 | 123 | 12/26 |

### Test UPI

- **Success:** `success@razorpay`
- **Failure:** `failure@razorpay`

### API Testing

```bash
# 1. Create an order (requires auth token)
curl -X POST http://localhost:3080/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "items": [{"product_id": "prod-123", "quantity": 1}],
    "delivery_address_id": "addr-123"
  }'

# Response includes:
# - razorpay_order_id: Use in checkout
# - razorpay_key_id: Use in checkout
# - payment_session_id: Use in verify call

# 2. Verify payment (after user completes checkout)
curl -X POST http://localhost:3080/api/payments/verify-razorpay \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "razorpay_order_id": "order_xxx",
    "razorpay_payment_id": "pay_xxx",
    "razorpay_signature": "signature_xxx"
  }'
```

## Deployment

### Environment Setup

**Development:**
```bash
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_RAZORPAY_SECRET
```

**Production:**
```bash
PAYMENT_PROVIDER=razorpay
PAYMENT_PROVIDER_MODE=live
RAZORPAY_KEY_ID=rzp_live_YOUR_LIVE_KEY_ID
RAZORPAY_KEY_SECRET=YOUR_LIVE_SECRET_KEY
RAZORPAY_WEBHOOK_SECRET=YOUR_WEBHOOK_SECRET
```

### Frontend Configuration

For mobile app (`apps/mobile/.env`):
```bash
# Flutter automatically uses the backend's key via API response
# No need to hardcode keys in mobile app
```

For web apps (if you add React/Vue/Angular):
```bash
# React (.env.local)
REACT_APP_RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID

# Next.js (.env.local)
NEXT_PUBLIC_RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID

# Vite (.env.local)
VITE_RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID
```

## Webhooks (Optional Enhancement)

Razorpay can send webhooks for payment events:

1. **Configure webhook in Razorpay Dashboard:**
   - URL: `https://your-domain.com/api/webhooks/razorpay`
   - Events: `payment.captured`, `payment.failed`, `order.paid`
   - Get webhook secret

2. **Already implemented in codebase:**
   - Endpoint: `apps/api/src/modules/webhooks/webhooks.routes.ts`
   - Handler: `apps/api/src/modules/webhooks/webhooks.service.ts`
   - Signature verification: `verifyRazorpayWebhookSignature()`

3. **Add webhook secret to `.env`:**
   ```bash
   RAZORPAY_WEBHOOK_SECRET=your_webhook_secret_from_dashboard
   ```

## Troubleshooting

### Payment Not Completing

1. **Check browser console** for JavaScript errors
2. **Verify RAZORPAY_KEY_ID** matches the test key
3. **Check API logs** for order creation errors
4. **Ensure CORS is configured** in backend `.env`:
   ```bash
   CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3080
   ```

### Signature Verification Failing

1. **Check orderId matches** - must be the `razorpay_order_id` from create order response
2. **Verify KEY_SECRET is correct** in backend `.env`
3. **Check for trailing/leading spaces** in env variables
4. **Ensure signature is not modified** during transmission

### "Razorpay credentials are not configured"

1. **Restart API server** after updating `.env`
2. **Verify .env location**: Should be `apps/api/.env`
3. **Check env loading**: Ensure `dotenv.config()` is called
4. **Check PAYMENT_PROVIDER_MODE**: Should be `live` for test keys

### Mobile App Issues

1. **Android:** Ensure Razorpay SDK permissions in `AndroidManifest.xml`
2. **iOS:** Ensure app transport security allows Razorpay domains
3. **Check pubspec.yaml:** Verify `razorpay_flutter` dependency
4. **Flutter build:** Run `flutter pub get` after adding dependency

## Additional Resources

- [Razorpay Docs](https://razorpay.com/docs/payments/payment-gateway/web-integration/standard/)
- [Test Cards](https://razorpay.com/docs/payments/payments/test-card-details/)
- [Webhook Integration](https://razorpay.com/docs/webhooks/)
- [Error Codes](https://razorpay.com/docs/api/errors/)

## Support

For issues with the integration:
1. Check API logs: `cd apps/api && npm run dev`
2. Review test file: `apps/api/test-razorpay.html`
3. Test with curl commands above
4. Check Razorpay Dashboard for payment status
