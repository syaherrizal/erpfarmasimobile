import 'package:bloc/bloc.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/shift_repository.dart';
import 'shift_history_state.dart';

class ShiftHistoryCubit extends Cubit<ShiftHistoryState> {
  final ShiftRepository _shiftRepository;

  ShiftHistoryCubit(this._shiftRepository) : super(ShiftHistoryInitial());

  Future<void> fetchHistory(String branchId) async {
    emit(ShiftHistoryLoading());
    try {
      final shifts = await _shiftRepository.getShiftHistory(branchId);
      emit(ShiftHistoryLoaded(shifts));
    } catch (e) {
      emit(ShiftHistoryError(e.toString()));
    }
  }
}
