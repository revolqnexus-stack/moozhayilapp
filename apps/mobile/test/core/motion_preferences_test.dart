import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moozhayil/core/utils/motion_preferences.dart';

void main() {
  testWidgets('premiumMotionEnabled respects disableAnimations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _Probe(),
        ),
      ),
    );

    expect(find.text('off'), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: false),
          child: _Probe(),
        ),
      ),
    );

    expect(find.text('on'), findsOneWidget);
  });
}

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    return Text(premiumMotionEnabled(context) ? 'on' : 'off');
  }
}
