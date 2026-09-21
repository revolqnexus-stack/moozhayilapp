import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart.dart';
import '../../../core/models/price_quote.dart';
import '../../../core/pricing/price_validity_guard.dart';
import '../../../core/time/server_clock_provider.dart';
import '../../../core/widgets/price_validity_banner.dart';
import '../providers/cart_provider.dart';

/// Shows server-issued rate lock on the cart when items are present.
class CartPriceLockBanner extends ConsumerStatefulWidget {
  const CartPriceLockBanner({super.key, required this.summary});

  final CartSummary summary;

  @override
  ConsumerState<CartPriceLockBanner> createState() =>
      _CartPriceLockBannerState();
}

class _CartPriceLockBannerState extends ConsumerState<CartPriceLockBanner> {
  PriceQuote? _quote;
  var _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncQuote());
    });
  }

  @override
  void didUpdateWidget(covariant CartPriceLockBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.itemCount != widget.summary.itemCount ||
        oldWidget.summary.subtotalPaise != widget.summary.subtotalPaise) {
      unawaited(_syncQuote(forceRefresh: true));
    }
  }

  Future<void> _syncQuote({bool forceRefresh = false}) async {
    if (_isRefreshing || widget.summary.items.isEmpty) return;

    final fromCart = _quoteFromSummary(widget.summary);
    if (!forceRefresh && fromCart != null) {
      _applyQuote(fromCart);
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      final quote =
          await ref.read(cartRepositoryProvider).createQuoteFromCart();
      if (mounted) {
        _applyQuote(quote);
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  PriceQuote? _quoteFromSummary(CartSummary summary) {
    final validUntil = summary.priceValidUntil;
    final serverTime = summary.serverTime;
    final quoteId = summary.quoteId;
    if (validUntil == null || serverTime == null || quoteId == null) {
      return null;
    }
    return PriceQuote(
      quoteId: quoteId,
      serverTime: serverTime,
      priceValidUntil: validUntil,
      totalPaise: summary.subtotalPaise,
      totalDisplay: summary.subtotalDisplay,
      kycGrossTotalPaise: summary.kycGrossTotalPaise,
    );
  }

  void _applyQuote(PriceQuote quote) {
    final serverTime = DateTime.tryParse(quote.serverTime)?.toUtc();
    if (serverTime != null) {
      ref.read(serverClockProvider).syncFromServerInstant(serverTime);
    }
    setState(() => _quote = quote);
  }

  PriceValidityGuard? _guard() {
    final quote = _quote;
    if (quote == null) {
      return null;
    }
    final validUntil = DateTime.tryParse(quote.priceValidUntil)?.toUtc();
    final serverTime = DateTime.tryParse(quote.serverTime)?.toUtc();
    if (validUntil == null || serverTime == null) {
      return null;
    }
    return PriceValidityGuard(
      validUntilUtc: validUntil,
      serverTimeAtIssueUtc: serverTime,
      clock: ref.read(serverClockProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guard = _guard();
    if (guard == null) {
      return const SizedBox.shrink();
    }
    return PriceValidityBanner(
      guard: guard,
      isRefreshing: _isRefreshing,
      onRefresh: () => _syncQuote(forceRefresh: true),
    );
  }
}
