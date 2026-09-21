class PriceQuote {
  const PriceQuote({
    required this.quoteId,
    required this.serverTime,
    required this.priceValidUntil,
    required this.totalPaise,
    required this.totalDisplay,
    this.kycGrossTotalPaise,
  });

  final String quoteId;
  final String serverTime;
  final String priceValidUntil;
  final int totalPaise;
  final String totalDisplay;
  final int? kycGrossTotalPaise;

  factory PriceQuote.fromJson(Map<String, dynamic> json) {
    return PriceQuote(
      quoteId: json['quote_id'] as String,
      serverTime: json['server_time'] as String,
      priceValidUntil: json['price_valid_until'] as String,
      totalPaise: (json['total_paise'] as num).toInt(),
      totalDisplay: json['total_display'] as String,
      kycGrossTotalPaise: (json['kyc_gross_total_paise'] as num?)?.toInt(),
    );
  }
}
