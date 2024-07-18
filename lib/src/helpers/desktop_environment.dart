import 'dart:io';

/// Represents Linux desktop environments.
enum DesktopEnvironment {
  gnome,
  kde,
  xfce,
  unknown,
}

/// Returns the desktop environment.
DesktopEnvironment getDesktopEnvironment() {
  final String? xdgCurrentDesktop = Platform.environment['XDG_CURRENT_DESKTOP'];

  switch (xdgCurrentDesktop) {
    case 'GNOME':
      return DesktopEnvironment.gnome;
    case 'KDE':
      return DesktopEnvironment.kde;
    case 'XFCE':
      return DesktopEnvironment.xfce;
    default:
      return DesktopEnvironment.unknown;
  }
}
