part of 'break_cubit.dart';

@freezed
class BreakState with _$BreakState {
  const factory BreakState({
    required List<BreakTimer> breaks,
    BreakTimer? activeBreak,
  }) = _BreakState;

  factory BreakState.initial() {
    return const BreakState(
      breaks: [],
    );
  }
}
