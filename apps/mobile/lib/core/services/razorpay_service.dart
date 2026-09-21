import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../components/feedback/premium_snackbar.dart';
import 'api_service.dart';

final razorpayServiceProvider = Provider<RazorpayService>((ref) {
  return RazorpayService(ref.watch(apiServiceProvider));
});

/// Result returned once the Razorpay checkout sheet closes.
sealed class RazorpayResult {
  const RazorpayResult();
}

final class RazorpaySuccess extends RazorpayResult {
  const RazorpaySuccess({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  final String paymentId;
  final String orderId;
  final String signature;
}

final class RazorpayFailure extends RazorpayResult {
  const RazorpayFailure({required this.message, required this.code});

  final String message;
  final int code;
}

final class RazorpayCancelled extends RazorpayResult {
  const RazorpayCancelled();
}

/// Test seam — screens hold a gateway; tests inject a fake that records opens.
abstract interface class RazorpayCheckoutGateway {
  Future<RazorpayResult> open({
    required String keyId,
    required String razorpayOrderId,
    required int amountPaise,
    required String description,
    String? userPhone,
  });

  void dispose();
}

/// Opens the Razorpay checkout sheet and resolves via a [Completer].
/// Create one per screen; call [dispose] in the screen's [dispose] method.
class RazorpayCheckout implements RazorpayCheckoutGateway {
  RazorpayCheckout() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  late final Razorpay _razorpay;
  Completer<RazorpayResult>? _completer;

  /// Opens the sheet and returns a Future that resolves when the user
  /// completes, cancels, or encounters an error.
  @override
  Future<RazorpayResult> open({
    required String keyId,
    required String razorpayOrderId,
    required int amountPaise,
    required String description,
    String? userPhone,
  }) {
    _completer = Completer<RazorpayResult>();
    final options = <String, dynamic>{
      'key': keyId,
      'order_id': razorpayOrderId,
      'amount': amountPaise,
      'name': 'Moozhayil Gold',
      'description': description,
      if (userPhone != null) 'prefill': {'contact': userPhone},
      'theme': {'color': '#C4961A'},
    };
    _razorpay.open(options);
    return _completer!.future;
  }

  @override
  void dispose() => _razorpay.clear();

  void _onSuccess(PaymentSuccessResponse response) => _completer?.complete(
    RazorpaySuccess(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
    ),
  );

  void _onError(PaymentFailureResponse response) => _completer?.complete(
    RazorpayFailure(
      message: response.message ?? 'Payment failed',
      code: response.code ?? 0,
    ),
  );

  // External wallets complete asynchronously via webhook — treat as cancelled
  // for UX; the backend will reconcile via Razorpay webhook.
  void _onExternalWallet(ExternalWalletResponse _) =>
      _completer?.complete(const RazorpayCancelled());
}

/// High-level helper used by screens. Opens Razorpay and calls
/// `POST /v1/payments/capture-checkout` to verify the signature server-side.
class RazorpayService {
  const RazorpayService(this._apiService);

  final ApiService _apiService;

  /// Returns `true` when payment was captured successfully on the server.
  Future<bool> pay({
    required BuildContext context,
    required RazorpayCheckoutGateway checkout,
    required String keyId,
    required String razorpayOrderId,
    required int amountPaise,
    required String paymentSessionId,
    required String description,
    String? userPhone,
  }) async {
    final result = await checkout.open(
      keyId: keyId,
      razorpayOrderId: razorpayOrderId,
      amountPaise: amountPaise,
      description: description,
      userPhone: userPhone,
    );

    switch (result) {
      case RazorpaySuccess(:final paymentId, :final orderId, :final signature):
        try {
          // Use the new Razorpay verification endpoint
          await _apiService.client.post<void>(
            '/payments/verify-razorpay',
            data: {
              'razorpay_payment_id': paymentId,
              'razorpay_order_id': orderId,
              'razorpay_signature': signature,
            },
          );
          return true;
        } on DioException catch (e) {
          if (context.mounted) {
            showPremiumSnackBar(
              context,
              'Payment verification failed: ${e.message ?? 'Unknown error'}',
              haptic: false,
            );
          }
          return false;
        }

      case RazorpayFailure(:final message):
        if (context.mounted) {
          showPremiumSnackBar(
            context,
            'Payment failed: $message',
            haptic: false,
          );
        }
        return false;

      case RazorpayCancelled():
        if (context.mounted) {
          showPremiumSnackBar(context, 'Payment was cancelled', haptic: false);
        }
        return false;
    }
  }
}
