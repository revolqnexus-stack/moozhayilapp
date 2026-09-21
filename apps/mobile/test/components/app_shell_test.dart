import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/app.dart';
import 'package:moozhayil/core/models/product.dart';
import 'package:moozhayil/core/models/cart.dart';
import 'package:moozhayil/core/models/kyc_status.dart';
import 'package:moozhayil/core/models/user.dart';
import 'package:moozhayil/core/models/vault_item.dart';
import 'package:moozhayil/core/models/goal.dart';
import 'package:moozhayil/core/models/gold_balance.dart';
import 'package:moozhayil/features/goals/providers/goals_provider.dart';
import 'package:moozhayil/features/orders/providers/orders_provider.dart';
import 'package:moozhayil/features/orders/providers/payments_provider.dart';
import 'package:moozhayil/core/models/aura_session.dart';
import 'package:moozhayil/core/models/notification.dart';
import 'package:moozhayil/core/models/referral.dart';
import 'package:moozhayil/core/models/store_location.dart';
import 'package:moozhayil/features/aura/providers/aura_provider.dart';
import 'package:moozhayil/features/notifications/providers/notifications_provider.dart';
import 'package:moozhayil/features/referrals/providers/referrals_provider.dart';
import 'package:moozhayil/features/store/providers/stores_provider.dart';
import 'package:moozhayil/core/models/order.dart';
import 'package:moozhayil/features/profile/providers/addresses_provider.dart';
import 'package:moozhayil/features/my_gold/providers/gold_balance_provider.dart';
import 'package:moozhayil/features/shop/providers/products_provider.dart';
import 'package:moozhayil/features/auth/providers/auth_provider.dart';
import 'package:moozhayil/features/cart/providers/cart_provider.dart';
import 'package:moozhayil/features/profile/providers/kyc_provider.dart';
import 'package:moozhayil/features/profile/providers/profile_provider.dart';
import 'package:moozhayil/features/vault/providers/vault_provider.dart';

