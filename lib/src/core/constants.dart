import 'package:flutter/foundation.dart';
import 'package:helpers/helpers.dart';

const String kDonateUrl = 'https://merritt.codes/support/';
const String kPackageId = 'codes.merritt.PostureParrot';
const String kRepoUrl = 'https://github.com/Merrit/posture_parrot';
const String kWebsiteUrl = 'https://merritt.codes/postureparrot/';

/// The paths to the app's icons.
abstract class AppIcons {
  /// Asset directory containing the app's icons.
  static const String path = 'assets/icons';

  /// Normal icon as an SVG.
  static const String linux = '$path/$kPackageId.svg';

  /// Normal icon as an ICO.
  static const String windows = '$path/$kPackageId.ico';

  /// Normal icon with a red dot indicating a notification, as an SVG.
  static const String linuxWithNotificationBadge = '$path/$kPackageId-with-notification-badge.svg';

  /// Normal icon with a red dot indicating a notification, as an ICO.
  static const String windowsWithNotificationBadge =
      '$path/$kPackageId-with-notification-badge.ico';

  /// Symbolic icon as an SVG.
  static const String linuxSymbolic = '$path/$kPackageId-symbolic.svg';

  /// Symbolic icon as an ICO.
  static const String windowsSymbolic = '$path/$kPackageId-symbolic.ico';

  /// Symbolic icon with a red dot indicating a notification, as an SVG.
  static const String linuxSymbolicWithNotificationBadge =
      '$path/$kPackageId-symbolic-with-notification-badge.svg';

  /// Symbolic icon with a red dot indicating a notification, as an ICO.
  static const String windowsSymbolicWithNotificationBadge =
      '$path/$kPackageId-symbolic-with-notification-badge.ico';

  /// Returns the appropriate icon path (or icon name) based on the current platform.
  static String platformSpecific({bool symbolic = false}) {
    if (runningInFlatpak() || runningInSnap()) {
      // When running in a sandboxed environment the icon must be specified by
      // the icon's name, not the path.
      return kPackageId;
    }

    return (defaultTargetPlatform.isLinux)
        ? symbolic
            ? linuxSymbolic
            : linux
        : symbolic
            ? windowsSymbolic
            : windows;
  }
}
