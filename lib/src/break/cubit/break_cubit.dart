import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../do_not_disturb/dnd_service.dart';
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
  final NotificationService notificationService;
  final SystemTrayManager systemTrayManager;

  BreakCubit({
    required this.appWindow,
    required this.dndService,
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
  }

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
}