/// Smoke tests for the full navigation shell.
void main() {
  const testUser = User(
    id: 'usr_test',
    phone: '+919876543210',
    name: 'Nikita Liby',
    kycStatus: 'not_started',
    kycDisplay: 'Complete KYC',
  );

  Widget buildApp() => ProviderScope(
    overrides: [
      authControllerProvider.overrideWith(
        () => _SignedInAuthController(testUser),
      ),
      profileUserProvider.overrideWith((ref) async => testUser),
      kycStatusProvider.overrideWith(
        (ref) async => const KycStatusResponse(kycStatus: 'not_started'),
      ),
      homeBannersProvider.overrideWith((ref) async => const <CmsBanner>[]),
      occasionsProvider.overrideWith((ref) async => const <CatalogRef>[]),
      featuredCollectionsProvider.overrideWith(
        (ref) async => const <CatalogRef>[],
      ),
      featuredProductsProvider.overrideWith((ref) async => const <Product>[]),
      productsProvider.overrideWith((ref) async => const <Product>[]),
      vaultItemsProvider.overrideWith(
        (ref) async => const VaultListResponse(items: [], count: 0),
      ),
      cartSummaryProvider.overrideWith(
        (ref) async => const CartSummary(
          items: [],
          subtotalPaise: 0,
          subtotalDisplay: '₹0',
          itemCount: 0,
        ),
      ),
      effectiveVaultProductIdsProvider.overrideWith((ref) async => {}),
      goalsListProvider.overrideWith(
        (ref, status) async => GoalsListResponse(
          goals: const [],
          summary: GoalsSummary(
            totalGrams: '0.0000',
            totalGramsDisplay: '0.0g',
            totalValuePaise: 0,
            totalValueDisplay: '₹0',
            activeCount: 0,
            monthlyTotalPaise: 0,
            monthlyTotalDisplay: '₹0/mo',
          ),
        ),
      ),
      goldBalanceProvider.overrideWith(
        (ref) async => const GoldBalance(
          totalGrams: '0.0000',
          totalGramsDisplay: '0.0g',
          totalValuePaise: 0,
          totalValueDisplay: '₹0',
          rateUsed: GoldRateUsed(
            purity: '22k',
            ratePaise: 624000,
            rateDisplay: '₹6,240/g',
            updatedAt: '2026-06-26T04:30:00Z',
          ),
        ),
      ),
      goldLedgerProvider.overrideWith(
        (ref) async => const GoldLedgerResponse(data: [], hasMore: false),
      ),
      redeemableProductsProvider.overrideWith((ref) async => const []),
      ordersListProvider.overrideWith(
        (ref, status) async =>
            const OrdersListResponse(data: [], hasMore: false),
      ),
      userAddressesProvider.overrideWith((ref) async => const []),
      paymentMethodsProvider.overrideWith((ref) async => const []),
      notificationsListProvider.overrideWith(
        (ref, unreadOnly) async => const NotificationsListResponse(
          data: [],
          unreadCount: 0,
          hasMore: false,
        ),
      ),
      notificationPreferencesProvider.overrideWith(
        (ref) async => const NotificationPreferences(
          pushEnabled: true,
          contributionsEnabled: true,
          milestonesEnabled: true,
          ordersEnabled: true,
          kycEnabled: true,
          auraEnabled: true,
          goldRateAlertEnabled: false,
        ),
      ),
      auraInsightProvider.overrideWith(
        (ref) async => const AuraInsightResponse(
          insightText: 'Explore Golden Wish to begin your jewellery journey.',
          insightType: 'onboarding',
          linkRoute: '/golden-wish',
        ),
      ),
      referralCodeProvider.overrideWith(
        (ref) async => const ReferralCodeResponse(
          referralCode: 'PRIYA2026',
          shareUrl: 'https://moozhayil.com/r/PRIYA2026',
          rewardDescription: 'Both you and your friend get ₹500 in gold credit',
          successfulReferrals: 0,
          pendingReferrals: 0,
        ),
      ),
      referralHistoryProvider.overrideWith(
        (ref) async => const ReferralHistoryResponse(referrals: []),
      ),
      storesListProvider.overrideWith(
        (
          ref,
          ({String? q, double? lat, double? lng, int? radiusKm}) args,
        ) async => const StoresListResponse(stores: []),
      ),
    ],
    child: const MoozhayilApp(),
  );

  Future<void> pumpAppShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel('Open navigation menu'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> navigateViaDrawer(WidgetTester tester, String label) async {
    await openDrawer(tester);
    await tester.tap(find.text(label).last);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  group('AppShell smoke test', () {
    testWidgets('renders without throwing', (tester) async {
      await pumpAppShell(tester);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('drawer exposes primary navigation links', (tester) async {
      await pumpAppShell(tester);
      await openDrawer(tester);

      expect(find.text('Home'), findsWidgets);
      expect(find.text('Shop'), findsWidgets);
      expect(find.text('Schemes'), findsWidgets);
      expect(find.text('Dream Vault'), findsWidgets);
      expect(find.text('My Gold'), findsWidgets);
      expect(find.text('AI Advisor'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);
    });

    testWidgets('drawer navigates to Shop branch', (tester) async {
      await pumpAppShell(tester);
      await navigateViaDrawer(tester, 'Shop');

      expect(find.text('Browse by occasion'), findsOneWidget);
    });

    testWidgets('drawer navigates to Schemes branch', (tester) async {
      await pumpAppShell(tester);
      await navigateViaDrawer(tester, 'Schemes');

      expect(find.text('Moozhayil purchase plans'), findsOneWidget);
    });

    testWidgets('drawer navigates to advisor branch', (tester) async {
      await pumpAppShell(tester);
      await navigateViaDrawer(tester, 'AI Advisor');

      expect(find.text('Help me choose a plan'), findsOneWidget);
    });

    testWidgets('bottom tab bar shows five primary tabs', (tester) async {
      await pumpAppShell(tester);

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('SHOP'), findsOneWidget);
      expect(find.text('SCHEMES'), findsWidgets);
      expect(find.text('ADVISOR'), findsOneWidget);
      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('WISHLIST'), findsNothing);
    });

    testWidgets('tapping Schemes tab navigates to Schemes branch', (
      tester,
    ) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('SCHEMES').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Moozhayil purchase plans'), findsOneWidget);
    });

    testWidgets('tapping AI tab navigates to advisor branch', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('ADVISOR'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Help me choose a plan'), findsOneWidget);
    });

    testWidgets('tapping Shop tab navigates to Shop branch', (tester) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('SHOP'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Browse by occasion'), findsOneWidget);
    });

    testWidgets('top bar Dream Vault icon opens Dream Vault screen', (
      tester,
    ) async {
      await pumpAppShell(tester);

      await tester.tap(find.bySemanticsLabel('Dream Vault'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Your Dream Vault is waiting.'), findsOneWidget);
    });

    testWidgets('tapping Profile tab navigates to Profile branch', (
      tester,
    ) async {
      await pumpAppShell(tester);

      await tester.tap(find.text('PROFILE'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Nikita Liby'), findsOneWidget);
    });

    testWidgets('drawer navigates to Profile branch', (tester) async {
      await pumpAppShell(tester);
      await navigateViaDrawer(tester, 'Profile');

      expect(find.text('Nikita Liby'), findsOneWidget);
    });

    testWidgets('top app bar shows brand wordmark on home', (tester) async {
      await pumpAppShell(tester);

      expect(find.text('Moozhayil'), findsWidgets);
    });
  });
}

class _SignedInAuthController extends AuthController {
  _SignedInAuthController(this.user);

  final User user;

  @override
  Future<AuthState> build() async =>
      AuthState(step: AuthFlowStep.signedIn, user: user, phone: user.phone);
}
