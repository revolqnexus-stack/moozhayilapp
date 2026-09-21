import 'package:go_router/go_router.dart';

import '../../components/navigation/navigation_shell.dart';
import '../../features/aura/screens/aura_conversation_screen.dart';
import '../../features/aura/screens/aura_gold_insights_screen.dart';
import '../../features/aura/screens/aura_goal_planning_screen.dart';
import '../../features/aura/screens/aura_product_discovery_screen.dart';
import '../../features/aura/screens/aura_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/golden_wish/screens/golden_wish_screen.dart';
import '../../features/golden_wish/screens/my_plans_screen.dart';
import '../../features/golden_wish/screens/plan_detail_screen.dart';
import '../../features/goals/screens/amount_screen.dart';
import '../../features/goals/screens/confirmation_screen.dart';
import '../../features/goals/screens/contribute_screen.dart';
import '../../features/goals/screens/goal_detail_screen.dart';
import '../../features/goals/screens/moment_screen.dart';
import '../../features/goals/screens/piece_screen.dart';
import '../../features/goals/screens/payment_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/my_gold/screens/my_gold_screen.dart';
import '../../features/onboarding/screens/intent_screen.dart';
import '../../features/onboarding/screens/kyc_intro_screen.dart';
import '../../features/onboarding/screens/name_screen.dart';
import '../../features/onboarding/screens/onboarding_carousel_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/profile/screens/kyc_landing_screen.dart';
import '../../features/profile/screens/aadhaar_screen.dart';
import '../../features/profile/screens/aadhaar_otp_screen.dart';
import '../../features/profile/screens/pan_screen.dart';
import '../../features/profile/screens/selfie_screen.dart';
import '../../features/profile/screens/kyc_review_screen.dart';
import '../../features/profile/screens/kyc_pending_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/shop/screens/collection_screen.dart';
import '../../features/shop/screens/product_detail_screen.dart';
import '../../features/shop/screens/search_screen.dart';
import '../../features/shop/screens/new_arrivals_screen.dart';
import '../../features/shop/screens/shop_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/profile/screens/addresses_screen.dart';
import '../../features/vault/screens/dream_vault_screen.dart';
import '../../features/orders/screens/checkout_screen.dart';
import '../../features/orders/screens/order_confirmation_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/orders/screens/payment_methods_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/referrals/screens/referrals_screen.dart';
import '../../features/dev/screens/dev_screen_gallery.dart';
import '../../features/store/screens/store_locator_screen.dart';
import '../config/dev_preview.dart';
import 'app_routes.dart';

/// The application's GoRouter instance.
///
/// Structure:
///   [StatefulShellRoute.indexedStack] — wraps the 6 persistent tab branches.
///     Branch 0: /home
///     Branch 1: /shop  (+ sub-routes)
///     Branch 2: /golden-wish  (Schemes tab)
///     Branch 3: /aura  (AI Advisor — customer label only)
///     Branch 4: /profile (+ sub-routes)
///
///   Top-level routes (no shell — no bottom tab bar):
///     /onboarding, /auth, /dream-vault, /my-gold, /my-plans, /goals, /orders,
///     /notifications, /store-locator, /referrals,
///     + goal creation flow (/goals/create/*)
///
/// Rule 8 (09-cursor-rules.md): Navigation MUST go through [context.push] /
/// [context.go] using constants from [AppRoutes]. Never use Navigator.push.
final GoRouter appRouter = createAppRouter();

