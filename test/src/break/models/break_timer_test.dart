import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:posture_parrot/src/break/break.dart';
import 'package:posture_parrot/src/logs/logging_manager.dart';

@GenerateNiceMocks([
  MockSpec<Logger>(),
])
import 'break_timer_test.mocks.dart';

void main() {
  group('BreakTimer', () {
    late BreakTimer breakTimer;

    log = MockLogger();

    setUp(() {
      breakTimer = BreakTimer(
        breakDuration: const Duration(seconds: 30),
        breakInterval: const Duration(minutes: 2),
        onBreakFinished: (_) {},
        onIntervalFinished: (_) {},
      );
    });

    test('initial state', () {
      expect(breakTimer.breakDuration, const Duration(seconds: 30));
      expect(breakTimer.breakInterval, const Duration(minutes: 2));
      expect(breakTimer.timerState, isA<Stream<BreakTimerState>>());
    });

    test('reset restarts the timers', () {
      breakTimer.reset();
      expect(breakTimer.isPaused, isFalse);
      expect(breakTimer.breakRemaining, Duration.zero);
      expect(breakTimer.intervalRemaining, Duration.zero);
    });

    test('pause pauses the timers', () {
      breakTimer.pause();
      expect(breakTimer.isPaused, isTrue);
    });

    test('resume resumes the timers', () {
      breakTimer.pause();
      expect(breakTimer.isPaused, isTrue);
      breakTimer.resume();
      expect(breakTimer.isPaused, isFalse);
    });

    test('postpone postpones an active break by the given duration', () async {
      breakTimer = BreakTimer(
        breakDuration: const Duration(seconds: 10),
        breakInterval: const Duration(seconds: 3),
        onBreakFinished: (_) {},
        onIntervalFinished: (_) {},
      );

      expect(breakTimer.isPaused, isFalse);

      expect(
        breakTimer,
        isA<BreakTimer>()
            .having((timer) => timer.breakRemaining, 'pausedBreakRemaining', Duration.zero)
            .having((timer) => timer.intervalRemaining.inSeconds, 'pausedIntervalRemaining',
                inInclusiveRange(0, 3)),
      );

      await Future.delayed(const Duration(seconds: 3));

      expect(
        breakTimer,
        isA<BreakTimer>()
            .having((timer) => timer.breakRemaining.inSeconds, 'pausedBreakRemaining',
                inInclusiveRange(0, 10))
            .having(
                (timer) => timer.intervalRemaining.inSeconds.round(), 'pausedIntervalRemaining', 0),
      );

      breakTimer.postpone(const Duration(seconds: 5));

      await Future.delayed(const Duration(seconds: 1));

      expect(
        breakTimer,
        isA<BreakTimer>()
            .having(
                (timer) => timer.breakRemaining, 'pausedBreakRemaining', const Duration(seconds: 0))
            .having((timer) => timer.intervalRemaining.inSeconds.round(), 'pausedIntervalRemaining',
                inInclusiveRange(1, 4)),
      );

      await Future.delayed(const Duration(seconds: 7));

      expect(
        breakTimer,
        isA<BreakTimer>()
            .having((timer) => timer.breakRemaining.inSeconds, 'pausedBreakRemaining',
                inInclusiveRange(1, 10))
            .having(
                (timer) => timer.intervalRemaining.inSeconds.round(), 'pausedIntervalRemaining', 0),
      );
    });
  });
}
