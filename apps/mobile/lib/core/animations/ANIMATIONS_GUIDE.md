# Moozhayil Premium Animation System

All animations feel **jewellery-like**: calm, precise, trustworthy. Never bouncy, cartoonish, or game-like.

---

## Core Principle

> Transactions should feel trustworthy, savings should feel rewarding, and jewellery browsing should feel editorial.

---

## Animation Files

### 1. **payment_success_animation.dart**
**Gold tick draws itself inside circular seal**

**Use cases:**
- Payment successful (schemes, orders, manual contributions)
- Contribution completed
- Refund completed

```dart
PaymentSuccessAnimation(
  size: 120,
  onComplete: () => Navigator.pop(context),
)
```

---

### 2. **add_to_cart_animation.dart**
**Product image gently flies into cart icon**

**Use cases:**
- Add to cart pressed
- Quick add from product grid

```dart
showAddToCartAnimation(
  context: context,
  productImageUrl: product.primaryImage,
  productImageRect: imageRect,
  cartIconRect: cartIconRect,
  onComplete: () {
    // Update cart state
  },
);
```

---

### 3. **gold_progress_ring.dart**
**Circular gold progress ring fills smoothly**

**Use cases:**
- Goal progress display
- Scheme maturity percentage
- KYC completion progress
- Profile completion

```dart
GoldProgressRing(
  percent: 0.65, // 65%
  size: 120,
  strokeWidth: 8,
  animateOnMount: true,
  showPercentage: true,
)
```

---

### 4. **payment_processing_animation.dart**
**Rotating gold ring with subtle shimmer**

**Use cases:**
- Payment verifying (Razorpay)
- Contribution processing
- Order being placed

```dart
PaymentProcessingAnimation(
  size: 80,
)
```

---

### 5. **order_timeline_animation.dart**
**Tracking timeline with animated progress**

**Use cases:**
- Order tracking (Confirmed → Packed → Shipped → Delivered)
- Scheme enrollment steps
- KYC submission steps

```dart
OrderTimelineAnimation(
  steps: [
    OrderTimelineStep(
      title: 'Order Confirmed',
      subtitle: 'Jan 15, 10:30 AM',
      icon: Icons.check_circle,
    ),
    // ...more steps
  ],
  currentStep: 2,
  animate: true,
)
```

---

### 6. **grams_counter_animation.dart**
**Grams count upward with shimmer**

**Use cases:**
- Gold grams credited (contribution success)
- Bonus credited
- Gold balance updated
- Redemption amount

```dart
GramsCounterAnimation(
  startValue: 0.0,
  endValue: 2.5432,
  decimals: 4,
  suffix: 'g',
)

// For amounts:
AmountCounterAnimation(
  startAmountPaise: 0,
  endAmountPaise: 500000, // ₹5,000.00
  prefix: '₹',
)
```

---

### 7. **kyc_verified_seal.dart**
**Identity card receives gold verified seal**

**Use cases:**
- KYC approved
- Profile verified
- Document approved

```dart
KycVerifiedSeal(
  size: 100,
  onComplete: () {
    // Navigate to next screen
  },
)
```

---

### 8. **aura_thinking_animation.dart**
**Elegant flowing gold line (not bouncing dots)**

**Use cases:**
- Aura processing request
- AI generating recommendations
- Search loading

```dart
// Primary: Flowing line
AuraThinkingAnimation(
  width: 120,
  height: 40,
)

// Alternative: Typing dots
AuraTypingAnimation(
  dotSize: 8,
)
```

---

### 9. **wishlist_heart_animation.dart**
**Heart fills with molten gold effect**

**Use cases:**
- Add to Dream Vault
- Add to wishlist
- Like/unlike product

```dart
WishlistHeartAnimation(
  isLiked: product.isInVault,
  size: 24,
  onTap: () {
    // Toggle vault status
  },
)
```

---

### 10. **gold_rate_ticker.dart**
**Digits roll vertically like premium market ticker**

**Use cases:**
- Live gold rate update
- Price recalculation
- Rate alert notification

```dart
GoldRateTicker(
  rate: '₹7,234.50',
  previousRate: '₹7,180.00',
  showChangeIndicator: true,
)

// For rate alerts:
GoldBellAnimation(
  size: 24,
)
```

---

### 11. **vault_animations.dart**
**Vault opens to reveal accumulated gold**

**Use cases:**
- Scheme matured
- Goal completed
- Product added to Dream Vault

```dart
// Vault opening:
VaultOpeningAnimation(
  goldGrams: 125.4320,
  size: 200,
  onComplete: () {
    // Show redemption options
  },
)

// Product shrinking into vault:
ShrinkToVaultAnimation(
  child: ProductCard(...),
  onComplete: () {
    // Remove from view
  },
)
```

