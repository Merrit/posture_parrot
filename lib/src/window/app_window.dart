import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart' as window_size;

import '../logs/logging_manager.dart';

enum WindowEvent {
  close,
}

class AppWindow with WindowListener {
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
      await _maximize();
    });

    windowManager.addListener(this);
    await windowManager.setPreventClose(true);
  }

  Future<void> center() async => await windowManager.center();

  void close() {
    dispose();
    exit(0);
  }

  void dispose() => windowManager.removeListener(this);

  /// Focuses the window.
  Future<void> focus() async => await windowManager.focus();

  Future<void> hide() async => await windowManager.hide();

  Stream<WindowEvent> get events => _windowEventController.stream;

  final StreamController<WindowEvent> _windowEventController =
      StreamController<WindowEvent>.broadcast();

  @override
  void onWindowEvent(String eventName) {
    log.d('Window event: $eventName');

    switch (eventName) {
      case 'close':
        _windowEventController.add(WindowEvent.close);
    }
  }

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

  /// Maximizes the window.
  ///
  /// We maximize the window so the break timer will be centered on the screen,
  /// and the remainder of the window without decorations can provide a dimming effect.
  Future<void> _maximize() async {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      await windowManager.maximize();
    } else {
      await _maximizeForWindows();
    }
  }

  /// Sets the window size to the same size as the screen's visible frame.
  ///
  /// This is a workaround for Windows, because `windowManager.maximize()`
  /// causes the window to be shown when the app is started.
  ///
  /// This method doesn't work on Linux, because the resulting window won't
  /// cover the entire screen for some reason.
  Future<void> _maximizeForWindows() async {
    final currentScreen = await window_size.getCurrentScreen();

    if (currentScreen == null) {
      log.e('Could not get the current screen');
      return;
    }

    window_size.setWindowFrame(currentScreen.visibleFrame);
  }
}
