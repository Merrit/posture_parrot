import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'src/app.dart';
import 'src/app/app.dart';
import 'src/break/break.dart';
import 'src/core/core.dart';
import 'src/do_not_disturb/dnd_service.dart';
import 'src/idle/idle_manager.dart';
import 'src/logs/logging_manager.dart';
import 'src/notifications/notifications.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/system_tray/system_tray_manager.dart';
import 'src/window/window.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool verbose = args.contains('--verbose') || const bool.fromEnvironment('VERBOSE');

  await LoggingManager.initialize(verbose: verbose);
  initializePlatformErrorHandler();

  final notificationService = await NotificationService.init(
    flutterLocalNotificationsPlugin: FlutterLocalNotificationsPlugin(),
  );

  final appWindow = AppWindow();
  await appWindow.initialize();

  final systemTrayManager = SystemTrayManager();
  await systemTrayManager.ensureInitialized();

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  final idleManager = IdleManager();
  final dndService = DndService();

  final breakCubit = BreakCubit(
    appWindow: appWindow,
    dndService: dndService,
    idleManager: idleManager,
    notificationService: notificationService,
    systemTrayManager: systemTrayManager,
  );

  // Create the AppCubit, which manages the app's state.
  AppCubit(
    appWindow: appWindow,
    breakCubit: breakCubit,
    systemTrayManager: systemTrayManager,
  );

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BreakCubit>.value(value: breakCubit),
      ],
      child: App(settingsController: settingsController),
    ),
  );
}
