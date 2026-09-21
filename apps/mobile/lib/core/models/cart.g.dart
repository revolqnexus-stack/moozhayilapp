// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartLineItem _$CartLineItemFromJson(Map<String, dynamic> json) =>
    _CartLineItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      isAvailable: json['is_available'] as bool,
      unavailableReason: json['unavailable_reason'] as String?,
    );

Map<String, dynamic> _$CartLineItemToJson(_CartLineItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product': instance.product,
      'quantity': instance.quantity,
      'is_available': instance.isAvailable,
      'unavailable_reason': instance.unavailableReason,
    };

_CartSummary _$CartSummaryFromJson(Map<String, dynamic> json) => _CartSummary(
  items: (json['items'] as List<dynamic>)
      .map((e) => CartLineItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  subtotalPaise: (json['subtotal_paise'] as num).toInt(),
  subtotalDisplay: json['subtotal_display'] as String,
  kycGrossTotalPaise: (json['kyc_gross_total_paise'] as num?)?.toInt(),
  itemCount: (json['item_count'] as num).toInt(),
  priceValidUntil: json['price_valid_until'] as String?,
);

Map<String, dynamic> _$CartSummaryToJson(_CartSummary instance) =>
    <String, dynamic>{
      'items': instance.items,
      'subtotal_paise': instance.subtotalPaise,
      'subtotal_display': instance.subtotalDisplay,
      'kyc_gross_total_paise': instance.kycGrossTotalPaise,
      'item_count': instance.itemCount,
      'price_valid_until': instance.priceValidUntil,
    };
