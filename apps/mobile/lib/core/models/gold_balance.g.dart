// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gold_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoldRateUsed _$GoldRateUsedFromJson(Map<String, dynamic> json) =>
    _GoldRateUsed(
      purity: json['purity'] as String,
      ratePaise: (json['rate_paise'] as num).toInt(),
      rateDisplay: json['rate_display'] as String,
      updatedAt: json['updated_at'] as String,
      isStale: json['is_stale'] as bool?,
      staleAfterSeconds: (json['stale_after_seconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GoldRateUsedToJson(_GoldRateUsed instance) =>
    <String, dynamic>{
      'purity': instance.purity,
      'rate_paise': instance.ratePaise,
      'rate_display': instance.rateDisplay,
      'updated_at': instance.updatedAt,
      'is_stale': instance.isStale,
      'stale_after_seconds': instance.staleAfterSeconds,
    };

_GoldBalance _$GoldBalanceFromJson(Map<String, dynamic> json) => _GoldBalance(
  totalGrams: json['total_grams'] as String,
  totalGramsDisplay: json['total_grams_display'] as String,
  totalValuePaise: (json['total_value_paise'] as num).toInt(),
  totalValueDisplay: json['total_value_display'] as String,
  rateUsed: GoldRateUsed.fromJson(json['rate_used'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GoldBalanceToJson(_GoldBalance instance) =>
    <String, dynamic>{
      'total_grams': instance.totalGrams,
      'total_grams_display': instance.totalGramsDisplay,
      'total_value_paise': instance.totalValuePaise,
      'total_value_display': instance.totalValueDisplay,
      'rate_used': instance.rateUsed,
    };

_GoldLedgerEntry _$GoldLedgerEntryFromJson(Map<String, dynamic> json) =>
    _GoldLedgerEntry(
      id: json['id'] as String,
      entryType: json['entry_type'] as String,
      gramsDelta: json['grams_delta'] as String,
      amountPaise: (json['amount_paise'] as num?)?.toInt(),
      goldRatePerGramPaise: (json['gold_rate_per_gram_paise'] as num).toInt(),
      sourceType: json['source_type'] as String,
      sourceId: json['source_id'] as String,
      postedAt: json['posted_at'] as String,
    );

Map<String, dynamic> _$GoldLedgerEntryToJson(_GoldLedgerEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entry_type': instance.entryType,
      'grams_delta': instance.gramsDelta,
      'amount_paise': instance.amountPaise,
      'gold_rate_per_gram_paise': instance.goldRatePerGramPaise,
      'source_type': instance.sourceType,
      'source_id': instance.sourceId,
      'posted_at': instance.postedAt,
    };

_GoldLedgerResponse _$GoldLedgerResponseFromJson(Map<String, dynamic> json) =>
    _GoldLedgerResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => GoldLedgerEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
      hasMore: json['has_more'] as bool,
    );

Map<String, dynamic> _$GoldLedgerResponseToJson(_GoldLedgerResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'next_cursor': instance.nextCursor,
      'has_more': instance.hasMore,
    };

_RedeemableProductsResponse _$RedeemableProductsResponseFromJson(
  Map<String, dynamic> json,
) => _RedeemableProductsResponse(
  data: json['data'] as List<dynamic>,
  nextCursor: json['next_cursor'] as String?,
  hasMore: json['has_more'] as bool,
);

Map<String, dynamic> _$RedeemableProductsResponseToJson(
  _RedeemableProductsResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'next_cursor': instance.nextCursor,
  'has_more': instance.hasMore,
};

_PendingContributionsResponse _$PendingContributionsResponseFromJson(
  Map<String, dynamic> json,
) => _PendingContributionsResponse(
  pending: (json['pending'] as List<dynamic>)
      .map((e) => PendingContribution.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PendingContributionsResponseToJson(
  _PendingContributionsResponse instance,
) => <String, dynamic>{'pending': instance.pending};

_PendingContribution _$PendingContributionFromJson(Map<String, dynamic> json) =>
    _PendingContribution(
      id: json['id'] as String,
      goalId: json['goal_id'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$PendingContributionToJson(
  _PendingContribution instance,
) => <String, dynamic>{
  'id': instance.id,
  'goal_id': instance.goalId,
  'status': instance.status,
  'created_at': instance.createdAt,
};
