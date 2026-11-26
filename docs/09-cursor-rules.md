# 09 — Cursor Rules
## Moozhayil Gold & Diamonds — AI Coding Assistant Instructions

---

## PROJECT OVERVIEW

This is a Flutter mobile app (iOS + Android) with a Node.js/Express backend (REST API) and PostgreSQL database.

App name: Moozhayil Gold & Diamonds
Internal project name: `moozhayil`

---

## TECHNOLOGY STACK

### Mobile (Flutter)
- Flutter SDK: latest stable
- State management: Riverpod (use `@riverpod` code generation)
- Navigation: go_router
- HTTP client: Dio with interceptors
- Local storage: flutter_secure_storage (tokens), Hive (cache)
- Image loading: cached_network_image
- SVG rendering: flutter_svg
- Animations: standard Flutter AnimationController + Implicit animations
- Form validation: reactive_forms
- Code generation: build_runner, freezed, json_serializable

### Backend (Node.js)
- Runtime: Node.js 20 LTS
- Framework: Express 4
- ORM: Prisma
- Database: PostgreSQL 15
- Auth: JWT (access + refresh token pattern)
- File storage: AWS S3 via @aws-sdk/client-s3
- Push notifications: Firebase Admin SDK
- Payment gateway: Razorpay
- Queue: Bull (Redis-backed) for async jobs
- Validation: Zod
- Logging: Winston + CloudWatch

### Infrastructure
- Database: AWS RDS PostgreSQL
- Storage: AWS S3 + CloudFront CDN
- Server: AWS EC2 or ECS
- Cache: AWS ElastiCache (Redis)

---

## FLUTTER PROJECT STRUCTURE

```
lib/
  main.dart
  app.dart                    // MaterialApp, router, providers
  
  core/
    constants/
      colors.dart             // All color tokens
      typography.dart         // All text styles
      spacing.dart            // All spacing values
      radii.dart              // Border radius values
      shadows.dart            // Shadow definitions
      animations.dart         // Duration + curve constants
    
    models/                   // Freezed data models
      user.dart
      goal.dart
      product.dart
      contribution.dart
      gold_balance.dart
      order.dart
      vault_item.dart
      notification.dart
      aura_session.dart
    
    services/
      api_service.dart        // Dio instance + interceptors
      auth_service.dart       // Token management
      storage_service.dart    // Secure + Hive storage
    
    utils/
      currency_formatter.dart // ₹ formatting
      gold_formatter.dart     // gram formatting
      date_formatter.dart     // date display helpers
      validators.dart         // form validation functions
    
  features/
    auth/
      screens/
        auth_screen.dart
        otp_screen.dart
      providers/
        auth_provider.dart
    
    onboarding/
      screens/
        splash_screen.dart
        intent_screen.dart
        name_screen.dart
        kyc_intro_screen.dart
      providers/
        onboarding_provider.dart
    
    home/
      screens/
        home_screen.dart
      widgets/
        greeting_card.dart
        goal_progress_ring_card.dart
        aura_insight_banner.dart
        hero_banner.dart
        quick_actions_row.dart
        occasion_discovery_row.dart
        dream_vault_preview_row.dart
        can_redeem_today_row.dart
        featured_collections_row.dart
        trust_anchors_row.dart
      providers/
        home_provider.dart
    
    shop/
      screens/
        shop_screen.dart
        search_screen.dart
        product_list_screen.dart
        product_detail_screen.dart
        collection_screen.dart
        occasion_screen.dart
      widgets/
        product_card.dart
        collection_card.dart
        occasion_chip.dart
        filter_bar.dart
        scheme_interstitial_card.dart
        product_image_gallery.dart
        product_specs_row.dart
        affordability_bridge.dart
        product_actions_bar.dart
      providers/
        products_provider.dart
        search_provider.dart
        product_detail_provider.dart
    
    vault/
      screens/
        dream_vault_screen.dart
      widgets/
        dream_vault_card.dart
        goal_start_bottom_sheet.dart
      providers/
        vault_provider.dart
    
    goals/
      screens/
        goals_screen.dart
        goal_detail_screen.dart
        goal_create/
          moment_screen.dart
          piece_screen.dart
          amount_screen.dart
          payment_screen.dart
          confirmation_screen.dart
      widgets/
        goal_card.dart
        completed_goal_card.dart
        milestone_timeline.dart
      providers/
        goals_provider.dart
        goal_create_provider.dart
    
    my_gold/
      screens/
        my_gold_screen.dart
        redeem_screen.dart
      widgets/
        my_gold_hero.dart
        gold_rate_row.dart
        gold_ledger.dart
        all_goal_rings_row.dart
        milestone_celebration_overlay.dart
      providers/
        gold_balance_provider.dart
    
    aura/
      screens/
        aura_screen.dart
        aura_conversation_screen.dart
        aura_goal_planning_screen.dart
        aura_product_discovery_screen.dart
        aura_gold_insights_screen.dart
      widgets/
        aura_action_card.dart
        aura_conversation_card.dart
        aura_option_button.dart
      providers/
        aura_provider.dart
    
    profile/
      screens/
        profile_screen.dart
        orders_screen.dart
        order_detail_screen.dart
        kyc_flow/
          kyc_landing_screen.dart
          aadhaar_screen.dart
          pan_screen.dart
          selfie_screen.dart
          kyc_review_screen.dart
          kyc_pending_screen.dart
      providers/
        profile_provider.dart
        kyc_provider.dart
    
    notifications/
      screens/
        notifications_screen.dart
      providers/
        notifications_provider.dart
  
  components/                  // Shared/reusable components
    navigation/
      top_app_bar.dart
      bottom_tab_bar.dart
      navigation_drawer.dart
    progress/
      progress_ring.dart
      linear_progress_bar.dart
    buttons/
      primary_button.dart
      secondary_button.dart
      ghost_button.dart
      destructive_button.dart
      wishlist_heart.dart
    inputs/
      text_input.dart
      slider_input.dart
      filter_bar.dart
    feedback/
      status_badge.dart
      loading_shimmer.dart
      empty_state.dart
      error_state.dart
      offline_banner.dart
    overlays/
      confirmation_bottom_sheet.dart
      sort_bottom_sheet.dart
      price_breakdown_sheet.dart
```

