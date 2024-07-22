import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../do_not_disturb/dnd_service.dart';
import '../../idle/idle_manager.dart';
import '../../logs/logging_manager.dart';
import '../../notifications/notifications.dart';
import '../../system_tray/system_tray_manager.dart';
import '../../window/window.dart';
import '../break.dart';

part 'break_state.dart';
part 'break_cubit.freezed.dart';

class BreakCubit extends Cubit<BreakState> {
  final AppWindow appWindow;
  final DndService dndService;
  final IdleManager idleManager;
  final NotificationService notificationService;
  final SystemTrayManager systemTrayManager;

  BreakCubit({
    required this.appWindow,
    required this.dndService,
    required this.idleManager,
    required this.notificationService,
    required this.systemTrayManager,
  }) : super(BreakState.initial()) {
    final breakTimer = BreakTimer(
      breakDuration: const Duration(seconds: 30),
      breakInterval: const Duration(minutes: 20),
      onBreakFinished: (BreakTimer timer) {
        stopBreak();
      },
      onIntervalFinished: (BreakTimer timer) {
        startBreak(timer);
      },
    );

    addBreak(breakTimer);

    idleManager.userIdleState.listen(_onUserStateChanged);
  }

  IdleState _idleState = IdleState.active;

  void addBreak(BreakTimer breakTimer) {
    final breaks = [...state.breaks];
    breaks.add(breakTimer);
    emit(BreakState(breaks: breaks));
    _listenToBreakTimer(breakTimer);
  }

  void _listenToBreakTimer(BreakTimer breakTimer) {
    breakTimer.timerState.listen((timerState) async {
      if (!timerState.isIntervalActive) return;

      systemTrayManager.updateTimeRemaining(timerState.remainingTime);

      if (timerState.remainingTime.inSeconds != 10) return;

      final dndEnabled = await dndService.isDndEnabled();

      if (dndEnabled) {
        log.t('Do Not Disturb is enabled. Skipping break.');
        breakTimer.reset();
        return;
      }

      notificationService.showNotification(
        id: breakTimer.hashCode,
        title: 'Break starting soon',
        body: 'Your break will start in 10 seconds',
      );
    });
  }

  void _onUserStateChanged(IdleState idleState) {
    if (_idleState == idleState) return;

    _idleState = idleState;

    if (idleState == IdleState.active) {
      log.i('User is active. Resuming breaks');
      for (var breakTimer in state.breaks) {
        breakTimer.reset();
      }
    } else {
      log.i('User is idle. Pausing breaks');
      for (var breakTimer in state.breaks) {
        breakTimer.pause();
        // TODO: Update the system tray to show that breaks have been paused.
      }
    }
  }

  void removeBreak(BreakTimer breakTimer) {
    final breaks = [...state.breaks];
    breaks.remove(breakTimer);
    emit(BreakState(breaks: breaks));
  }

  Future<void> startBreak(BreakTimer breakTimer) async {
    log.t('starting break for ${breakTimer.breakDuration.inSeconds} seconds');
    await appWindow.show();
    await appWindow.focus();
    emit(state.copyWith(activeBreak: breakTimer));
  }

  Future<void> stopBreak() async {
    log.t(
        'stopping break. starting interval for ${state.activeBreak!.breakInterval.inSeconds} seconds');
    await appWindow.hide();
    emit(state.copyWith(activeBreak: null));
  }

  @override
  Future<void> close() async {
    await idleManager.dispose();
    return super.close();
  }
}
