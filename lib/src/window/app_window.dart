import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class AppWindow {
  const AppWindow();

  Future<void> initialize() async {
    await windowManager.ensureInitialized();

    const WindowOptions windowOptions = WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setAsFrameless();
      await windowManager.setSkipTaskbar(true);
      await windowManager.maximize();
    });
  }

  Future<void> center() async => await windowManager.center();

  void close() => exit(0);

  /// Focuses the window.
  Future<void> focus() async => await windowManager.focus();

  Future<void> hide() async => await windowManager.hide();

  /// Sets whether the window should be always on bottom.
  Future<void> setAlwaysOnBottom(bool alwaysOnBottom) async {
    await windowManager.setAlwaysOnBottom(alwaysOnBottom);
  }

  Future<void> setAsFrameless() async {
    await windowManager.setAsFrameless();
  }

  /// Sets the background color of the window.
  Future<void> setBackgroundColor(Color color) async {
    await windowManager.setBackgroundColor(color);
  }

  /// Sets whether the window should be shown in the taskbar.
  Future<void> setSkipTaskbar(bool skip) async {
    await windowManager.setSkipTaskbar(skip);
  }

  /// Sets the title bar visibility.
  Future<void> setTitleBarVisible(bool visible) async {
    final titleBarStyle = (visible) //
        ? TitleBarStyle.normal
        : TitleBarStyle.hidden;
    await windowManager.setTitleBarStyle(titleBarStyle);
  }

  Future<void> show() async => await windowManager.show();

  Future<void> toggleVisible() async {
    final isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
    }
  }
}
