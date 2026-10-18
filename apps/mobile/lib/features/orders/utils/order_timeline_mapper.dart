import 'package:flutter/material.dart';

import '../../../core/animations/order_timeline_animation.dart';

/// Maps backend [Order.status] values to timeline step index (0-based).
///
/// Only uses statuses present in the API schema — no invented fulfilment steps.
int orderTimelineCurrentStep(String status) {
  switch (status) {
    case 'pending_payment':
      return 0;
    case 'confirmed':
      return 1;
    case 'shipped':
      return 2;
    case 'delivered':
      return 3;
    case 'cancelled':
      return 0;
    default:
      return 1;
  }
}

List<OrderTimelineStep> defaultOrderTimelineSteps() {
  return const [
    OrderTimelineStep(
      title: 'Order placed',
      subtitle: 'We received your order',
      icon: Icons.receipt_long_outlined,
    ),
    OrderTimelineStep(
      title: 'Confirmed',
      subtitle: 'Payment confirmed — preparing your piece',
      icon: Icons.verified_outlined,
    ),
    OrderTimelineStep(
      title: 'Shipped',
      subtitle: 'On its way with insured delivery',
      icon: Icons.local_shipping_outlined,
    ),
    OrderTimelineStep(
      title: 'Delivered',
      subtitle: 'Enjoy your Moozhayil piece',
      icon: Icons.check_circle_outline,
    ),
  ];
}

bool orderQualifiesForSuccessCelebration(String status) {
  return status == 'confirmed' || status == 'shipped' || status == 'delivered';
}
