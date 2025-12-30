part of 'shift_bloc.dart';

abstract class ShiftState extends Equatable {
  const ShiftState();

  @override
  List<Object> get props => [];
}

class ShiftInitial extends ShiftState {}

class ShiftLoading extends ShiftState {}

class ShiftOpened extends ShiftState {
  final ShiftModel shift;

  const ShiftOpened(this.shift);

  @override
  List<Object> get props => [shift];
}

class ShiftClosed extends ShiftState {}

class ShiftError extends ShiftState {
  final String message;

  const ShiftError(this.message);

  @override
  List<Object> get props => [message];
}
