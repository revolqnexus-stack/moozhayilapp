import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../time/server_clock_provider.dart';

/// Marks [serverClock] unsynced on resume until the next HTTP response re-syncs it.
class ServerClockLifecycle extends ConsumerStatefulWidget {
  const ServerClockLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ServerClockLifecycle> createState() =>
      _ServerClockLifecycleState();
}

class _ServerClockLifecycleState extends ConsumerState<ServerClockLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(serverClockProvider).markUnsyncedPendingResync();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
