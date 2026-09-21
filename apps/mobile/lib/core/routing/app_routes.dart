/// Canonical route paths for the Moozhayil app.
///
/// Source of truth: docs/14-final-architecture.md §4.2
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const onboardingCarousel = '/onboarding/carousel';
  static const onboardingIntent = '/onboarding/intent';
  static const onboardingName = '/onboarding/name';
  static const onboardingKycIntro = '/onboarding/kyc-intro';

  static const auth = '/auth';
  static const authOtp = '/auth/otp';

  static const home = '/home';
  static const shop = '/shop';
  static const shopSearch = '/shop/search';
  static const shopCategory = '/shop/category/:categoryId';
  static const shopOccasion = '/shop/occasion/:occasionId';
  static const shopCollection = '/shop/collection/:collectionId';
  static const shopProduct = '/shop/product/:productId';

  static const dreamVault = '/dream-vault';
  static const wishlist = '/wishlist';

  static const newArrivals = '/new';

  /// Golden Wish tab and purchase-plan hub (backend: Goal + scheme_type).
  static const goldenWish = '/golden-wish';
  static String goldenWishPlanDetail(String planSlug) =>
      '/golden-wish/plans/$planSlug';
  static const myPlans = '/my-plans';

  static const goals = '/goals';
  static const goalDetail = '/goals/:goalId';
  static const goalContribute = '/goals/:goalId/contribute';

  static String goalContributeFirstPayment({
    required String goalId,
    required int amountPaise,
  }) => Uri(
    path: '/goals/$goalId/contribute',
    queryParameters: {'firstPayment': '1', 'amountPaise': '$amountPaise'},
  ).toString();
  static const goalsCreate = '/goals/create';
  static const goalsCreateMoment = '/goals/create/moment';
  static const goalsCreatePiece = '/goals/create/piece';
  static const goalsCreateAmount = '/goals/create/amount';
  static const goalsCreatePayment = '/goals/create/payment';
  static const goalsCreateConfirmation = '/goals/create/confirmation';

  static const myGold = '/my-gold';
  static const myGoldRedeem = '/my-gold/redeem';

  static const aura = '/aura';
  static const auraConversation = '/aura/conversation/:sessionId';
  static const auraGoalPlanning = '/aura/goal-planning';
  static const auraProductDiscovery = '/aura/product-discovery';
  static const auraGoldInsights = '/aura/gold-insights';

  static const profile = '/profile';
  static const profileKyc = '/profile/kyc';
  static const profileKycAadhaar = '/profile/kyc/aadhaar';
  static const profileKycAadhaarOtp = '/profile/kyc/aadhaar/otp';
  static const profileKycPan = '/profile/kyc/pan';
  static const profileKycSelfie = '/profile/kyc/selfie';
  static const profileKycReview = '/profile/kyc/review';
  static const profileKycPending = '/profile/kyc/pending';
  static const profileAddresses = '/profile/addresses';
  static const profilePaymentMethods = '/profile/payment-methods';

  static const orders = '/orders';
  static const orderDetail = '/orders/:orderId';
  static const orderConfirmation = '/orders/confirmation/:orderId';

  static const checkout = '/checkout';
  static const cart = '/cart';
  static const notifications = '/notifications';
  static const storeLocator = '/store-locator';
  static const referrals = '/referrals';

  /// Debug-only screen gallery (kDebugMode).
  static const devScreens = '/dev/screens';
}
