import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../app_mode.dart';

part 'app_mode_state.dart';

class AppModeCubit extends Cubit<AppModeState> {
  AppModeCubit() : super(const AppModeState(AppMode.pos));

  void setMode(AppMode mode) {
    emit(AppModeState(mode));
  }

  void toggleMode() {
    if (state.mode == AppMode.pos) {
      emit(const AppModeState(AppMode.owner));
    } else {
      emit(const AppModeState(AppMode.pos));
    }
  }
}
