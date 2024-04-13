import 'dart:async';

import 'package:quiver/async.dart';

class BreakTimer {
  final Duration breakDuration;
  final Duration breakInterval;

  void Function(BreakTimer timer) onBreakFinished;
  void Function(BreakTimer timer) onIntervalFinished;

  BreakTimer({
    required this.breakDuration,
    required this.breakInterval,
    required this.onBreakFinished,
    required this.onIntervalFinished,
  }) {
    _startIntervalTimer();
  }

  CountdownTimer _breakTimer = CountdownTimer(Duration.zero, Duration.zero);
  CountdownTimer _intervalTimer = CountdownTimer(Duration.zero, Duration.zero);

  final StreamController<BreakTimerState> _timerStateController = StreamController.broadcast();
  Stream<BreakTimerState> get timerState => _timerStateController.stream;

  /// Restarts the break timer.
  void reset() {
    _breakTimer.cancel();
    _intervalTimer.cancel();
    _startIntervalTimer();
  }

  void _startBreakTimer() {
    _breakTimer = CountdownTimer(breakDuration, const Duration(seconds: 1))
      ..listen((timer) {
        if (timer.finished) {
          onBreakFinished(this);
          _startIntervalTimer();
          return;
        }

        _timerStateController.add(BreakTimerState(
          isBreakActive: true,
          isIntervalActive: false,
          remainingTime: timer.remaining,
        ));
      });
  }

  void _startIntervalTimer() {
    _intervalTimer = CountdownTimer(breakInterval, const Duration(seconds: 1))
      ..listen((timer) {
        if (timer.finished) {
          onIntervalFinished(this);
          _startBreakTimer();
          return;
        }

        _timerStateController.add(BreakTimerState(
          isBreakActive: false,
          isIntervalActive: true,
          remainingTime: timer.remaining,
        ));
      });
  }

  void dispose() {
    _breakTimer.cancel();
    _intervalTimer.cancel();
    _timerStateController.close();
  }
}

class BreakTimerState {
  final bool isBreakActive;
  final bool isIntervalActive;
  final Duration remainingTime;

  BreakTimerState({
    required this.isBreakActive,
    required this.isIntervalActive,
    required this.remainingTime,
  });

  @override
  String toString() {
    return 'BreakTimerState(isBreakActive: $isBreakActive, isIntervalActive: $isIntervalActive, remainingTime: ${remainingTime.inSeconds})';
  }
}

extension on CountdownTimer {
  bool get finished => secondsRemaining == 0;

  /// https://github.com/google/quiver-dart/issues/495#issuecomment-482308497
  int get secondsRemaining => (remaining.inMilliseconds / 1000).round();
}
