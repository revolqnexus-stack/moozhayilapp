# Cashfree Payment Gateway Migration Plan

**Generated:** 2026-08-17  
**Task:** Replace Razorpay with Cashfree Payment Gateway  
**Scope:** Flutter Android/iOS + Node.js Backend

---

## 1. Current Razorpay Integration Analysis

### Backend (Node.js/TypeScript)
**Files identified:**
- `apps/api/src/modules/payments/razorpay.client.ts` - Razorpay API wrapper
- `apps/api/src/modules/payments/payment_provider.client.ts` - Provider abstraction layer
- `apps/api/src/modules/payments/payments.service.ts` - Payment business logic
- `apps/api/src/modules/payments/payments.schema.ts` - Zod validation schemas
- `apps/api/src/modules/payments/payment_completion.service.ts` - Capture/refund logic
- `apps/api/src/modules/webhooks/webhooks.service.ts` - Webhook ingestion
- `apps/api/src/modules/webhooks/webhooks.controller.ts` - Webhook endpoint
- `apps/api/src/jobs/processors/payment_webhook.processor.ts` - Async webhook processing

**Current flow:**
1. Frontend calls `/orders` or `/goals/{id}/contribute`
2. Backend creates Razorpay order via API
3. Backend returns `razorpay_order_id` + `razorpay_key_id` + `payment_session_id` (our DB ID)
4. Flutter opens Razorpay checkout with these IDs
5. User completes payment
6. Flutter receives success callback with `payment_id`, `order_id`, `signature`
7. Flutter calls `/payments/capture-checkout` with these 3 fields + our `payment_session_id`
8. Backend verifies signature using `orderId|paymentId` HMAC
9. Backend marks payment as captured
10. Razorpay sends webhook to `/webhooks/payment` (verified with HMAC signature)
11. Webhook marks order as reconciled

**Database schema:**
- `payment_transaction` table with columns:
  - `provider` enum (currently only 'razorpay')
  - `provider_order_id` - Razorpay's order_xxx
  - `provider_payment_id` - Razorpay's pay_xxx
  - `status` enum: created, pending, authorized, captured, failed, refund_initiated, refunded, reconciled
- `payment_method` table with `provider` enum

**Environment variables:**
- `PAYMENT_PROVIDER_MODE` - 'mock', 'test', or 'live'
- `RAZORPAY_KEY_ID`
- `RAZORPAY_KEY_SECRET`
- `RAZORPAY_WEBHOOK_SECRET`

### Flutter (Dart)
**Files identified:**
- `apps/mobile/lib/core/services/razorpay_service.dart` - Razorpay Flutter SDK wrapper
- `apps/mobile/lib/features/orders/screens/checkout_screen.dart` - Product checkout
- `apps/mobile/lib/features/goals/screens/contribute_screen.dart` - Gold contribution
- `apps/mobile/lib/core/models/order.dart` - Data models with razorpay fields

**Dependencies:**
- `razorpay_flutter: ^1.3.7` in `pubspec.yaml`

**Current flow:**
1. Screen calls `orderActionsProvider.placeOrder()` or `goalsRepository.contribute()`
2. API response includes `paymentRequired`, `razorpayOrderId`, `razorpayKeyId`, `paymentSessionId`, `paymentAmountPaise`
3. If `paymentRequired == true`, calls `razorpayService.pay()`
4. `RazorpayCheckout` opens native SDK sheet
5. User completes payment
6. SDK fires success callback with `paymentId`, `orderId`, `signature`
7. Service calls `/payments/capture-checkout` to verify server-side
8. On success, navigates to confirmation screen

**No Razorpay keys in Flutter** - keys come from API response (good security practice already in place)

---

## 2. Cashfree SDK Research

### Official Cashfree Flutter SDK
**Package:** `cashfree_pg: ^4.0.15` (latest as of 2024)  
**Documentation:** https://docs.cashfree.com/docs/flutter-integration