---

## CODING RULES

### Rule 1: Always use design tokens. Never hardcode values.

```dart
// WRONG
Container(
  color: Color(0xFFB8962E),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
)

// CORRECT
Container(
  color: AppColors.antiqueGold,
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card)),
)
```

### Rule 2: Every component must handle all its documented states.

When implementing any component from 03-component-library.md, implement ALL states listed.
Do not implement only the happy path.

```dart
// WRONG - only handles loaded state
class ProductCard extends StatelessWidget {
  final Product product;
  // only renders product
}

// CORRECT - handles all states
class ProductCard extends StatelessWidget {
  final Product? product;      // null = loading state
  final bool isLoading;
  final bool isOutOfStock;
  final bool isWishlisted;
  final bool isNewBadge;
  // etc.
}
```

### Rule 3: Use Freezed for all data models.

```dart
@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String name,
    required GoalType goalType,
    required GoalStatus status,
    Product? targetProduct,
    required double currentGrams,
    required double targetGrams,
    // ...
  }) = _Goal;
  
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}
```

### Rule 4: Use Riverpod for all state. No setState in production screens.

```dart
// WRONG - using StatefulWidget + setState for data
class HomeScreen extends StatefulWidget { ... }

// CORRECT - using ConsumerWidget + Riverpod
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    return homeState.when(
      loading: () => HomeScreenSkeleton(),
      error: (e, st) => ErrorState(onRetry: () => ref.refresh(homeProvider)),
      data: (data) => HomeScreenContent(data: data),
    );
  }
}
```

### Rule 5: Loading states use shimmer, not spinners.

```dart
// WRONG - spinner for content loading
if (isLoading) return CircularProgressIndicator();

// CORRECT - shimmer for content loading
if (isLoading) return ProductCardShimmer(); // matches exact dimensions of ProductCard
```

Spinners are used only for: button loading states, full-screen overlay loading (payment processing).

### Rule 6: Always handle errors in providers.

```dart
// Every provider that fetches data must catch errors
@riverpod
Future<List<Product>> products(ProductsRef ref, ProductFilter filter) async {
  try {
    final response = await ref.read(apiServiceProvider).getProducts(filter);
    return response.data;
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  } catch (e) {
    throw ApiException.unknown(e.toString());
  }
}
```

