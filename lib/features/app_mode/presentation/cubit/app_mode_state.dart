part of 'app_mode_cubit.dart';

class AppModeState extends Equatable {
  final AppMode mode;

  const AppModeState(this.mode);

  @override
  List<Object> get props => [mode];
}
