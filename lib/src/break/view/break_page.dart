import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../break.dart';

/// Displays a list of SampleItems.
class BreakView extends StatelessWidget {
  const BreakView({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Break Time',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  BlocBuilder<BreakCubit, BreakState>(
                    builder: (context, state) {
                      if (state.activeBreak == null) {
                        return const SizedBox();
                      }

                      return StreamBuilder<BreakTimerState>(
                        stream: state.activeBreak!.timerState,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }

                          final timerState = snapshot.data!;

                          return Text(
                            '${timerState.remainingTime.inMinutes}:${(timerState.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
