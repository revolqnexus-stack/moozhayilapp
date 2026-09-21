import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/auth_models.dart';
import '../../../core/config/dev_preview.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/push_registration_service.dart';
import '../../../core/utils/phone_utils.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

enum AuthFlowStep { signedOut, otpSent, signedIn }

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthFlowStep.signedOut) AuthFlowStep step,
    User? user,
    OtpChallenge? otpChallenge,
    @Default('') String phone,
    @Default('') String otp,
  }) = _AuthState;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<AuthState> build() async {
    // In debug/dev-preview mode skip the network call entirely so the emulator
    // never blocks on a missing backend during development.
    if (DevPreview.enabled) {
      unawaited(
        ref.read(pushRegistrationServiceProvider).registerDeviceIfNeeded(),
      );
      return AuthState(
        step: AuthFlowStep.signedIn,
        user: DevPreview.previewUser,
        phone: DevPreview.previewUser.phone,
      );
    }

    final user = await ref.read(authServiceProvider).restoreSession();
    if (user != null) {
      unawaited(
        ref.read(pushRegistrationServiceProvider).registerDeviceIfNeeded(),
      );
      return AuthState(
        step: AuthFlowStep.signedIn,
        user: user,
        phone: user.phone,
      );
    }

    return const AuthState();
  }

  void setPhone(String phone) {
    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(phone: phone));
  }

  void setOtp(String otp) {
    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(otp: otp));
  }

  Future<void> sendOtp() async {
    if (state.isLoading) {
      return;
    }

    final previous = state.value ?? const AuthState();
    final phone = normalizeIndianPhone(previous.phone);
    if (!isValidIndianPhone(phone)) {
      return;
    }

    state = await AsyncValue.guard(() async {
      final challenge = await ref.read(authServiceProvider).sendOtp(phone);
      return previous.copyWith(
        step: AuthFlowStep.otpSent,
        phone: phone,
        otpChallenge: challenge,
        otp: '',
      );
    });
  }

  Future<User> verifyOtp() async {
    final previous = state.value ?? const AuthState();
    final challenge = previous.otpChallenge;
    if (challenge == null) {
      throw StateError('OTP session is missing');
    }

    final result = await AsyncValue.guard(() async {
      final verifyResult = await ref
          .read(authServiceProvider)
          .verifyOtp(otpSessionId: challenge.otpSessionId, otp: previous.otp);
      return previous.copyWith(
        step: AuthFlowStep.signedIn,
        user: verifyResult.user,
      );
    });
    state = result;
    unawaited(
      ref.read(pushRegistrationServiceProvider).registerDeviceIfNeeded(),
    );
    return result.requireValue.user!;
  }

  Future<void> refreshMe() async {
    final previous = state.value ?? const AuthState();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).me();
      return previous.copyWith(step: AuthFlowStep.signedIn, user: user);
    });
  }

  Future<void> logout() async {
    final previous = state.value ?? const AuthState();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).logout();
      return AuthState(phone: previous.phone);
    });
  }
}
