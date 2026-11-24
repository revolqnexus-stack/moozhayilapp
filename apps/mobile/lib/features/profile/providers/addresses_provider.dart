import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/address.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

part 'addresses_provider.g.dart';

class AddressesRepository {
  const AddressesRepository(this._apiService);

  final ApiService _apiService;

  Future<List<UserAddress>> list() async {
    try {
      final response = await _apiService.client.get<Map<String, dynamic>>(
        '/addresses',
      );
      return AddressListResponse.fromJson(response.data!).addresses;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<UserAddress> create(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/addresses',
        data: payload,
      );
      return UserAddress.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<UserAddress> update(
    String addressId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _apiService.client.patch<Map<String, dynamic>>(
        '/addresses/$addressId',
        data: payload,
      );
      return UserAddress.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<void> remove(String addressId) async {
    try {
      await _apiService.client.delete<void>('/addresses/$addressId');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<PincodeValidation> validatePincode(String pincode) async {
    try {
      final response = await _apiService.client.post<Map<String, dynamic>>(
        '/addresses/validate-pincode',
        data: {'pincode': pincode},
      );
      return PincodeValidation.fromJson(response.data!);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

@riverpod
AddressesRepository addressesRepository(Ref ref) {
  return AddressesRepository(ref.watch(apiServiceProvider));
}

@riverpod
Future<List<UserAddress>> userAddresses(Ref ref) async {
  if (watchSignedInUserId(ref) == null) {
    return const [];
  }

  return ref.watch(addressesRepositoryProvider).list();
}

@riverpod
class AddressActions extends _$AddressActions {
  @override
  FutureOr<void> build() {}

  Future<PincodeValidation> validatePincode(String pincode) {
    return ref.read(addressesRepositoryProvider).validatePincode(pincode);
  }

  Future<UserAddress> createAddress({
    String? label,
    required String fullName,
    required String phone,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
  }) async {
    final address = await ref.read(addressesRepositoryProvider).create({
      'label': label,
      'full_name': fullName,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
    });
    ref.invalidate(userAddressesProvider);
    return address;
  }

  Future<void> deleteAddress(String addressId) async {
    await ref.read(addressesRepositoryProvider).remove(addressId);
    ref.invalidate(userAddressesProvider);
  }
}
