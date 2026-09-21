import 'package:flutter/material.dart';
import '../constants/animations.dart';

/// Premium add-to-cart animation: product image gently flies into cart icon.
/// Call `AnimationController.forward()` to trigger the flight.
class AddToCartFlyingImage extends StatefulWidget {
  const AddToCartFlyingImage({
    super.key,
    required this.productImageUrl,
    required this.startRect,
    required this.endRect,
    required this.onComplete,
  });

  final String productImageUrl;
  final Rect startRect;
  final Rect endRect;
  final VoidCallback onComplete;

  @override
  State<AddToCartFlyingImage> createState() => _AddToCartFlyingImageState();
}

class _AddToCartFlyingImageState extends State<AddToCartFlyingImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Rect?> _rectTween;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AnimationPresets.addToCartFlight,
    );

    _rectTween = RectTween(begin: widget.startRect, end: widget.endRect)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: AnimationPresets.addToCartCurve,
          ),
        );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final rect = _rectTween.value ?? widget.startRect;
        return Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: Opacity(
            opacity: _fadeOut.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                widget.productImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Overlay helper to trigger add-to-cart flight animation.
void showAddToCartAnimation({
  required BuildContext context,
  required String productImageUrl,
  required Rect productImageRect,
  required Rect cartIconRect,
  required VoidCallback onComplete,
}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => AddToCartFlyingImage(
      productImageUrl: productImageUrl,
      startRect: productImageRect,
      endRect: cartIconRect,
      onComplete: () {
        onComplete();
        entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}
