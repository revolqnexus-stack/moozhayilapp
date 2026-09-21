import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/app.dart';
import 'package:moozhayil/core/models/cart.dart';
import 'package:moozhayil/core/models/product.dart';
import 'package:moozhayil/core/models/vault_item.dart';
import 'package:moozhayil/core/models/goal.dart';
import 'package:moozhayil/core/models/gold_balance.dart';
import 'package:moozhayil/features/cart/providers/cart_provider.dart';
import 'package:moozhayil/features/goals/providers/goals_provider.dart';
import 'package:moozhayil/features/my_gold/providers/gold_balance_provider.dart';
import 'package:moozhayil/features/shop/providers/products_provider.dart';
import 'package:moozhayil/features/vault/providers/vault_provider.dart';

void main() {
  testWidgets('app shell smoke test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBannersProvider.overrideWith((ref) async => const <CmsBanner>[]),
          occasionsProvider.overrideWith((ref) async => const <CatalogRef>[]),
          featuredCollectionsProvider.overrideWith(
            (ref) async => const <CatalogRef>[],
          ),
          featuredProductsProvider.overrideWith(
            (ref) async => const <Product>[],
          ),
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
        ],
        child: const MoozhayilApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Moozhayil'), findsWidgets);
  });
}
