import 'dart:async';
import 'dart:io';

import 'package:dbus/dbus.dart';

import '../../helpers/helpers.dart';
import '../../kwin_interface/kwin_interface.dart';
import '../../logs/logging_manager.dart';
import '../idle_manager.dart';
import 'idle_dbus_service.dart';

/// Linux implementation of [IdleManager].
abstract class IdleManagerLinux implements IdleManager {
  factory IdleManagerLinux() {
    final de = getDesktopEnvironment();

    switch (de) {
      case DesktopEnvironment.kde:
        return IdleManagerLinuxKDE();
      default:
        return IdleManagerLinuxNotAvailable();
    }
  }
}

/// A no-op implementation of [IdleManagerLinux] for unsupported desktop environments.
class IdleManagerLinuxNotAvailable implements IdleManagerLinux {
  @override
  Stream<IdleState> get userIdleState => const Stream.empty();

  @override
  Future<void> dispose() async {}
}

/// KDE implementation of [IdleManagerLinux].
class IdleManagerLinuxKDE implements IdleManagerLinux {
  final PostureParrotIdleDBus _idleDbusManager = PostureParrotIdleDBus();
  final KWin _kwin = KWin();

  /// The current idle state.
  IdleState _idleState = IdleState.active;

  /// The last time the user was active.
  DateTime _lastUserActivity = DateTime.now();

  /// Timer that checks for user activity.
  Timer? _activityCheckTimer;

  /// The name of the KWin script we load to get user activity on KDE.
  static const _kwinScriptName = 'postureParrotCompanion';

  @override
  Stream<IdleState> get userIdleState => _userIdleStateController.stream;

  final StreamController<IdleState> _userIdleStateController =
      StreamController<IdleState>.broadcast();

  IdleManagerLinuxKDE() {
    _initializeActivityCheck();
    _initializeDBusService();
    _listenToUserActivity();

    _listenToScriptOutput();

    _kwin.loadScript(
      '${Directory.current.path}/assets/scripts/kwin-script.js',
      _kwinScriptName,
    );
  }

  final DBusClient dbusClient = DBusClient.session();

  void _initializeActivityCheck() {
    _activityCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final currentTime = DateTime.now();
      final difference = currentTime.difference(_lastUserActivity).inMinutes;
      if (difference >= 5 && _idleState != IdleState.idle) {
        _idleState = IdleState.idle;
        _userIdleStateController.add(_idleState);
      }
    });
  }

  Future<void> _initializeDBusService() async {
    await dbusClient.requestName('codes.merritt.PostureParrot');
    await dbusClient.registerObject(_idleDbusManager);
  }

  void _listenToUserActivity() {
    // Assuming _idleDbusManager.userActivity is a Stream that notifies about user activity
    _idleDbusManager.userActivity.listen((_) {
      _lastUserActivity = DateTime.now();
      if (_idleState == IdleState.idle) {
        _idleState = IdleState.active;
        _userIdleStateController.add(_idleState);
      }
    });
  }

  void _listenToScriptOutput() {
    _kwin.scriptOutput.where((line) => line.contains('posture-parrot-companion')).listen((line) {
      log.d('KWin script output: $line');
    });
  }

  @override
  Future<void> dispose() async {
    await _idleDbusManager.dispose();
    await dbusClient.close();
    _activityCheckTimer?.cancel();
    _userIdleStateController.close();
    await _kwin.unloadScript(_kwinScriptName);
    await _kwin.dispose();
  }
}
