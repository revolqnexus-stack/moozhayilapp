/// Client-side Schemes plan catalogue (presentation layer).
/// Backend discriminator: Goal.schemeType — same string values.
enum GoldenWishPlanId { aura, crest, dhanam, goldNidhi }

class GoldenWishPlan {
  const GoldenWishPlan({
    required this.id,
    required this.title,
    required this.tagline,
    required this.summary,
    required this.detailHeadline,
    required this.detailBody,
    required this.highlights,
    required this.enrollmentAvailable,
    required this.schemeType,
  });

  final GoldenWishPlanId id;
  final String title;
  final String tagline;
  final String summary;
  final String detailHeadline;
  final String detailBody;
  final List<String> highlights;
  final bool enrollmentAvailable;
  final String schemeType;

  String get routeSlug => switch (id) {
    GoldenWishPlanId.aura => 'aura',
    GoldenWishPlanId.crest => 'crest',
    GoldenWishPlanId.dhanam => 'dhanam',
    GoldenWishPlanId.goldNidhi => 'gold-nidhi',
  };
}

const goldenWishPlans = <GoldenWishPlan>[
  GoldenWishPlan(
    id: GoldenWishPlanId.aura,
    title: 'Aura Plan',
    tagline: 'Monthly Jewellery Savings',
    summary:
        '11 monthly installments from ₹500 — gold credited at each payment.',
    detailHeadline: 'Save monthly. Own beautifully.',
    detailBody:
        'Aura Plan is Moozhayil\'s monthly jewellery savings scheme — trusted by '
        'families since 1969. Each installment converts to gold at the day\'s rate. '
        'After all 11 installments, 0% making charges on jewellery redemption may apply '
        'when you pay with My Gold during your redemption window (days 332–352).',
    highlights: [
      '11 monthly installments from ₹500',
      'Gold credited at each payment',
      '0% making charges when paying with My Gold during your redemption window (after 11 installments)',
      'Two consecutive missed installments discontinue the plan; accumulated gold is retained',
      'Ideal for weddings, milestones, and heirlooms',
    ],
    enrollmentAvailable: true,
    schemeType: 'aura',
  ),
  GoldenWishPlan(
    id: GoldenWishPlanId.crest,
    title: 'Crest',
    tagline: 'Advance Gold Booking',
    summary: 'One advance payment — your gold weight is locked immediately.',
    detailHeadline: 'One payment. Weight secured.',
    detailBody:
        'Crest is for when you have a lump sum and want certainty. Pay your advance '
        'today and your gold weight is locked at today\u2019s published rate.',
    highlights: [
      'Single advance from ₹500',
      'Gold weight locked at enrollment',
      'Ideal for planned weddings and occasions',
    ],
    enrollmentAvailable: true,
    schemeType: 'crest',
  ),
  GoldenWishPlan(
    id: GoldenWishPlanId.dhanam,
    title: 'Dhanam',
    tagline: 'Protected Gold Pricing',
    summary:
        'Book today — receive the lower of booking or redemption day rate.',
    detailHeadline: 'Peace of mind against market movement.',
    detailBody:
        'Dhanam protects you when gold prices rise. Your booking-day rate is recorded. '
        'At redemption, you benefit from whichever rate is lower — the day you booked, '
        'or the day you collect your jewellery.',
    highlights: [
      'Lower of booking vs redemption rate',
      '12-month booking window',
      'Trusted by families across Kerala since 1969',
    ],
    enrollmentAvailable: true,
    schemeType: 'dhanam',
  ),
  GoldenWishPlan(
    id: GoldenWishPlanId.goldNidhi,
    title: 'Swarna Nidhi',
    tagline: 'Flexible Gold Savings',
    summary: 'Open-ended deposits from ₹500 — save at your own pace.',
    detailHeadline: 'Your gold. Your timeline.',
    detailBody:
        'Swarna Nidhi is an open-ended accumulation plan. Deposit whenever it suits you, '
        'build gold weight over time, and redeem whenever you are ready from Moozhayil.',
    highlights: [
      'Open-ended — no fixed maturity',
      'Deposits from ₹500, multiples of ₹500',
      'Multiple deposits welcome',
    ],
    enrollmentAvailable: true,
    schemeType: 'gold_nidhi',
  ),
];

GoldenWishPlan? goldenWishPlanBySlug(String slug) {
  for (final plan in goldenWishPlans) {
    if (plan.routeSlug == slug || plan.routeSlug.replaceAll('-', '') == slug) {
      return plan;
    }
    if (slug == 'gold-nidhi' && plan.id == GoldenWishPlanId.goldNidhi) {
      return plan;
    }
  }
  return null;
}
