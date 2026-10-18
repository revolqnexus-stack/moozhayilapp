import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/error_state.dart';
import '../../../components/feedback/loading_shimmer.dart';
import '../../../components/navigation/top_app_bar.dart';
import '../../../components/overlays/price_breakdown_sheet.dart';
import '../../../components/product/product_image_gallery.dart';
import '../../../core/config/dev_preview.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/product.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';
import '../../../core/animations/add_to_cart_animation.dart';
import '../../../core/animations/bag_animation_targets.dart';
import '../../../core/animations/bag_celebration_overlay.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/sample_catalog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../vault/providers/vault_product_ids_display.dart';
import '../../vault/widgets/vault_save_handler.dart';
import '../providers/product_detail_provider.dart';
import '../widgets/product_detail_action_bar.dart';
import '../../../components/feedback/premium_snackbar.dart';
import '../../../core/constants/customer_copy.dart';
import '../widgets/product_detail_accordion.dart';
import '../widgets/product_video_call_bottom_sheet.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));
    final vaultIds = ref.watch(displayVaultProductIdsProvider);

    return product.when(
      data: (item) => _ProductDetailBody(
        item: item,
        vaultProductIds: vaultIds,
        productId: productId,
      ),
      loading: () {
        if (DevPreview.enabled) {
          final sample = SampleCatalog.productById(productId);
          if (sample != null) {
            return _ProductDetailBody(
              item: sample,
              vaultProductIds: vaultIds,
              productId: productId,
            );
          }
        }
        return Scaffold(
          backgroundColor: AppColors.paper,
          appBar: AppTopBar.minimal(),
          body: const Center(
            child: LoadingShimmer(
              width: double.infinity,
              height: AppSpacing.x3l * 4,
            ),
          ),
        );
      },
      error: (error, _) {
        if (DevPreview.enabled) {
          final sample = SampleCatalog.productById(productId);
          if (sample != null) {
            return _ProductDetailBody(
              item: sample,
              vaultProductIds: vaultIds,
              productId: productId,
            );
          }
        }
        return Scaffold(
          backgroundColor: AppColors.paper,
          appBar: AppTopBar.minimal(),
          body: ErrorState(
            headline: CustomerCopy.productLoadError,
            body: CustomerErrorCopy.message(error),
            onRetry: () => ref.invalidate(productDetailProvider(productId)),
          ),
        );
      },
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  const _ProductDetailBody({
    required this.item,
    required this.vaultProductIds,
    required this.productId,
  });

  final Product item;
  final Set<String> vaultProductIds;
  final String productId;

  @override
  ConsumerState<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<_ProductDetailBody> {
  var _addingToBag = false;
  var _bagAddedAck = false;
  final _heroImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final displayItem = productWithVaultState(
      widget.item,
      widget.vaultProductIds,
    );

    final eyebrow = displayItem.collection?.name ?? displayItem.category?.name;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: ListView(
        children: [
          ProductImageGallery(key: _heroImageKey, product: displayItem),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow.toUpperCase(),
                    style: AppTypography.uiMicro.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 9 * 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  displayItem.name,
                  style: AppTypography.headingLG.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    height: 1.12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  displayItem.price.totalDisplay,
                  style: AppTypography.priceLG.copyWith(
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!displayItem.stockAvailable) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Currently unavailable online',
                    style: AppTypography.uiBodySM.copyWith(
                      color: AppColors.brandBurgundy,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                const Divider(height: 0.5, color: AppColors.border),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${displayItem.purityDisplay} · ${displayItem.weightDisplay}',
                  style: AppTypography.uiBodySM.copyWith(
                    height: 1.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  displayItem.description ??
                      'A Moozhayil jewellery piece, crafted in hallmarked '
                          'gold to be worn today and treasured for a lifetime.',
                  style: AppTypography.uiBodySM.copyWith(
                    height: 1.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ProductDetailAccordion(
                  title: 'About',
                  body:
                      displayItem.description ??
                      'Hand-finished in our Pala atelier.',
                  initiallyExpanded: true,
                ),
                ProductDetailAccordion(
                  title: 'Care',
                  body: 'Store in the provided pouch. Clean with a soft cloth.',
                ),
                ProductDetailAccordion(
                  title: 'Shipping & returns',
                  body: 'Insured delivery across India. Returns within 7 days.',
                  onActionTap: () => showPriceBreakdownSheet(
                    context: context,
                    product: displayItem,
                  ),
                  actionLabel: 'View price breakdown',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductDetailActionBar(
        product: displayItem,
        isInVault: displayItem.isInVault,
        isOutOfStock: !displayItem.stockAvailable,
        isAddingToBag: _addingToBag,
        showBagAddedAck: _bagAddedAck,
        onAddToBag: !displayItem.stockAvailable
            ? null
            : () => _addToBag(context, displayItem),
        onBookVideoCall: () =>
            showProductVideoCallBottomSheet(context, product: displayItem),
        onToggleVault: () => handleVaultSave(context, ref, displayItem.id),
      ),
    );
  }

  Future<void> _addToBag(BuildContext context, Product product) async {
    final auth = ref.read(authControllerProvider).value;
    if (auth?.step != AuthFlowStep.signedIn) {
      context.push(
        Uri(
          path: AppRoutes.auth,
          queryParameters: {'from': GoRouterState.of(context).uri.toString()},
        ).toString(),
      );
      return;
    }

    AppHaptics.light();
    setState(() {
      _addingToBag = true;
      _bagAddedAck = false;
    });
    try {
      await ref.read(cartActionsProvider.notifier).addProduct(product.id);
      if (!mounted) return;
      setState(() {
        _addingToBag = false;
        _bagAddedAck = true;
      });

      AppHaptics.medium();
      if (context.mounted) {
        await _playAddToBagMotion(context, product);
      }

      if (context.mounted) {
        showPremiumSnackBar(
          context,
          CustomerCopy.addedToBag,
          actionLabel: CustomerCopy.viewBag,
          onAction: () => context.push(AppRoutes.cart),
        );
      }
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted) setState(() => _bagAddedAck = false);
    } on ApiException catch (_) {
      if (context.mounted) {
        showPremiumSnackBar(context, CustomerCopy.addToBagError, haptic: false);
      }
      if (mounted) {
        setState(() {
          _addingToBag = false;
          _bagAddedAck = false;
        });
      }
    }
  }

  Future<void> _playAddToBagMotion(
    BuildContext context,
    Product product,
  ) async {
    final imageUrl =
        product.primaryImage ??
        (product.images.isNotEmpty ? product.images.first.url : '');
    final heroBox =
        _heroImageKey.currentContext?.findRenderObject() as RenderBox?;
    final cartRect = BagAnimationTargets.cartIconRectOnScreen();

    if (imageUrl.isNotEmpty &&
        heroBox != null &&
        heroBox.hasSize &&
        cartRect != null) {
      final start = heroBox.localToGlobal(Offset.zero) & heroBox.size;
      final end = cartRect;
      final flightEnd = Rect.fromCenter(
        center: end.center,
        width: 44,
        height: 44,
      );
      final flightStart = Rect.fromCenter(
        center: start.center,
        width: start.width * 0.35,
        height: start.height * 0.35,
      );

      final flightDone = Completer<void>();
      showAddToCartAnimation(
        context: context,
        productImageUrl: imageUrl,
        productImageRect: flightStart,
        cartIconRect: flightEnd,
        onComplete: () => flightDone.complete(),
      );
      await flightDone.future.timeout(
        const Duration(milliseconds: 900),
        onTimeout: () {},
      );
    }

    if (context.mounted) {
      await showBagCelebrationOverlay(context);
    }
  }
}
