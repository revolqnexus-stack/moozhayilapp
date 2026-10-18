import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../components/feedback/premium_snackbar.dart';
import '../../../core/models/product.dart';
import '../../../core/models/vault_item.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/customer_error_copy.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/vault_list_display.dart';
import '../providers/vault_product_ids_display.dart';
import '../providers/vault_provider.dart';
import 'goal_start_bottom_sheet.dart';

Product productWithVaultState(Product product, Set<String> vaultIds) {
  return product.copyWith(isInVault: vaultIds.contains(product.id));
}

Future<void> handleVaultSave(
  BuildContext context,
  WidgetRef ref,
  String productId,
) async {
  final ids = ref.read(displayVaultProductIdsProvider);
  final wasSaved = ids.contains(productId);

  if (wasSaved) {
    applyOptimisticVaultToggle(ref, productId: productId, saving: false);
    try {
      await ref.read(vaultActionsProvider.notifier).removeProduct(productId);
      forgetVaultProductInCache(ref, productId);
      ref.invalidate(vaultItemsProvider);
      ref.invalidate(effectiveVaultProductIdsProvider);
    } on ApiException catch (error) {
      revertOptimisticVaultToggle(ref, productId: productId, wasSaving: false);
      if (context.mounted) {
        showPremiumSnackBar(
          context,
          CustomerErrorCopy.message(error),
          haptic: false,
        );
      }
    }
    return;
  }

  applyOptimisticVaultToggle(ref, productId: productId, saving: true);

  final auth = ref.read(authControllerProvider).value;
  AddVaultResponse? response;
  try {
    response = await ref
        .read(vaultActionsProvider.notifier)
        .saveProduct(productId);
    ref.invalidate(vaultItemsProvider);
    ref.invalidate(effectiveVaultProductIdsProvider);
  } on ApiException catch (error) {
    revertOptimisticVaultToggle(ref, productId: productId, wasSaving: true);
    if (context.mounted) {
      showPremiumSnackBar(
        context,
        CustomerErrorCopy.message(error),
        haptic: false,
      );
    }
    return;
  }

  if (!context.mounted) {
    return;
  }

  if (auth?.step != AuthFlowStep.signedIn) {
    await showGuestVaultPrompt(
      context: context,
      onSignIn: () => context.push(
        Uri(
          path: AppRoutes.auth,
          queryParameters: {'from': GoRouterState.of(context).uri.toString()},
        ).toString(),
      ),
    );
    return;
  }

  if (response != null) {
    rememberVaultItemInCache(ref, response.vaultItem);
    await showGoalStartBottomSheet(
      context: context,
      ref: ref,
      item: response.vaultItem,
      goalSuggestion: response.goalSuggestion,
    );
  }
}
