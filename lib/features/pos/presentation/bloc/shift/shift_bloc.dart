import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/shift_model.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/shift_repository.dart';
import 'package:uuid/uuid.dart';

part 'shift_event.dart';
part 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final ShiftRepository _shiftRepository;

  ShiftBloc(this._shiftRepository) : super(ShiftInitial()) {
    on<CheckShiftStatus>(_onCheckShiftStatus);
    on<OpenShift>(_onOpenShift);
    on<CloseShift>(_onCloseShift);
    on<UpdateShiftStats>(_onUpdateShiftStats);
  }

  Future<void> _onCheckShiftStatus(
    CheckShiftStatus event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());
    try {
      final openShift = await _shiftRepository.getOpenShift(event.branchId);
      if (openShift != null) {
        emit(ShiftOpened(openShift));
      } else {
        emit(ShiftClosed());
      }
    } catch (e) {
      emit(ShiftError(e.toString()));
    }
  }

  Future<void> _onOpenShift(OpenShift event, Emitter<ShiftState> emit) async {
    emit(ShiftLoading());
    try {
      final newShift = ShiftModel(
        id: const Uuid().v4(),
        cashierId: event.cashierId,
        branchId: event.branchId,
        openTime: DateTime.now(),
        startCash: event.startCash,
        expectedEndCash: event.startCash,
        cashierName: event.cashierName,
        status: 'open',
      );
      await _shiftRepository.openShift(newShift);
      emit(ShiftOpened(newShift));
    } catch (e) {
      emit(ShiftError(e.toString()));
    }
  }

  Future<void> _onCloseShift(CloseShift event, Emitter<ShiftState> emit) async {
    try {
      await _shiftRepository.closeShift(
        event.shiftId,
        event.actualEndCash,
        event.note,
      );
      emit(ShiftClosed());
    } catch (e) {
      emit(ShiftError(e.toString()));
    }
  }

  Future<void> _onUpdateShiftStats(
    UpdateShiftStats event,
    Emitter<ShiftState> emit,
  ) async {
    if (state is ShiftOpened) {
      final currentShift = (state as ShiftOpened).shift;
      // We assume the caller (e.g. TransactionBloc) tells us the transaction amount
      // or we just reload the shift if it was updated in repo

      // For now, let's reload
      final updatedShift = await _shiftRepository.getOpenShift(
        currentShift.branchId,
      );
      if (updatedShift != null) {
        emit(ShiftOpened(updatedShift));
      }
    }
  }
}
