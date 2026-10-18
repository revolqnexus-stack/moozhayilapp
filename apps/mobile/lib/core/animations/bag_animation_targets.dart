import 'package:flutter/material.dart';

/// Global keys for add-to-bag flight animations (shell app bar bag icon).
abstract final class BagAnimationTargets {
  static final cartIconKey = GlobalKey();

  static Rect? cartIconRectOnScreen() {
    final targetContext = cartIconKey.currentContext;
    if (targetContext == null) return null;

    final box = targetContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final topLeft = box.localToGlobal(Offset.zero);
    return topLeft & box.size;
  }
}
