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

  static const kycGateRedemptionBody =
      'Complete verification to use My Gold toward a purchase. '
      'Browsing and Dream Vault need no verification.';

  static const kycGateHighValueOrderBody =
      'Orders above ₹50,000 require identity verification before checkout.';

  static const kycGateEnhancedBody =
      'Contributions above ₹50,000 require enhanced verification with Aadhaar and PAN.';

  static String kycPendingReviewSla(int minutes) =>
      'This usually takes about $minutes minutes. We will notify you when it is done.';

  static const kycStatusUnknownBody =
      'We could not confirm your verification status. Check your connection and try again.';

  static const kycRejectionGeneric =
      'We could not verify your documents. You may resubmit after review.';

  static const kycRejectionNameMismatch =
      'The name on your documents did not match. Please resubmit with matching details.';

  static const kycRejectionDocumentUnreadable =
      'We could not read one of your documents clearly. Please capture a clearer photo.';

  static const kycRejectionSelfieMismatch =
      'Your selfie did not match your ID photo. Please try again in good lighting.';

  static const kycRejectionExpiredDocument =
      'One of your documents appears expired. Please submit a current document.';

  static const kycRedemptionPanelTitle = 'Complete verification to use My Gold';

  static const kycRedemptionPanelBody =
      'Redeeming saved gold toward jewellery requires identity verification.';

  // Gold rate label (daily admin-set rate — not a live feed)
  static const goldRateHeadline = 'Gold rate';
  static const goldRateRefreshing = 'Refreshing…';
  static const goldRateOffline = "You're offline. Showing last known rate.";
  static const goldRateClientCacheStale =
      'Showing last known rate. Tap to refresh.';
  static const goldRateSourceStale = "Today's rate has not been updated yet.";
  static const goldRateSourceUnchanged =
      "Still showing today's published rate.";
  static const goldRateTimeUnavailable = 'Time unavailable';

  static String goldRateUnavailable(String purityLabel) =>
      'Gold rate unavailable · $purityLabel';

  // Price lock (server-issued quote)
  static String priceLockUntilIst(String timeIst) =>
      'Rate locked until $timeIst';
  static String priceLockCountdownMmSs(int minutes, int seconds) =>
      'Rate locked · ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} left';
  static const priceLockExpired = 'Rate lock expired';
  static const priceLockRefreshing = 'Refreshing rate…';
  static const priceLockRefresh = 'Refresh';
  static const priceLockChangedTitle = 'Price updated';
  static const priceLockChangedBody =
      'The gold rate changed while refreshing your quote. Confirm the new total to continue.';
  static const priceLockPreviousTotal = 'Previous total';
  static const priceLockUpdatedTotal = 'Updated total';
  static const priceLockConfirmPay = 'Confirm and pay';

  static const enrollmentHandoffHint =
      'Next: pay your advance to secure your booking (Step 2 of 2).';
  static const firstPaymentSecureBooking = 'Secure your booking';
  static const firstPaymentSecureRate = 'Secure your rate protection';
  static const firstPaymentBody =
      'Your plan is created. Pay your advance now to lock today\u2019s published rate.';
  static const firstPaymentLockedAmount =
      'This amount was set during enrollment and cannot be changed here.';
  static const firstPaymentSuccessSubtitle =
      'Your advance is received. Your booking is now secured.';

  static const planCompletePrefix = 'Plan complete';

  /// Summary line suffix, e.g. "3 active plans".
  static String activePlansCount(int count) =>
      count == 1 ? '1 active plan' : '$count active plans';

  // Generic
  static const showroomFallback =
      'Available through our showroom. Contact Moozhayil to continue.';
  static const allCaughtUp = 'You\u2019re all caught up.';
}
