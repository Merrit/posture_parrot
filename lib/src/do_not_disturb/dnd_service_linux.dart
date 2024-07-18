import 'dart:io';

import 'package:dbus/dbus.dart';

import '../helpers/helpers.dart';
import '../logs/logging_manager.dart';

/// A service that monitors the system's Do Not Disturb (DND) status on Linux.
class DndServiceLinux {
  /// The currently running desktop environment.
  final DesktopEnvironment _desktopEnvironment = getDesktopEnvironment();

  DndServiceLinux() {
    log.i('Desktop environment: $_desktopEnvironment');
  }

  /// Returns whether Do Not Disturb is enabled.
  Future<bool> isDndEnabled() async {
    switch (_desktopEnvironment) {
      case DesktopEnvironment.gnome:
        return _gnomeIsDndEnabled();
      case DesktopEnvironment.kde:
        return _kdeIsDndEnabled();
      case DesktopEnvironment.xfce:
        return _xfceIsDndEnabled();
      case DesktopEnvironment.unknown:
        return false;
    }
  }

  /// Returns whether Do Not Disturb is enabled in GNOME.
  Future<bool> _gnomeIsDndEnabled() async {
    final result = await Process.run(
      'gsettings',
      ['get', 'org.gnome.desktop.notifications', 'show-banners'],
    );

    if (result.exitCode != 0) {
      return false;
    }

    final String output = result.stdout as String;
    log.t('GNOME DND status: $output');
    return output.trim() == 'false';
  }

  /// Returns whether Do Not Disturb is enabled in KDE.
  Future<bool> _kdeIsDndEnabled() async {
    final client = DBusClient.session();

    final dbusObject = DBusRemoteObject(
      client,
      name: 'org.freedesktop.Notifications',
      path: DBusObjectPath('/org/freedesktop/Notifications'),
    );

    final dbusValue = await dbusObject.getProperty(
      'org.freedesktop.Notifications',
      'Inhibited',
      signature: DBusSignature('b'),
    );

    final bool inhibited = dbusValue.asBoolean();

    return inhibited;
  }

  /// Returns whether Do Not Disturb is enabled in Xfce.
  Future<bool> _xfceIsDndEnabled() async {
    final client = DBusClient.session();

    final dbusObject = DBusRemoteObject(
      client,
      name: 'org.xfce.Xfconf',
      path: DBusObjectPath('/org/xfce/Xfconf'),
    );

    final dbusResponse = await dbusObject.callMethod(
      'org.xfce.Xfconf',
      'GetProperty',
      [
        const DBusString('xfce4-notifyd'),
        const DBusString('/do-not-disturb'),
      ],
    );

    final dbusValue = dbusResponse.values.first;
    final bool dndEnabled = dbusValue.asBoolean();

    log.t('Xfce DND status: $dndEnabled');

    return dndEnabled;
  }
}