GoRouter createAppRouter({AuthState? authState}) => GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    if (authState == null) {
      return null;
    }

    final location = state.uri.path;
    final isPublicRoute =
        location.startsWith(AppRoutes.auth) ||
        location.startsWith(AppRoutes.onboarding) ||
        (DevPreview.enabled && location.startsWith('/dev'));
    final isSignedIn = authState.step == AuthFlowStep.signedIn;

    if (!isSignedIn && !isPublicRoute) {
      return Uri(
        path: AppRoutes.auth,
        queryParameters: {'from': state.uri.toString()},
      ).toString();
    }

    if (isSignedIn && location.startsWith(AppRoutes.auth)) {
      final from = state.uri.queryParameters['from'];
      final name = authState.user?.name;
      if (name == null || name.isEmpty) {
        return AppRoutes.onboardingIntent;
      }
      return from ?? AppRoutes.home;
    }

    return null;
  },
  routes: [
    // ── Persistent tab shell ───────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          NavigationShell(navigationShell: navigationShell),
      branches: [
        // Branch 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Branch 1 — Shop
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.shop,
              builder: (context, state) => const ShopScreen(),
              routes: [
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const SearchScreen(),
                ),
                GoRoute(
                  path: 'category/:categoryId',
                  builder: (context, state) => ProductListScreen(
                    categoryId: state.pathParameters['categoryId']!,
                  ),
                ),
                GoRoute(
                  path: 'occasion/:occasionId',
                  builder: (context, state) => OccasionScreen(
                    occasionId: state.pathParameters['occasionId']!,
                  ),
                ),
                GoRoute(
                  path: 'collection/:collectionId',
                  builder: (context, state) => CollectionScreen(
                    collectionId: state.pathParameters['collectionId']!,
                  ),
                ),
                GoRoute(
                  path: 'product/:productId',
                  builder: (context, state) => ProductDetailScreen(
                    productId: state.pathParameters['productId']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Branch 2 — Golden Wish
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.goldenWish,
              builder: (context, state) => const GoldenWishScreen(),
              routes: [
                GoRoute(
                  path: 'plans/:planSlug',
                  builder: (context, state) => PlanDetailScreen(
                    planSlug: state.pathParameters['planSlug']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Branch 3 — AI Advisor (/aura internally)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.aura,
              builder: (context, state) => const AuraScreen(),
              routes: [
                GoRoute(
                  path: 'conversation/:sessionId',
                  builder: (context, state) => AuraConversationScreen(
                    sessionId: state.pathParameters['sessionId']!,
                  ),
                ),
                GoRoute(
                  path: 'goal-planning',
                  builder: (context, state) => const AuraGoalPlanningScreen(),
                ),
                GoRoute(
                  path: 'product-discovery',
                  builder: (context, state) =>
                      const AuraProductDiscoveryScreen(),
                ),
                GoRoute(
                  path: 'gold-insights',
                  builder: (context, state) => const AuraGoldInsightsScreen(),
                ),
              ],
            ),
          ],
        ),

        // Branch 4 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'kyc',
                  builder: (context, state) => KycLandingScreen(
                    returnRoute: state.uri.queryParameters['from'],
                  ),
                  routes: [
                    GoRoute(
                      path: 'aadhaar',
                      builder: (context, state) => const AadhaarScreen(),
                      routes: [
                        GoRoute(
                          path: 'otp',
                          builder: (context, state) => const AadhaarOtpScreen(),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: 'pan',
                      builder: (context, state) => const PanScreen(),
                    ),
                    GoRoute(
                      path: 'selfie',
                      builder: (context, state) => const SelfieScreen(),
                    ),
                    GoRoute(
                      path: 'review',
                      builder: (context, state) => KycReviewScreen(
                        returnRoute: state.uri.queryParameters['from'],
                      ),
                    ),
                    GoRoute(
                      path: 'pending',
                      builder: (context, state) => KycPendingScreen(
                        returnRoute: state.uri.queryParameters['from'],
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'addresses',
                  builder: (context, state) => const AddressesScreen(),
                ),
                GoRoute(
                  path: 'payment-methods',
                  builder: (context, state) => const PaymentMethodsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.wishlist,
      redirect: (context, state) => AppRoutes.dreamVault,
    ),

    // ── Standalone routes ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
      routes: [
        GoRoute(
          path: 'carousel',
          builder: (context, state) => const OnboardingCarouselScreen(),
        ),
        GoRoute(
          path: 'intent',
          builder: (context, state) => const IntentScreen(),
        ),
        GoRoute(path: 'name', builder: (context, state) => const NameScreen()),
        GoRoute(
          path: 'kyc-intro',
          builder: (context, state) => const KycIntroScreen(),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) =>
          AuthScreen(from: state.uri.queryParameters['from']),
      routes: [
        GoRoute(
          path: 'otp',
          builder: (context, state) =>
              OtpScreen(from: state.uri.queryParameters['from']),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.dreamVault,
      builder: (context, state) => const DreamVaultScreen(),
    ),

    GoRoute(
      path: AppRoutes.myGold,
      builder: (context, state) => const MyGoldScreen(),
      routes: [
        GoRoute(
          path: 'redeem',
          builder: (context, state) => const RedeemScreen(),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.myPlans,
      builder: (context, state) => const MyPlansScreen(),
    ),

    GoRoute(
      path: AppRoutes.goals,
      redirect: (context, state) => AppRoutes.goldenWish,
    ),

    GoRoute(
      path: '/goals/:goalId',
      builder: (context, state) =>
          GoalDetailScreen(goalId: state.pathParameters['goalId']!),
      routes: [
        GoRoute(
          path: 'contribute',
          builder: (context, state) {
            final query = state.uri.queryParameters;
            final firstPayment = query['firstPayment'] == '1';
            final amountPaise = int.tryParse(query['amountPaise'] ?? '');
            return ContributeScreen(
              goalId: state.pathParameters['goalId']!,
              firstPayment: firstPayment,
              lockedAmountPaise: amountPaise,
            );
          },
        ),
      ],
    ),

    // Goal creation flow — standalone (multi-step, no tab bar)
    GoRoute(
      path: AppRoutes.goalsCreate,
      redirect: (context, state) => AppRoutes.goalsCreateMoment,
      routes: [
        GoRoute(
          path: 'moment',
          builder: (context, state) => const MomentScreen(),
        ),
        GoRoute(
          path: 'piece',
          builder: (context, state) => const PieceScreen(),
        ),
        GoRoute(
          path: 'amount',
          builder: (context, state) => const AmountScreen(),
        ),
        GoRoute(
          path: 'payment',
          builder: (context, state) => const PaymentSetupScreen(),
        ),
        GoRoute(
          path: 'confirmation',
          builder: (context, state) => const ConfirmationScreen(),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.cart,
      builder: (context, state) => const CartScreen(inTabShell: false),
    ),

    GoRoute(
      path: AppRoutes.newArrivals,
      builder: (context, state) => const NewArrivalsScreen(),
    ),

    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersScreen(),
      routes: [
        GoRoute(
          path: 'confirmation/:orderId',
          builder: (context, state) => OrderConfirmationScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
        GoRoute(
          path: ':orderId',
          builder: (context, state) =>
              OrderDetailScreen(orderId: state.pathParameters['orderId']!),
        ),
      ],
    ),

    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) {
        final redeemWithGold = state.uri.queryParameters['redeem'] == '1';
        return CheckoutScreen(redeemWithGold: redeemWithGold);
      },
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: AppRoutes.storeLocator,
      builder: (context, state) => const StoreLocatorScreen(),
    ),

    GoRoute(
      path: AppRoutes.referrals,
      builder: (context, state) => const ReferralsScreen(),
    ),

    if (DevPreview.enabled)
      GoRoute(
        path: AppRoutes.devScreens,
        builder: (context, state) => const DevScreenGallery(),
      ),
  ],
);
