import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'window_state.dart';
part 'window_cubit.freezed.dart';

class WindowCubit extends Cubit<WindowState> {
  WindowCubit() : super(WindowState.initial());
}
