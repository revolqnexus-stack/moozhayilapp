// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
abstract class CartLineItem with _$CartLineItem {
  const factory CartLineItem({
    required String id,
    required Product product,
    required int quantity,
    @JsonKey(name: 'is_available') required bool isAvailable,
    @JsonKey(name: 'unavailable_reason') String? unavailableReason,
  }) = _CartLineItem;

  factory CartLineItem.fromJson(Map<String, dynamic> json) =>
      _$CartLineItemFromJson(json);
}

@freezed
abstract class CartSummary with _$CartSummary {
  const factory CartSummary({
    required List<CartLineItem> items,
    @JsonKey(name: 'subtotal_paise') required int subtotalPaise,
    @JsonKey(name: 'subtotal_display') required String subtotalDisplay,
    @JsonKey(name: 'kyc_gross_total_paise') int? kycGrossTotalPaise,
    @JsonKey(name: 'item_count') required int itemCount,
    @JsonKey(name: 'price_valid_until') String? priceValidUntil,
  }) = _CartSummary;

  factory CartSummary.fromJson(Map<String, dynamic> json) =>
      _$CartSummaryFromJson(json);
}
