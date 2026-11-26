import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'goal_create_provider.g.dart';

/// Golden Wish scheme identifiers — match API `scheme_type`.
enum GoldenWishSchemeType {
  aura('aura', 'Aura Plan', 11, 50000, 50000, 5000000),
  crest('crest', 'Crest', 1, 50000, 50000, 5000000),
  dhanam('dhanam', 'Dhanam', 12, 50000, 50000, 5000000),
  goldNidhi('gold_nidhi', 'Swarna Nidhi', 999, 50000, 50000, 5000000);

  const GoldenWishSchemeType(
    this.apiValue,
    this.displayName,
    this.defaultDurationMonths,
    this.minAmountPaise,
    this.stepPaise,
    this.maxAmountPaise,
  );

  final String apiValue;
  final String displayName;
  final int defaultDurationMonths;
  final int minAmountPaise;
  final int stepPaise;
  final int maxAmountPaise;

  static GoldenWishSchemeType fromApiValue(String value) {
    return GoldenWishSchemeType.values.firstWhere(
      (scheme) => scheme.apiValue == value,
      orElse: () => GoldenWishSchemeType.aura,
    );
  }

  bool get isOpenEnded => this == GoldenWishSchemeType.goldNidhi;
  bool get isLumpSum => this == GoldenWishSchemeType.crest;
  bool get isMonthly => this == GoldenWishSchemeType.aura;
  bool get isRateProtected => this == GoldenWishSchemeType.dhanam;
}

class GoalCreateDraft {
  const GoalCreateDraft({
    this.schemeType = GoldenWishSchemeType.aura,
    this.goalType = 'wedding',
    this.name = '',
    this.targetProductId,
    this.targetProductName,
    this.monthlyAmountPaise = 50000,
    this.durationMonths = 11,
    this.startDate,
  });

  final GoldenWishSchemeType schemeType;
  final String goalType;
  final String name;
  final String? targetProductId;
  final String? targetProductName;
  final int monthlyAmountPaise;
  final int durationMonths;
  final String? startDate;

  GoalCreateDraft copyWith({
    GoldenWishSchemeType? schemeType,
    String? goalType,
    String? name,
    String? targetProductId,
    String? targetProductName,
    int? monthlyAmountPaise,
    int? durationMonths,
    String? startDate,
  }) {
    return GoalCreateDraft(
      schemeType: schemeType ?? this.schemeType,
      goalType: goalType ?? this.goalType,
      name: name ?? this.name,
      targetProductId: targetProductId ?? this.targetProductId,
      targetProductName: targetProductName ?? this.targetProductName,
      monthlyAmountPaise: monthlyAmountPaise ?? this.monthlyAmountPaise,
      durationMonths: durationMonths ?? this.durationMonths,
      startDate: startDate ?? this.startDate,
    );
  }

  bool get isValid {
    if (name.trim().isEmpty) return false;
    if (monthlyAmountPaise < schemeType.minAmountPaise) return false;
    if (monthlyAmountPaise % schemeType.stepPaise != 0) return false;
    // Open-ended (gold_nidhi) has no fixed duration constraint.
    // For all other schemes, the duration must match the fixed scheme duration.
    if (!schemeType.isOpenEnded &&
        durationMonths != schemeType.defaultDurationMonths) {
      return false;
    }
    return true;
  }

  String get amountLabel => switch (schemeType) {
    GoldenWishSchemeType.aura => 'Monthly installment',
    GoldenWishSchemeType.crest => 'Advance amount',
    GoldenWishSchemeType.dhanam => 'Booking advance',
    GoldenWishSchemeType.goldNidhi => 'Minimum deposit',
  };

  String get successTitle => switch (schemeType) {
    GoldenWishSchemeType.aura => 'Your Aura Plan has started.',
    _ => 'Your ${schemeType.displayName} has started.',
  };

  String get successSubtitle => switch (schemeType) {
    GoldenWishSchemeType.aura =>
      'Your plan is active. Make your first contribution from My Plans whenever you are ready.',
    GoldenWishSchemeType.crest =>
      'Your Crest plan is created. Pay your advance from Contribute to lock gold weight at today\u2019s rate.',
    GoldenWishSchemeType.dhanam =>
      'Your Dhanam booking is created. Pay your booking advance from Contribute to lock today\u2019s rate.',
    GoldenWishSchemeType.goldNidhi =>
      'Your Swarna Nidhi account is open. Deposit whenever you wish from Contribute.',
  };
}

// keepAlive: the plan screen only `ref.read`s this before navigating, so an
// auto-dispose store was dropped and every plan showed the default (Aura).
@Riverpod(keepAlive: true)
class GoalCreateDraftStore extends _$GoalCreateDraftStore {
  @override
  GoalCreateDraft build() {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month, 1);
    return GoalCreateDraft(
      startDate:
          '${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-01',
    );
  }

  void setScheme(GoldenWishSchemeType schemeType) {
    state = GoalCreateDraft(
      schemeType: schemeType,
      goalType: state.goalType,
      name: state.name,
      targetProductId: state.targetProductId,
      targetProductName: state.targetProductName,
      monthlyAmountPaise: schemeType.minAmountPaise,
      durationMonths: schemeType.defaultDurationMonths,
      startDate: state.startDate,
    );
  }

  void setGoalType(String goalType) {
    state = state.copyWith(goalType: goalType);
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setProduct({required String id, required String name}) {
    state = state.copyWith(targetProductId: id, targetProductName: name);
  }

  void setMonthlyAmount(int paise) {
    state = state.copyWith(monthlyAmountPaise: paise);
  }

  void setDuration(int months) {
    state = state.copyWith(durationMonths: months);
  }

  void reset() {
    state = build();
  }
}
