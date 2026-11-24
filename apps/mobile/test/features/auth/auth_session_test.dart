import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/models/user.dart';
import 'package:moozhayil/core/services/api_service.dart';
import 'package:moozhayil/core/services/auth_service.dart';
import 'package:moozhayil/core/services/push_registration_service.dart';
import 'package:moozhayil/features/auth/providers/auth_provider.dart';

class FakeAuthService implements AuthService {
  Object? meError;
  User? meResult;

  @override
  Future<User> me() async {
    if (meError != null) throw meError!;
    return meResult!;
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class NoopPush implements PushRegistrationService {
  @override
  Future<void> registerDeviceIfNeeded() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _user = User(
  id: 'usr_preview',
  phone: '+919876543210',
  name: 'Updated Name',
  kycStatus: 'verified',
);

void main() {
  // Tests run in debug mode, so AuthController.build() starts signed in as
  // the DevPreview user without touching the network.
  late ProviderContainer container;
  late FakeAuthService auth;

  setUp(() {
    auth = FakeAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        pushRegistrationServiceProvider.overrideWithValue(NoopPush()),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('refreshMe failure keeps the user signed in', () async {
    final before = await container.read(authControllerProvider.future);
    expect(before.step, AuthFlowStep.signedIn);

    auth.meError = const ApiException('Too many requests', code: 'RATE_LIMITED');
    await container.read(authControllerProvider.notifier).refreshMe();

    final after = container.read(authControllerProvider);
    expect(after.hasError, isFalse);
    expect(after.value!.step, AuthFlowStep.signedIn);
    expect(after.value!.user, before.user);
  });

  test('refreshMe success updates the user', () async {
    await container.read(authControllerProvider.future);

    auth.meResult = _user;
    await container.read(authControllerProvider.notifier).refreshMe();

    final after = container.read(authControllerProvider).value!;
    expect(after.step, AuthFlowStep.signedIn);
    expect(after.user!.name, 'Updated Name');
    expect(after.user!.kycStatus, 'verified');
  });

  test('data providers do not rebuild on unrelated auth changes', () async {
    await container.read(authControllerProvider.future);

    var builds = 0;
    final probe = Provider<String?>((ref) {
      builds++;
      return watchSignedInUserId(ref);
    });
    final sub = container.listen(probe, (_, _) {});
    expect(sub.read(), 'usr_preview');
    expect(builds, 1);

    // Same user, different profile data and form fields.
    auth.meResult = _user;
    await container.read(authControllerProvider.notifier).refreshMe();
    container.read(authControllerProvider.notifier).setPhone('9876543210');
    container.read(authControllerProvider.notifier).setOtp('123456');
    await container.pump();

    expect(builds, 1);
    sub.close();
  });

  test('logout switches data providers to signed-out', () async {
    await container.read(authControllerProvider.future);
    final probe = Provider<String?>((ref) => watchSignedInUserId(ref));
    final sub = container.listen(probe, (_, _) {});
    expect(sub.read(), 'usr_preview');

    await container.read(authControllerProvider.notifier).logout();
    await container.pump();

    expect(sub.read(), isNull);
    sub.close();
  });
}