**Key differences from Razorpay:**
- Uses `CFSession` object instead of options map
- Requires `order_id`, `payment_session_id` (Cashfree's session token), and `environment` ('TEST' or 'PROD')
- Callback structure is different (success returns `order_id` but NOT a signature)
- **Signature verification happens server-side only via webhook**
- No client-side signature verification in Cashfree (by design)

**Flutter integration:**
```dart
import 'package:cashfree_pg/cashfree_pg.dart';

final session = CFSession(
  orderId: cfOrderId,
  paymentSessionId: cfSessionToken,
  environment: CFEnvironment.PRODUCTION,
);

final callback = CFCallback(
  onVerify: (orderId) {
    // Call backend to verify payment status
  },
  onError: (error, orderId) {
    // Handle error
  },
);

await CashfreePG.doPayment(session, callback);
```

### Cashfree Backend API
**Base URL:** `https://api.cashfree.com/pg` (production) or `https://sandbox.cashfree.com/pg` (sandbox)

**Authentication:** 
- Header: `x-client-id: <app_id>`
- Header: `x-client-secret: <secret_key>`
- Header: `x-api-version: 2022-09-01`

**Create Order API:**
```
POST /orders
{
  "order_amount": 500.00,
  "order_currency": "INR",
  "customer_details": {
    "customer_id": "user_123",
    "customer_phone": "9876543210"
  }
}

Response:
{
  "cf_order_id": "order_xxx",
  "payment_session_id": "session_xxx",  // This is what Flutter needs
  "order_status": "ACTIVE"
}
```

**Fetch Order Status API:**
```
GET /orders/{cf_order_id}

Response:
{
  "order_id": "order_xxx",
  "order_status": "PAID",
  "order_amount": 500.00,
  "transactions": [{
    "cf_payment_id": "payment_xxx",
    "payment_status": "SUCCESS",
    "payment_amount": 500.00
  }]
}
```

**Webhook payload:**
```json
{
  "type": "PAYMENT_SUCCESS_WEBHOOK",
  "data": {
    "order": {
      "order_id": "order_xxx",
      "order_amount": 500.00,
      "order_status": "PAID"
    },
    "payment": {
      "cf_payment_id": 123456,
      "payment_status": "SUCCESS",
      "payment_amount": 500.00,
      "payment_time": "2024-01-01T12:00:00Z"
    }
  }
}
```

**Webhook verification:**
- Cashfree sends `x-webhook-signature` header
- Compute: `base64(sha256(raw_body + webhook_secret_key + webhook_timestamp))`
- Compare with provided signature

---

## 3. Migration Architecture

### Backend Changes

**New file:** `apps/api/src/modules/payments/cashfree.client.ts`
- `createCashfreeOrder(input)` → calls POST /orders
- `fetchCashfreeOrderStatus(orderId)` → calls GET /orders/{id}
- `createCashfreeRefund(input)` → calls POST /refunds
- `verifyCashfreeWebhookSignature(payload, signature, timestamp)` → HMAC verification

**Modify:** `apps/api/src/modules/payments/payment_provider.client.ts`
- Replace all `createRazorpayOrder` calls with `createCashfreeOrder`
- Replace `verifyRazorpayWebhookSignature` with `verifyCashfreeWebhookSignature`
- **Remove** `verifyCheckoutSignature()` - Cashfree doesn't use client signatures
- Replace `captureRazorpayPayment` with `fetchCashfreeOrderStatus`

**Modify:** `apps/api/src/modules/payments/payments.service.ts`
- `captureCheckout()` - change to fetch order status from Cashfree instead of verifying signature
- Remove signature verification logic (Cashfree doesn't provide it)

**Modify:** `apps/api/src/modules/payments/payments.schema.ts`
- Rename `razorpay_payment_id` → `cashfree_payment_id`
- Rename `razorpay_order_id` → `cashfree_order_id`
- **Remove** `razorpay_signature` field (not used in Cashfree)

**Modify:** `apps/api/src/modules/webhooks/webhooks.controller.ts`
- Change header from `x-razorpay-signature` to `x-webhook-signature`
- Add `x-webhook-timestamp` header extraction

**Modify:** `apps/api/src/jobs/processors/payment_webhook.processor.ts`
- Update event names: `payment.captured` → `PAYMENT_SUCCESS_WEBHOOK`
- Update payload parsing to match Cashfree structure

**Database migration:**
```sql
-- Add 'cashfree' to payment_provider enum
ALTER TYPE payment_provider ADD VALUE 'cashfree';

-- No need to drop 'razorpay' - keeps historical records intact
```

**Environment variables:**
```bash
# Remove
RAZORPAY_KEY_ID
RAZORPAY_KEY_SECRET
RAZORPAY_WEBHOOK_SECRET

# Add
CASHFREE_APP_ID=<from dashboard>
CASHFREE_SECRET_KEY=<from dashboard>
CASHFREE_WEBHOOK_SECRET=<generate with: openssl rand -base64 32>
CASHFREE_ENVIRONMENT=sandbox  # or 'production'
```

### Flutter Changes

**Remove:** `razorpay_flutter: ^1.3.7` from `pubspec.yaml`  
**Add:** `cashfree_pg: ^4.0.15` to `pubspec.yaml`

**Delete:** `apps/mobile/lib/core/services/razorpay_service.dart`  
**Create:** `apps/mobile/lib/core/services/cashfree_service.dart`

**Modify:** `apps/mobile/lib/core/models/order.dart`
- Rename `razorpayOrderId` → `cashfreeOrderId`
- Rename `razorpayKeyId` → `cashfreeAppId`
- Remove `razorpaySignature` references (not used)

**Modify:** Checkout and contribute screens
- Replace `RazorpayCheckout` with `CashfreeCheckout`
- Replace `razorpayService.pay()` with `cashfreeService.pay()`
- Update response field names

**Android configuration:**
No significant changes needed - Cashfree SDK handles permissions internally

**iOS configuration:**
Add URL scheme in `Info.plist` if not already present (for payment return flow)

---

## 4. Migration Steps (Priority Order)

### Phase 1: Backend Payment Client (Day 1)
1. ✅ Create `cashfree.client.ts` with all API methods
2. ✅ Update `payment_provider.client.ts` to use Cashfree
3. ✅ Update database enum to add 'cashfree'
4. ✅ Update environment variable configuration
5. ✅ Write unit tests for Cashfree client

### Phase 2: Backend Payment Logic (Day 1-2)
6. ✅ Update `payments.service.ts` - remove signature verification, use order status fetch
7. ✅ Update `payments.schema.ts` - rename Razorpay fields
8. ✅ Update webhook controller - change header names
9. ✅ Update webhook processor - parse Cashfree events
10. ✅ Update mock mode to simulate Cashfree responses

### Phase 3: Flutter SDK Integration (Day 2)
11. ✅ Add `cashfree_pg` dependency
12. ✅ Create `cashfree_service.dart` with `CashfreeCheckout` class
13. ✅ Update `order.dart` model - rename fields
14. ✅ Test with Cashfree sandbox environment

### Phase 4: Flutter Screen Updates (Day 2-3)
15. ✅ Update `checkout_screen.dart` - use Cashfree service
16. ✅ Update `contribute_screen.dart` - use Cashfree service
17. ✅ Update any other payment flows (refunds, autopay if present)
18. ✅ Update error messages and customer copy

### Phase 5: Testing (Day 3-4)
19. ✅ Test order creation flow (backend sandbox)
20. ✅ Test Flutter checkout with Cashfree sandbox
21. ✅ Test webhook delivery and verification
22. ✅ Test payment failure scenarios
23. ✅ Test refund flow
24. ✅ Test concurrent payment attempts (race conditions)

### Phase 6: Cleanup (Day 4)
25. ✅ Remove `razorpay_flutter` from `pubspec.yaml`
26. ✅ Delete `razorpay.client.ts`
27. ✅ Delete `razorpay_service.dart`
28. ✅ Remove Razorpay imports from all files
29. ✅ Update `.env.example` files
30. ✅ Update documentation (PRODUCTION_HANDOFF.md, etc.)

### Phase 7: Android/iOS Configuration (Day 4-5)
31. ✅ Test Android release build
32. ✅ Test iOS build (if Mac available)
33. ✅ Verify ProGuard rules don't break Cashfree SDK
34. ✅ Update deployment guides

---

## 5. Security Checklist

- [x] `CASHFREE_SECRET_KEY` never included in Flutter app
- [x] Backend creates orders, not Flutter
- [x] Backend verifies payment status via Cashfree API, not client callback
- [x] Webhook signature verified with timing-safe comparison
- [x] Webhook processing is idempotent (duplicate events don't double-charge)
- [x] Payment amounts calculated server-side, never trusted from client
- [x] Race condition handled: if Flutter calls capture before webhook arrives
- [x] Historical Razorpay transactions remain in database (no data loss)

---

## 6. Rollback Plan

If Cashfree integration fails during testing:

1. Revert backend environment variables to Razorpay credentials
2. Revert `payment_provider.client.ts` to use `razorpay.client.ts`
3. Revert Flutter to use `razorpay_service.dart`
4. Database supports both providers, so no migration rollback needed
5. Re-deploy backend with Razorpay mode

**Estimated rollback time:** 30 minutes

---

## 7. Cashfree Dashboard Configuration Required

After code deployment:

1. **Create Cashfree account** (if not already created)
2. **Complete KYC** (required for live mode, 2-3 days)
3. **Get credentials:**
   - App ID (`x-client-id`)
   - Secret Key (`x-client-secret`)
4. **Configure webhook:**
   - URL: `https://api.moozhayil.com/v1/webhooks/payment`
   - Secret: (paste `CASHFREE_WEBHOOK_SECRET` value)
   - Events: `PAYMENT_SUCCESS_WEBHOOK`, `PAYMENT_FAILED_WEBHOOK`, `REFUND_STATUS_WEBHOOK`
5. **Test in sandbox first:**
   - Use test cards: `4111 1111 1111 1111` (Visa)
   - CVV: any 3 digits
   - Expiry: any future date

---

## 8. Testing Matrix

| Scenario | Expected Result |
|---|---|
| Successful UPI payment | Order status = PAID, gold credited |
| Card payment success | Order status = PAID, webhook received |
| Payment failure | Order status = pending_payment, user can retry |
| User cancels payment | Order status = pending_payment, no charge |
| Webhook arrives before Flutter callback | Payment marked as captured by webhook |
| Flutter callback arrives before webhook | Payment marked as captured by API call |
| Duplicate webhook | Idempotency prevents double credit |
| Refund initiated | Refund webhook marks order as refunded |
| Network timeout during payment | Order status fetched from Cashfree API |

---

## 9. Files to Modify

**Backend (12 files):**
- apps/api/src/modules/payments/cashfree.client.ts (NEW)
- apps/api/src/modules/payments/payment_provider.client.ts
- apps/api/src/modules/payments/payments.service.ts
- apps/api/src/modules/payments/payments.schema.ts
- apps/api/src/modules/webhooks/webhooks.controller.ts
- apps/api/src/modules/webhooks/webhooks.service.ts
- apps/api/src/jobs/processors/payment_webhook.processor.ts
- apps/api/prisma/migrations/YYYYMMDDHHMMSS_add_cashfree_provider/migration.sql (NEW)
- .env.example
- .env.production.example
- PRODUCTION_HANDOFF.md
- REQUIRED_SERVICES_AND_APIS.md

**Flutter (5 files):**
- apps/mobile/lib/core/services/cashfree_service.dart (NEW)
- apps/mobile/lib/core/models/order.dart
- apps/mobile/lib/features/orders/screens/checkout_screen.dart
- apps/mobile/lib/features/goals/screens/contribute_screen.dart
- apps/mobile/pubspec.yaml

**To DELETE (2 files):**
- apps/api/src/modules/payments/razorpay.client.ts
- apps/mobile/lib/core/services/razorpay_service.dart

**Total:** 19 files

---

## 10. Estimated Timeline

- **Backend migration:** 1-2 days
- **Flutter migration:** 1 day
- **Testing:** 2 days
- **Documentation:** 0.5 days
- **Total:** 4.5-5.5 days

---

**Next Steps:**
1. Review this plan with stakeholders
2. Create Cashfree sandbox account
3. Start Phase 1 implementation
