import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

import '../core/core.dart';
import '../window/window.dart';

/// Manages the system tray icon.
class SystemTrayManager {
  final AppWindow _window;

  SystemTrayManager({
    required AppWindow appWindow,
  }) : _window = appWindow;

  Future<void> ensureInitialized() async {
    final String iconPath = AppIcons.platformSpecific();

    await trayManager.setIcon(iconPath);

    _menu = Menu(
      items: [
        MenuItem(label: 'Exit', onClick: (menuItem) => _window.close()),
      ],
    );

    if (kDebugMode) {
      // Add a debug menu item to toggle the window's visibility.
      _menu.items?.insert(
        0,
        MenuItem(
          label: 'Debug: Toggle Visible',
          onClick: (menuItem) async {
            await _window.toggleVisible();
          },
        ),
      );
    }

    await trayManager.setContextMenu(_menu);
  }

  Menu _menu = Menu();

  /// Sets the system tray icon.
  Future<void> setIcon(String iconPath) async {
    await trayManager.setIcon(iconPath);
  }

  Future<void> updateTimeRemaining(Duration timeRemaining) async {
    /// If `_menu` already has an item with a label that contains 'Next Break:', remove it.
    _menu.items?.removeWhere((element) => element.label?.contains('Next Break:') ?? false);

    _menu.items?.insert(
      0,
      MenuItem(
        key: timeRemaining.inSeconds.toString(),
        label: 'Next Break: ${timeRemaining.asString}',
        onClick: (menuItem) => _window.show(),
      ),
    );

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
