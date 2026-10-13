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
    @Default(false) bool otpSendInProgress,
    Object? sendOtpError,
    @Default(false) bool otpVerifyInProgress,
    Object? verifyOtpError,
  }) = _AuthState;
}

@Riverpod(keepAlive: true)
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

    final inFlight = state.value;
    if (inFlight != null &&
        (inFlight.otpSendInProgress ||
            inFlight.otpChallenge != null ||
            inFlight.step == AuthFlowStep.otpSent)) {
      return inFlight;
    }

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
    state = AsyncData(
      current.copyWith(
        phone: indianMobileDigitsOnly(phone),
        sendOtpError: null,
      ),
    );
  }

  void setOtp(String otp) {
    final current = state.value ?? const AuthState();
    state = AsyncData(current.copyWith(otp: otp, verifyOtpError: null));
  }

  Future<void> sendOtp() async {
    final previous = state.value ?? const AuthState();
    if (previous.otpSendInProgress) {
      return;
    }

    final phone = normalizeIndianPhone(previous.phone);
    if (!isValidIndianPhone(phone)) {
      return;
    }

    state = AsyncData(
      previous.copyWith(
        otpSendInProgress: true,
        sendOtpError: null,
        verifyOtpError: null,
      ),
    );

    try {
      final challenge = await ref.read(authServiceProvider).sendOtp(phone);
      state = AsyncData(
        previous.copyWith(
          otpSendInProgress: false,
          sendOtpError: null,
          verifyOtpError: null,
          step: AuthFlowStep.otpSent,
          phone: indianMobileDigitsOnly(phone),
          otpChallenge: challenge,
          otp: '',
        ),
      );
    } catch (error) {
      state = AsyncData(
        previous.copyWith(otpSendInProgress: false, sendOtpError: error),
      );
    }
  }

  /// Verifies the entered OTP.
  ///
  /// Returns the signed-in [User] on success, or `null` on failure. Unlike a
  /// raw [AsyncValue.guard], this preserves the existing [AuthState] (phone,
  /// entered code) while verifying so the OTP screen never blanks mid-request.
  Future<User?> verifyOtp() async {
    final previous = state.value ?? const AuthState();
    if (previous.otpVerifyInProgress) {
      return null;
    }

    final challenge = previous.otpChallenge;
    if (challenge == null) {
      state = AsyncData(
        previous.copyWith(
          verifyOtpError: StateError('OTP session is missing'),
        ),
      );
      return null;
    }

    state = AsyncData(
      previous.copyWith(otpVerifyInProgress: true, verifyOtpError: null),
    );

    try {
      final result = await ref
          .read(authServiceProvider)
          .verifyOtp(otpSessionId: challenge.otpSessionId, otp: previous.otp);
      state = AsyncData(
        previous.copyWith(
          step: AuthFlowStep.signedIn,
          user: result.user,
          otpVerifyInProgress: false,
          verifyOtpError: null,
        ),
      );
      unawaited(
        ref.read(pushRegistrationServiceProvider).registerDeviceIfNeeded(),
      );
      return result.user;
    } catch (error) {
      state = AsyncData(
        previous.copyWith(otpVerifyInProgress: false, verifyOtpError: error),
      );
      return null;
    }
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
