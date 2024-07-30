import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:posture_parrot/src/break/break.dart';
import 'package:posture_parrot/src/do_not_disturb/dnd_service.dart';
import 'package:posture_parrot/src/idle/idle_manager.dart';
import 'package:posture_parrot/src/logs/logging_manager.dart';
import 'package:posture_parrot/src/notifications/notifications.dart';
import 'package:posture_parrot/src/system_tray/system_tray_manager.dart';
import 'package:posture_parrot/src/window/window.dart';

@GenerateNiceMocks([
  MockSpec<AppWindow>(),
  MockSpec<DndService>(),
  MockSpec<IdleManager>(),
  MockSpec<NotificationService>(),
  MockSpec<SystemTrayManager>(),
  MockSpec<BreakTimer>(),
  MockSpec<Logger>(),
])
import 'break_cubit_test.mocks.dart';

void main() {
  late BreakCubit breakCubit;
  late MockAppWindow mockAppWindow;
  late MockDndService mockDndService;
  late MockIdleManager mockIdleManager;
  late MockNotificationService mockNotificationService;
  late MockSystemTrayManager mockSystemTrayManager;

  log = MockLogger();

  setUp(() {
    mockAppWindow = MockAppWindow();
    mockDndService = MockDndService();
    mockIdleManager = MockIdleManager();
    mockNotificationService = MockNotificationService();
    mockSystemTrayManager = MockSystemTrayManager();

    breakCubit = BreakCubit(
      appWindow: mockAppWindow,
      dndService: mockDndService,
      idleManager: mockIdleManager,
      notificationService: mockNotificationService,
      systemTrayManager: mockSystemTrayManager,
    );
  });

  test('initial state is BreakState.initial()', () {
    // TODO: Implement this test properly once the break isn't hard-coded in the BreakCubit
    // constructor anymore.
    final breaks = breakCubit.state.breaks;
    expect(breaks.length, 1);
    expect(breaks.first.breakDuration, const Duration(seconds: 30));
    expect(breaks.first.breakInterval, const Duration(minutes: 20));
    expect(breakCubit.state.activeBreak, isNull);
  });

  blocTest<BreakCubit, BreakState>(
    'addBreak adds a break to the state',
    build: () => breakCubit,
    act: (cubit) {
      final breakTimer = MockBreakTimer();
      cubit.addBreak(breakTimer);
    },
    expect: () => [
      isA<BreakState>().having((state) => state.breaks.length, 'breaks length', 2),
    ],
  );

  blocTest<BreakCubit, BreakState>(
    'removeBreak removes a break from the state',
    build: () => breakCubit,
    seed: () {
      final breakTimer = MockBreakTimer();
      return BreakState(breaks: [breakTimer]);
    },
    act: (cubit) {
      final breakTimer = cubit.state.breaks.first;
      cubit.removeBreak(breakTimer);
    },
    expect: () => [
      isA<BreakState>().having((state) => state.breaks.length, 'breaks length', 0),
    ],
  );

  blocTest<BreakCubit, BreakState>(
    'startBreak starts a break',
    build: () => breakCubit,
    act: (cubit) async {
      final breakTimer = BreakTimer(
        breakDuration: const Duration(seconds: 30),
        breakInterval: const Duration(minutes: 2),
        onBreakFinished: (_) {},
        onIntervalFinished: (_) {},
      );
      await cubit.startBreak(breakTimer);
    },
    verify: (cubit) {
      verify(mockAppWindow.show()).called(1);
      verify(mockAppWindow.focus()).called(1);
    },
  );

  blocTest<BreakCubit, BreakState>(
    'stopBreak stops a break',
    build: () => breakCubit,
    seed: () {
      final breakTimer = BreakTimer(
        breakDuration: const Duration(seconds: 30),
        breakInterval: const Duration(minutes: 2),
        onBreakFinished: (_) {},
        onIntervalFinished: (_) {},
      );
      return BreakState(breaks: [breakTimer], activeBreak: breakTimer);
    },
    act: (cubit) async => await cubit.stopBreak(),
    verify: (cubit) {
      verify(mockAppWindow.hide()).called(1);
    },
  );

  test('close disposes resources', () async {
    await breakCubit.close();
    verify(mockIdleManager.dispose()).called(1);
  });
}
