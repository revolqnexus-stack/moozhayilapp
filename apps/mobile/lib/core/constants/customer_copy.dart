/// Customer-facing copy — single source for empty states and toasts.
abstract final class CustomerCopy {
  // Bag
  static const bagEmptyHeadline =
      'Your bag is waiting for something beautiful.';
  static const bagEmptyBody =
      'Discover handcrafted gold and diamonds curated for you.';
  static const bagEmptyCta = 'Explore Jewellery';
  static const addedToBag = 'Added to Bag';
  static const viewBag = 'View Bag';
  static const addToBagError = 'Something went wrong while adding to Bag.';
  static const productLoadError = 'We couldn\u2019t load this piece.';
  static const paymentError = 'Payment could not be completed.';
  static const planStartError =
      'We couldn\u2019t start your plan. Please try again.';
  static const contributionReceived = 'Installment received.';
  static const contributionMovingForward = 'Your Aura Plan is moving forward.';

  // Dream Vault
  static const dreamVaultTitle = 'Dream Vault';
  static const dreamVaultEmptyHeadline = 'Your Dream Vault is waiting.';
  static const dreamVaultEmptyBody =
      'Tap the heart on any piece to save it for later.';
  static const dreamVaultEmptyCta = 'Browse Collections';
  static const dreamVaultSignedOutHeadline = 'Your Dream Vault awaits';

  // Orders
  static const ordersEmptyHeadline = 'No purchases yet.';
  static const ordersEmptyBody =
      'When you order from Moozhayil, your history will appear here.';

  // Schemes tab
  static const schemesPurchasePlansTitle = 'Moozhayil purchase plans';
  static const schemesBrowsePlansCta = 'Browse plans';
  static const myPlansSectionTitle = 'My Plans';
  static const exploreSchemesCta = 'Explore Schemes';
  static const myPlansEmptyHeadlineInline =
      'Start your jewellery savings journey.';
  static const myPlansEmptyBodyInline =
      'Explore Aura Plan, Crest, Dhanam, and Swarna Nidhi.';

  // My Plans
  static const myPlansEmptyHeadline = 'No active plans yet.';
  static const myPlansEmptyBody =
      'Explore Schemes to start saving toward your next piece.';

  // Scheme enrollment
  static const linkPieceOptional = 'Optional: link a dream piece to your plan.';

  // Profile / KYC (BR-KYC-001: schemes, installments, My Gold; browsing open)
  static const kycUnlockSchemes =
      'Required to enroll in Schemes, pay installments and use My Gold. '
      'Browsing needs no verification.';

  static const kycGateGoalBody =
      'Required to enroll in Schemes, pay installments and use My Gold. '
      'Browsing and Dream Vault need no verification. '
      'Orders above ₹50,000 require verification.';

  static const kycGateContributionBody =
      'Installments and My Gold require identity verification. '
      'You can browse and save to Dream Vault without it. '
      'Orders above ₹50,000 require verification.';

  // Gold rate label
  static const goldRateRefreshing = 'Refreshing…';
  static const goldRateOffline = "You're offline. Showing last known rate.";
  static const goldRateStale = 'Rate may be outdated.';
  static const goldRateTimeUnavailable = 'Time unavailable';

  static String goldRateUnavailable(String purityLabel) =>
      'Gold rate unavailable · $purityLabel';

  static const planCompletePrefix = 'Plan complete';

  /// Summary line suffix, e.g. "3 active plans".
  static String activePlansCount(int count) =>
      count == 1 ? '1 active plan' : '$count active plans';

  // Generic
  static const showroomFallback =
      'Available through our showroom. Contact Moozhayil to continue.';
  static const allCaughtUp = 'You\u2019re all caught up.';
}