---

## Existing Premium Animations

### From `premium_pressable.dart`
**Button press depth and release**

```dart
PremiumPressable(
  onTap: () {},
  scaleEnd: 0.97, // Subtle compression
  child: Container(...),
)
```

### From `fade_slide_in.dart`
**Page content reveals with gentle slide**

```dart
FadeSlideIn(
  duration: AppMotion.normal,
  offsetY: 12,
  delay: Duration(milliseconds: 80),
  child: Text('Hero Text'),
)
```

### From `section_reveal.dart`
**Home sections reveal on scroll**

```dart
SectionReveal(
  index: 2,
  child: CategoryCarousel(),
)
```

---

## Animation Constants

All durations and curves live in `AppMotion` (`core/constants/motion.dart`).
Never hardcode a `Duration` or `Curve` in a widget.

```dart
// General scale
AppMotion.instant      // 80ms   - press feedback
AppMotion.fast         // 140ms  - icon / badge state changes
AppMotion.normal       // 220ms  - sheets, cross-fades, section reveals
AppMotion.slow         // 380ms  - confirmation draw sequences
AppMotion.cinematic    // 700ms  - hero moments
AppMotion.hero         // 1000ms

// Curves
AppMotion.standard       // easeOutCubic   - most transitions
AppMotion.standardInOut  // easeInOutCubic - rings, banners, cart flight
AppMotion.emphasized     // easeOutQuart
AppMotion.decelerate     // easeOut        - counters, rolling digits
AppMotion.organic        // easeInOutSine  - gold filling a ring
AppMotion.exit           // easeInCubic    - things leaving the screen
```

---

## Feature Tokens

Component- and feature-specific tokens, also in `AppMotion`:

```dart
AppMotion.cartFlight         // 500ms
AppMotion.sealDraw           // 700ms  - payment success, KYC approved
AppMotion.progressFill       // 800ms  - all progress rings and bars
AppMotion.vaultOpen          // 1000ms
AppMotion.gramsCredit        // 600ms
AppMotion.countUp            // 400ms
AppMotion.auraThinking       // 1200ms
AppMotion.wishlistHeartFill  // 400ms
AppMotion.shimmerCycle       // 1200ms
```

---

## Usage Patterns

### 1. Success Flows
```dart
// Contribution successful:
showDialog(
  context: context,
  builder: (_) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PaymentSuccessAnimation(),
      SizedBox(height: 16),
      GramsCounterAnimation(
        endValue: contribution.gramsAdded,
      ),
    ],
  ),
);
```

### 2. Progress Tracking
```dart
// Goal progress:
GoldProgressRing(
  percent: goal.currentGrams / goal.targetGrams,
  centerWidget: Column(
    children: [
      Text('${goal.percentComplete}%'),
      Text('complete'),
    ],
  ),
)
```

### 3. Rate Updates
```dart
// Live gold rate:
GoldRateTicker(
  rate: currentRate,
  previousRate: ref.watch(previousRateProvider),
  showChangeIndicator: true,
)
```

### 4. Vault Interactions
```dart
// Add to vault:
onTap: () {
  setState(() => product.isInVault = !product.isInVault);
  if (product.isInVault) {
    // Show shrink animation
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => ShrinkToVaultAnimation(
          child: ProductCard(product),
          onComplete: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
```

---

## NOT TO DO ❌

- ❌ Confetti explosions
- ❌ Bouncing icons
- ❌ Aggressive red flashes
- ❌ Game-like celebrations
- ❌ Spinning loaders (use gold ring)
- ❌ Instant state changes (always animate)
- ❌ Elastic bounces (except subtle button press)

---

## Haptic Feedback

Pair animations with haptic feedback using `AppHaptics`:

```dart
import '../../core/utils/app_haptics.dart';

// On success:
AppHaptics.success();
PaymentSuccessAnimation();

// On selection:
AppHaptics.selection();
WishlistHeartAnimation();

// On light press:
AppHaptics.light();
PremiumPressable();
```

---

## Testing Animations

To slow down all animations for testing:

```dart
// In main.dart (dev only):
if (kDebugMode) {
  timeDilation = 2.0; // 2x slower
}
```

---

## Future Animations (Not Yet Built)

These are specified but not implemented:

- Order placed (jewellery box closes, wraps, shows ID)
- Payment failed (soft shake, clean retry)
- Scheme joined (coin drops into vault)
- Milestone glow (25%, 50%, 75% markers)
- OTP verified (digits merge into tick)
- Document upload (slide into secure folder)
- Product variant selection (gold trace around chip)
- Filter applied (catalogue reorganises)
- Appointment booked (calendar folds to ticket)
- Border trace (gold line draws around selected card)

These should follow the same premium, calm principles defined in the existing animations.
