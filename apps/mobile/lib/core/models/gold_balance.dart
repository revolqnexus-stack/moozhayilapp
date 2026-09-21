// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'gold_balance.freezed.dart';
part 'gold_balance.g.dart';

@freezed
abstract class GoldRateUsed with _$GoldRateUsed {
  const factory GoldRateUsed({
    required String purity,
    @JsonKey(name: 'rate_paise') required int ratePaise,
    @JsonKey(name: 'rate_display') required String rateDisplay,
    @JsonKey(name: 'updated_at') required String updatedAt,
    @JsonKey(name: 'is_stale') bool? isStale,
    @JsonKey(name: 'stale_after_seconds') int? staleAfterSeconds,
  }) = _GoldRateUsed;

  factory GoldRateUsed.fromJson(Map<String, dynamic> json) =>
      _$GoldRateUsedFromJson(json);
}

@freezed
abstract class GoldBalance with _$GoldBalance {
  const factory GoldBalance({
    @JsonKey(name: 'total_grams') required String totalGrams,
    @JsonKey(name: 'total_grams_display') required String totalGramsDisplay,
    @JsonKey(name: 'total_value_paise') required int totalValuePaise,
    @JsonKey(name: 'total_value_display') required String totalValueDisplay,
    @JsonKey(name: 'rate_used') required GoldRateUsed rateUsed,
  }) = _GoldBalance;

  factory GoldBalance.fromJson(Map<String, dynamic> json) =>
      _$GoldBalanceFromJson(json);
}

@freezed
abstract class GoldLedgerEntry with _$GoldLedgerEntry {
  const factory GoldLedgerEntry({
    required String id,
    @JsonKey(name: 'entry_type') required String entryType,
    @JsonKey(name: 'grams_delta') required String gramsDelta,
    @JsonKey(name: 'amount_paise') int? amountPaise,
    @JsonKey(name: 'gold_rate_per_gram_paise')
    required int goldRatePerGramPaise,
    @JsonKey(name: 'source_type') required String sourceType,
    @JsonKey(name: 'source_id') required String sourceId,
    @JsonKey(name: 'posted_at') required String postedAt,
  }) = _GoldLedgerEntry;

  factory GoldLedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$GoldLedgerEntryFromJson(json);
}

@freezed
abstract class GoldLedgerResponse with _$GoldLedgerResponse {
  const factory GoldLedgerResponse({
    required List<GoldLedgerEntry> data,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _GoldLedgerResponse;

  factory GoldLedgerResponse.fromJson(Map<String, dynamic> json) =>
      _$GoldLedgerResponseFromJson(json);
}

@freezed
abstract class RedeemableProductsResponse with _$RedeemableProductsResponse {
  const factory RedeemableProductsResponse({
    required List<dynamic> data,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @JsonKey(name: 'has_more') required bool hasMore,
  }) = _RedeemableProductsResponse;

  factory RedeemableProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$RedeemableProductsResponseFromJson(json);
}

@freezed
abstract class PendingContributionsResponse
    with _$PendingContributionsResponse {
  const factory PendingContributionsResponse({
    required List<PendingContribution> pending,
  }) = _PendingContributionsResponse;

  factory PendingContributionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingContributionsResponseFromJson(json);
}

@freezed
abstract class PendingContribution with _$PendingContribution {
  const factory PendingContribution({
    required String id,
    @JsonKey(name: 'goal_id') required String goalId,
    required String status,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _PendingContribution;

  factory PendingContribution.fromJson(Map<String, dynamic> json) =>
      _$PendingContributionFromJson(json);
}
