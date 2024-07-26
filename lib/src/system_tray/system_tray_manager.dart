import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

import '../core/core.dart';

enum TrayEvent {
  exitApp,
  toggleVisibility,
}

/// Manages the system tray icon.
class SystemTrayManager {
  Menu _menu = Menu();

  Future<void> ensureInitialized() async {
    final String iconPath = AppIcons.platformSpecific();

    await trayManager.setIcon(iconPath);

    _menu = Menu(
      items: [
        MenuItem(label: 'Exit', onClick: (menuItem) => _trayEventController.add(TrayEvent.exitApp)),
      ],
    );

    if (kDebugMode) {
      // Add a debug menu item to toggle the window's visibility.
      _menu.items?.insert(
        0,
        MenuItem(
          label: 'Debug: Toggle Visible',
          onClick: (menuItem) async {
            _trayEventController.add(TrayEvent.toggleVisibility);
          },
        ),
      );
    }

    await trayManager.setContextMenu(_menu);
  }

  Stream<TrayEvent> get events => _trayEventController.stream;

  final StreamController<TrayEvent> _trayEventController = StreamController<TrayEvent>.broadcast();

  /// Sets the system tray icon.
  Future<void> setIcon(String iconPath) async {
    await trayManager.setIcon(iconPath);
  }

  Future<void> updateTimeRemaining(Duration timeRemaining) async {
    /// If `_menu` already has an item with a label that contains 'Next Break:', remove it.
    _menu.items?.removeWhere((element) => element.label?.contains('Next Break:') ?? false);

    if (timeRemaining == Duration.zero) {
      _menu.items?.insert(
        0,
        MenuItem(
          key: 'breaksPaused',
          label: 'Breaks Paused: Idle Detected',
        ),
      );
    } else {
      _menu.items?.removeWhere((element) => element.key == 'breaksPaused');

      _menu.items?.insert(
        0,
        MenuItem(
          key: timeRemaining.inSeconds.toString(),
          label: 'Next Break: ${timeRemaining.asString}',
        ),
      );
    }

    await trayManager.setContextMenu(_menu);
  }
}

extension on Duration {
  /// Returns the duration and its unit as a string.
  String get asString {
    final int minutes = inMinutes;
    final int seconds = inSeconds.remainder(60);

    if (minutes == 0) {
      return '$seconds seconds';
    }

    if (seconds == 0) {
      return '$minutes minutes';
    }

    return '$minutes minutes and $seconds seconds';
  }
}
