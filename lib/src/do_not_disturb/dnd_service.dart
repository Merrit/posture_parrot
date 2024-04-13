import 'package:flutter/foundation.dart';

import '../logs/logging_manager.dart';
import 'dnd_service_linux.dart';

/// A service that monitors the system's Do Not Disturb (DND) status.
class DndService {
  final DndServiceLinux _dndServiceLinux = DndServiceLinux();

  /// Returns whether Do Not Disturb is enabled.
  Future<bool> isDndEnabled() async {
    switch (defaultTargetPlatform) {
      case TargetPlatform.linux:
        return await _dndServiceLinux.isDndEnabled();
      case TargetPlatform.windows:
        // return await _windowsIsDndEnabled();
        log.w('DndService Windows is not implemented');
        return false;
      default:
        log.w('Unable to determine DND status on this platform.');
        return false;
    }
  }
}
