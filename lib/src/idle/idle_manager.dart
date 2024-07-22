import 'package:flutter/foundation.dart';

import 'src/idle_manager_linux.dart';

enum IdleState { active, idle }

/// Service that checks if the user is idle.
///
/// Emits an event when the user's idle state changes.
abstract class IdleManager {
  factory IdleManager() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return IdleManagerLinuxKDE();
      default:
        return IdleManagerNotAvailable();
    }
  }

  /// Stream that emits an event when the user's idle state changes.
  Stream<IdleState> get userIdleState;

  Future<void> dispose();
}

/// A no-op implementation of [IdleManager] for platforms without idle detection.
class IdleManagerNotAvailable implements IdleManager {
  @override
  Stream<IdleState> get userIdleState => const Stream.empty();

  @override
  Future<void> dispose() async {}
}
