import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../break.dart';

/// The view that shows the active break.
class BreakView extends StatelessWidget {
  const BreakView({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    const Widget breakTimeText = Text(
      'Break Time',
      style: TextStyle(
        fontSize: 40,
        color: Colors.white,
      ),
    );

    final timerText = BlocBuilder<BreakCubit, BreakState>(
      builder: (context, state) {
        const timerTextStyle = TextStyle(
          fontSize: 40,
          color: Colors.white,
        );

        if (state.activeBreak == null) {
          // This should only happen during debugging, to check the design.
          return const Text(
            'No active break',
            style: timerTextStyle,
          );
        }

        return StreamBuilder<BreakTimerState>(
          stream: state.activeBreak!.timerState,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }

            final timerState = snapshot.data!;

            return Text(
              '${timerState.remainingBreakTime.inMinutes}:${(timerState.remainingBreakTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: timerTextStyle,
            );
          },
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: CircleAvatar(
            radius: 200,
            backgroundColor: Colors.blue,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  breakTimeText,
                  timerText,
                  const SizedBox(height: 16),
                  _BreakControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BreakControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreakCubit, BreakState>(
      builder: (context, state) {
        // SingleChildScrollView prevents overflow error when the screen is too small, and when
        // the app is first starting.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<BreakCubit>().postponeBreak();
                },
                child: const Text('Postpone'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<BreakCubit>().skipBreak();
                },
                child: const Text('Skip'),
              ),
            ],
          ),
        );
      },
    );
  }
}