### Rule 7: All monetary values come from the API. Never compute prices client-side.

```dart
// WRONG - computing price on client
final price = product.weightGrams * goldRate * (1 + product.makingChargePct / 100);

// CORRECT - using server-computed price
final price = product.price.totalDisplay; // "₹84,966" from API
```

The exception: scheme monthly suggestion on product cards may be estimated client-side for display only, not for transactions.

### Rule 8: Navigation via go_router, not Navigator directly.

```dart
// WRONG
Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen()));

// CORRECT
context.push('/shop/product/$productId');
```

All routes are defined in `app.dart` as constants. Use route constants, not string literals.

```dart
// Define constants
abstract class AppRoutes {
  static const home = '/home';
  static const productDetail = '/shop/product/:id';
  // etc.
}

// Use in navigation
context.push(AppRoutes.productDetail.replaceFirst(':id', product.id));
```

### Rule 9: Cormorant Garamond for emotional content. DM Sans for functional content.

Refer to 02-design-system.md for the complete typography map.
Do not use Cormorant for buttons, labels, form fields, or metadata.
Do not use DM Sans for product names, goal names, Aura text, or hero headings.

### Rule 10: Progress ring animations use the specified duration and curve.

```dart
// Standard progress ring animation
AnimationController(
  duration: AppMotion.progressFill, // 800ms
  vsync: this,
)..forward();

CurvedAnimation(
  parent: controller,
  curve: AppMotion.standardInOut, // Curves.easeInOutCubic
)
```

Never use bounce or spring curves on progress rings.

### Rule 11: Gold values always show 1 decimal place. Never more, never less.

```dart
// Use the goldFormatter utility
GoldFormatter.display(37.4892) // returns "37.4g"
GoldFormatter.display(10.0)    // returns "10.0g" (not "10g")
```

### Rule 12: Monetary display uses Indian number formatting.

```dart
// Use the currencyFormatter utility
CurrencyFormatter.display(2336800) // returns "₹23,368" (input in paise)
CurrencyFormatter.display(84966000) // returns "₹84,966"
```

### Rule 13: Offline state is handled at the root app level.

A `ConnectivityWrapper` wraps the entire app. It shows `OfflineBanner` when `connectivity_plus` detects no connection. Individual screens do not manage offline state.

### Rule 14: Idempotency keys on all POST /orders and POST /goals calls.

```dart
// Generate before the call, not inside it
final idempotencyKey = const Uuid().v4();
await apiService.createOrder(request, idempotencyKey: idempotencyKey);
```

Store the key locally. If the call times out, retry with the same key.

### Rule 15: Images always have a fallback.

```dart
CachedNetworkImage(
  imageUrl: product.primaryImage,
  placeholder: (_, __) => ProductImagePlaceholder(), // brand placeholder
  errorWidget: (_, __, ___) => ProductImagePlaceholder(),
  fit: BoxFit.cover,
)
```

`ProductImagePlaceholder` is a Container with Champagne Veil background + centered brand monogram SVG.

---

## BACKEND CODING RULES

### Rule B1: All endpoints validate input with Zod before processing.

```javascript
const createGoalSchema = z.object({
  goal_type: z.enum(['wedding', 'investment', 'festival', 'gift', 'family', 'other']),
  monthly_amount_paise: z.number().int().min(100000).max(5000000),
  duration_months: z.enum([12, 18, 24, 36]),
  // ...
});

router.post('/goals', authenticate, async (req, res) => {
  const result = createGoalSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(422).json({ error: { code: 'UNPROCESSABLE', details: result.error.flatten() } });
  }
  // proceed with result.data
});
```

### Rule B2: All monetary arithmetic uses integer paise. Never floats.

```javascript
// WRONG
const total = 84966.42 * 1.03; // floating point errors

// CORRECT - all in paise (integers)
const basePaise = 8496642;
const gstPaise = Math.round(basePaise * 3 / 100);
const totalPaise = basePaise + gstPaise;
```

### Rule B3: Gold weight arithmetic uses decimal.js or equivalent.

```javascript
import Decimal from 'decimal.js';

const grams = new Decimal(contributionPaise)
  .dividedBy(ratePaise)
  .toDecimalPlaces(4, Decimal.ROUND_DOWN);
```

Never use JavaScript native division for gold weight calculations.

