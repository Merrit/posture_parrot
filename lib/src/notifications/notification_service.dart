import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helpers/helpers.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/core.dart';
import '../logs/logging_manager.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService._(this._notificationsPlugin);

  static Future<NotificationService> init({
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    tz.initializeTimeZones();
    final localTimeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(localTimeZoneName));

    const initSettingsAndroid = AndroidInitializationSettings('app_icon');
    const initSettingsDarwin = DarwinInitializationSettings();
    final initSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon(AppIcons.linux),
    );

    final initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsDarwin,
        macOS: initSettingsDarwin,
        linux: initSettingsLinux);

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: _notificationBackgroundCallback,
      onDidReceiveNotificationResponse: _notificationCallback,
    );

    if (defaultTargetPlatform.isWindows) {
      // await localNotifier.setup(appName: kPackageId);
    }

    return NotificationService._(flutterLocalNotificationsPlugin);
  }

  static const _androidNotificationDetails = AndroidNotificationDetails(
    kPackageId,
    'App notifications',
    actions: [
      AndroidNotificationAction(
        'complete',
        'Complete',
      ),
      AndroidNotificationAction(
        'snooze',
        'Snooze',
      ),
    ],
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: DefaultStyleInformation(true, true),
  );

  static const _iOSNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _macOSNotificationDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const _linuxNotificationDetails = LinuxNotificationDetails(
    // actions: [
    //   LinuxNotificationAction(
    //     key: 'complete',
    //     label: 'Complete',
    //   ),
    //   LinuxNotificationAction(
    //     key: 'snooze',
    //     label: 'Snooze',
    //   ),
    // ],
    // defaultActionName: 'Open notification',
    transient: true,
    urgency: LinuxNotificationUrgency.low,
  );

  /// Cancel a notification.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Show a notification.
  ///
  /// This will only show a notification if notifications are enabled and
  /// permission has been granted.
  ///
  /// [id] is a unique identifier for the notification. If not specified, a
  /// random id will be generated. The id must fit within a 32-bit integer.
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    log.t('Showing notification: $title, $body, $payload');

    id ??= _generateNotificationId();

    const notificationDetails = NotificationDetails(
      android: _androidNotificationDetails,
      iOS: _iOSNotificationDetails,
      macOS: _macOSNotificationDetails,
      linux: _linuxNotificationDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Generate a random id for a notification.
  ///
  /// The id will fit within a 32-bit integer as required by the plugin.
  int _generateNotificationId() {
    return Random().nextInt(1 << 30);
  }

  /// Schedule a notification on Windows.
  ///
  /// The `flutter_local_notifications` plugin does not support Windows yet.
  /// See: https://github.com/MaikuB/flutter_local_notifications/issues/746
  ///
  /// When the plugin is updated, this method should be removed and replaced
  /// with the appropriate method from the plugin.
  // Future<void> _scheduleNotificationWindows(Notification notification) async {
  // final localNotification = LocalNotification();
  // localNotification.onClick = () {};
  // localNotification.show();
  // }
}

/// A stream that emits a notification response when the user taps on a
/// notification.
final StreamController<NotificationResponse> notificationResponseStream =
    StreamController.broadcast();

/// Handle background notification actions.
///
/// This is called when the user taps on a notification action button.
///
/// On all platforms except Linux this runs in a separate isolate.
@pragma('vm:entry-point')
Future<void> _notificationBackgroundCallback(NotificationResponse response) async {
  await LoggingManager.initialize(verbose: true);
  initializePlatformErrorHandler();
  log.i('Notification response type: ${response.notificationResponseType}');

  // switch (response.actionId) {
  //   case 'complete':
  //     break;
  //   case 'snooze':
  //     break;
  // }
}

/// Called when the user taps on a notification.
Future<void> _notificationCallback(NotificationResponse response) async {
  log.i('Notification response type: ${response.notificationResponseType}');

  // switch (response.notificationResponseType) {
  //   case NotificationResponseType.selectedNotification:
  //     if (defaultTargetPlatform.isDesktop) {
  //       // On desktop, the app is already running so we can just show the window.
  //       await AppWindow.instance.show();
  //       await AppWindow.instance.focus();
  //     }

  //     notificationResponseStream.add(response);
  //     break;
  //   case NotificationResponseType.selectedNotificationAction:
  //     // response.actionId will be either `complete` or `snooze`.
  //     notificationResponseStream.add(response);
  //     break;
  // }
}
