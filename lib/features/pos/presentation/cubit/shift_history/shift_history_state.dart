import 'package:equatable/equatable.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/shift_model.dart';

abstract class ShiftHistoryState extends Equatable {
  const ShiftHistoryState();

  @override
  List<Object> get props => [];
}

class ShiftHistoryInitial extends ShiftHistoryState {}

class ShiftHistoryLoading extends ShiftHistoryState {}

class ShiftHistoryLoaded extends ShiftHistoryState {
  final List<ShiftModel> shifts;

  const ShiftHistoryLoaded(this.shifts);

  @override
  List<Object> get props => [shifts];
}

class ShiftHistoryError extends ShiftHistoryState {
  final String message;

  const ShiftHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