### Rule B4: Stock decrement uses database-level atomic operations.

```javascript
// WRONG - read-then-write race condition
const product = await prisma.product.findUnique({ where: { id } });
if (product.stockQuantity > 0) {
  await prisma.product.update({ where: { id }, data: { stockQuantity: product.stockQuantity - 1 } });
}

// CORRECT - atomic conditional update
const updated = await prisma.product.updateMany({
  where: { id, stockQuantity: { gt: 0 } },
  data: { stockQuantity: { decrement: 1 } },
});
if (updated.count === 0) throw new ApiError('OUT_OF_STOCK');
```

### Rule B5: All errors follow the standard error response format.

```javascript
// Use the ApiError class
throw new ApiError('INSUFFICIENT_BALANCE', 'Gold balance is insufficient', {
  required_paise: productPricePaise,
  available_paise: userBalancePaise,
}, 400);
```

### Rule B6: JWT tokens must not contain sensitive data.

```javascript
// WRONG
jwt.sign({ userId, phone, aadhaar, panNumber }, secret);

// CORRECT
jwt.sign({ userId, kycStatus }, secret, { expiresIn: '1h' });
```

### Rule B7: All DB queries go through Prisma. No raw SQL except for performance-critical read queries.

Exceptions allowed:
- Materialized view refreshes
- Full-text search queries
- Complex aggregations with explain-plan justification

### Rule B8: Prisma transactions for multi-table writes.

```javascript
// When creating a goal + first contribution:
await prisma.$transaction(async (tx) => {
  const goal = await tx.goal.create({ data: goalData });
  const contribution = await tx.contribution.create({ data: { ...contributionData, goalId: goal.id } });
  await updateGoldBalanceSnapshot(tx, userId);
  return { goal, contribution };
});
```

### Rule B9: Push notifications are sent via a queue, not inline.

```javascript
// WRONG - inline in request handler
await sendPushNotification(userId, message); // blocks response

// CORRECT - add to queue
await notificationQueue.add({ userId, type: 'contribution_success', data: { grams: '0.38g' } });
// Response returned immediately
```

### Rule B10: Rate-limit all sensitive endpoints at the middleware level.

```javascript
// Applied as middleware in route definition
router.post('/auth/send-otp', 
  rateLimit({ windowMs: 10 * 60 * 1000, max: 3 }),
  sendOtpHandler
);
```

---

## FILE NAMING CONVENTIONS

Flutter:
- Screens: `snake_case_screen.dart`
- Widgets/Components: `snake_case_widget.dart` or just `snake_case.dart`
- Providers: `snake_case_provider.dart`
- Models: `snake_case.dart`
- Constants: `snake_case.dart` (all caps for const values inside)

Backend:
- Routes: `snake_case.routes.js`
- Controllers: `snake_case.controller.js`
- Services: `snake_case.service.js`
- Middleware: `snake_case.middleware.js`
- Schemas (Zod): `snake_case.schema.js`

---

## ENVIRONMENT VARIABLES

Required in `.env`:
```
# Backend
DATABASE_URL=
JWT_SECRET=
JWT_REFRESH_SECRET=
RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
AWS_CLOUDFRONT_DOMAIN=
FIREBASE_PROJECT_ID=
FIREBASE_PRIVATE_KEY=
FIREBASE_CLIENT_EMAIL=
REDIS_URL=
GOLD_RATE_API_KEY=
KYC_PROVIDER_API_KEY=
AADHAAR_API_KEY=

# Flutter (.env or dart_define)
API_BASE_URL=
SENTRY_DSN=
```

---

## DO NOT

- Do not use `print()` in production Flutter code — use a logger
- Do not store gold weights as JavaScript numbers — use Decimal.js on backend
- Do not use `setState` in screens — use Riverpod
- Do not hardcode any color, size, or spacing — use tokens
- Do not make API calls inside `build()` methods
- Do not use `dynamic` type in Dart unless absolutely unavoidable
- Do not skip `freezed` for data models
- Do not write business logic in Flutter widgets — it belongs in providers or services
- Do not pass raw PAN or Aadhaar numbers in logs
- Do not send push notifications synchronously in request handlers
- Do not compute product prices on the client — use server-returned values for transactions
- Do not use `Navigator.push` — use `context.push` via go_router
