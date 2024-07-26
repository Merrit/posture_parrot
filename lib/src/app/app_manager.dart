import '../break/break.dart';
import '../system_tray/system_tray_manager.dart';
import '../window/window.dart';

/// Manages the app's state and lifecycle.
class AppManager {
  final AppWindow _appWindow;
  final BreakCubit _breakCubit;
  final SystemTrayManager _systemTrayManager;

  AppManager({
    required AppWindow appWindow,
    required BreakCubit breakCubit,
    required SystemTrayManager systemTrayManager,
  })  : _appWindow = appWindow,
        _breakCubit = breakCubit,
        _systemTrayManager = systemTrayManager {
    _appWindow.events.listen(_onWindowEvent);
    _systemTrayManager.events.listen(_onTrayEvent);
  }

  Future<void> _close() async {
    await _appWindow.hide();
    await _breakCubit.close();
    _appWindow.close();
  }

  Future<void> _onTrayEvent(TrayEvent event) async {
    switch (event) {
      case TrayEvent.exitApp:
        await _close();
      case TrayEvent.toggleVisibility:
        await _appWindow.toggleVisible();
    }
  }

  Future<void> _onWindowEvent(WindowEvent event) async {
    if (event == WindowEvent.close) {
      await _close();
    }
  }
}
