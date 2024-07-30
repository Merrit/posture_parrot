import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quiver/async.dart';

part 'break_timer.freezed.dart';

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
  bool isPaused = false;
  Duration breakRemaining = Duration.zero;
  Duration intervalRemaining = Duration.zero;

  final StreamController<BreakTimerState> _timerStateController = StreamController.broadcast();
  Stream<BreakTimerState> get timerState => _timerStateController.stream;

  /// Restarts the break timer.
  void reset() {
    _breakTimer.cancel();
    _intervalTimer.cancel();
    isPaused = false;
    breakRemaining = Duration.zero;
    intervalRemaining = Duration.zero;
    _startIntervalTimer();
  }

  void pause() {
    if (isPaused) return;

    _breakTimer.cancel();
    _intervalTimer.cancel();
    isPaused = true;
    // Store remaining time for both timers
    breakRemaining = _breakTimer.remaining;
    intervalRemaining = _intervalTimer.remaining;
  }

  void postpone(Duration duration) {
    if (_breakTimer.remaining > Duration.zero) {
      // If the break timer is active, stop it and start an interval timer with the postponed time
      _breakTimer.cancel();
      _intervalTimer.cancel();
      breakRemaining = Duration.zero;
      _startIntervalTimer(duration);
    } else {
      // If the break timer is not active, add the postponed time to the interval timer
      // TODO: Verify this logic actually works to extend the interval timer. When we add a button
      // to postpone the upcoming break from the notifiation maybe?
      _intervalTimer.cancel();
      _startIntervalTimer(_intervalTimer.remaining + duration);
    }
  }

  void resume() {
    if (!isPaused) return;

    isPaused = false;
    // Resume with the remaining time
    if (breakRemaining > Duration.zero) {
      _startBreakTimer(breakRemaining);
    } else if (intervalRemaining > Duration.zero) {
      _startIntervalTimer(intervalRemaining);
    }
    breakRemaining = Duration.zero;
    intervalRemaining = Duration.zero;
  }

  void _startBreakTimer([Duration? remainingTime]) {
    _breakTimer = CountdownTimer(remainingTime ?? breakDuration, const Duration(seconds: 1))
      ..listen((timer) {
        breakRemaining = timer.remaining;

        if (timer.finished) {
          onBreakFinished(this);
          _startIntervalTimer();
          return;
        }

        _timerStateController.add(BreakTimerState(
          isBreakActive: true,
          isIntervalActive: false,
          remainingBreakTime: timer.remaining,
          remainingIntervalTime: _intervalTimer.remaining,
        ));
      });
  }

  void _startIntervalTimer([Duration? remainingTime]) {
    _intervalTimer.cancel();

    _intervalTimer = CountdownTimer(remainingTime ?? breakInterval, const Duration(seconds: 1))
      ..listen((timer) {
        intervalRemaining = timer.remaining;

        if (timer.finished) {
          onIntervalFinished(this);
          _startBreakTimer();
          return;
        }

        _timerStateController.add(BreakTimerState(
          isBreakActive: false,
          isIntervalActive: true,
          remainingBreakTime: _breakTimer.remaining,
          remainingIntervalTime: timer.remaining,
        ));
      });
  }

  void dispose() {
    _breakTimer.cancel();
    _intervalTimer.cancel();
    _timerStateController.close();
  }
}

@freezed
class BreakTimerState with _$BreakTimerState {
  const factory BreakTimerState({
    required bool isBreakActive,
    required bool isIntervalActive,
    required Duration remainingBreakTime,
    required Duration remainingIntervalTime,
  }) = _BreakTimerState;

  factory BreakTimerState.initial() {
    return const BreakTimerState(
      isBreakActive: false,
      isIntervalActive: false,
      remainingBreakTime: Duration.zero,
      remainingIntervalTime: Duration.zero,
    );
  }
}

extension on CountdownTimer {
  bool get finished => secondsRemaining == 0;

  /// https://github.com/google/quiver-dart/issues/495#issuecomment-482308497
  int get secondsRemaining => (remaining.inMilliseconds / 1000).round();
}
