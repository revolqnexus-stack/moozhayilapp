import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'server_clock.dart';

part 'server_clock_provider.g.dart';

/// Shared server-adjusted clock for rate staleness and price validity (Fix 1).
@Riverpod(keepAlive: true)
ServerClock serverClock(Ref ref) => ServerClock();
