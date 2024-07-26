import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../break/break.dart';
import '../../system_tray/system_tray_manager.dart';
import '../../window/window.dart';

part 'app_state.dart';
part 'app_cubit.freezed.dart';

/// Manages the app's state and lifecycle.
class AppCubit extends Cubit<AppState> {
  final AppWindow _appWindow;
  final BreakCubit _breakCubit;
  final SystemTrayManager _systemTrayManager;

  AppCubit({
    required AppWindow appWindow,
    required BreakCubit breakCubit,
    required SystemTrayManager systemTrayManager,
  })  : _appWindow = appWindow,
        _breakCubit = breakCubit,
        _systemTrayManager = systemTrayManager,
        super(const AppState.initial()) {
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
