part of 'shift_bloc.dart';

abstract class ShiftEvent extends Equatable {
  const ShiftEvent();

  @override
  List<Object> get props => [];
}

class CheckShiftStatus extends ShiftEvent {
  final String branchId;
  const CheckShiftStatus(this.branchId);

  @override
  List<Object> get props => [branchId];
}

class OpenShift extends ShiftEvent {
  final String branchId;
  final String cashierId;
  final String cashierName;
  final double startCash;

  const OpenShift({
    required this.branchId,
    required this.cashierId,
    required this.cashierName,
    required this.startCash,
  });

  @override
  List<Object> get props => [branchId, cashierId, cashierName, startCash];
}

class CloseShift extends ShiftEvent {
  final String shiftId;
  final double actualEndCash;
  final String? note;

  const CloseShift({
    required this.shiftId,
    required this.actualEndCash,
    this.note,
  });

  @override
  List<Object> get props => [shiftId, actualEndCash, note ?? ''];
}

class UpdateShiftStats extends ShiftEvent {}
