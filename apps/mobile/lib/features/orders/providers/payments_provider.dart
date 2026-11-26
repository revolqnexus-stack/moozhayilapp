import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/payment_method.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'payments_provider.g.dart';

class PaymentsRepository {
  const PaymentsRepository(this._apiService);

  final ApiService _apiService;

  Future<PaymentMethodsResponse> listMethods() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/payments/methods',
      );
      return PaymentMethodsResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PaymentMethod> createMethod({
    required String type,
    required String providerToken,
    required String displayLabel,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/payments/methods',
        data: {
          'type': type,
          'provider_token': providerToken,
          'display_label': displayLabel,
          'is_default': isDefault,
        },
      );
      return PaymentMethod.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> deleteMethod(String methodId) async {
    try {
      await _apiService.client.delete<void>('/payments/methods/$methodId');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<VerifyUpiResponse> verifyUpi(String upiId) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/payments/upi/verify',
        data: {'upi_id': upiId},
      );
      return VerifyUpiResponse.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
PaymentsRepository paymentsRepository(Ref ref) {
  return PaymentsRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<List<PaymentMethod>> paymentMethods(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const [];
  }

  final response = await ref.watch(paymentsRepositoryProvider).listMethods();
  return response.paymentMethods;
}

@Riverpod(keepAlive: true)
class PaymentMethodActions extends _$PaymentMethodActions {
  @override
  FutureOr<void> build() {}

  Future<VerifyUpiResponse> verifyUpi(String upiId) {
    return ref.read(paymentsRepositoryProvider).verifyUpi(upiId);
  }

  Future<PaymentMethod> addUpi({
    required String upiId,
    required String displayLabel,
    bool isDefault = false,
  }) async {
    final method = await ref
        .read(paymentsRepositoryProvider)
        .createMethod(
          type: 'upi',
          providerToken: upiId,
          displayLabel: displayLabel,
          isDefault: isDefault,
        );
    ref.invalidate(paymentMethodsProvider);
    return method;
  }

  Future<void> removeMethod(String methodId) async {
    await ref.read(paymentsRepositoryProvider).deleteMethod(methodId);
    ref.invalidate(paymentMethodsProvider);
  }
}
