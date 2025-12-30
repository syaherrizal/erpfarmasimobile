import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/shift_model.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final Box<ShiftModel> _shiftBox;
  final SupabaseClient _supabase;

  ShiftRepositoryImpl(this._shiftBox, this._supabase);

  @override
  Future<ShiftModel?> getOpenShift(String branchId) async {
    try {
      return _shiftBox.values.firstWhere(
        (shift) => shift.branchId == branchId && shift.status == 'open',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ShiftModel>> getShiftHistory(String branchId) async {
    return _shiftBox.values
        .where((shift) => shift.branchId == branchId)
        .toList()
      ..sort((a, b) => b.openTime.compareTo(a.openTime));
  }

  @override
  Future<void> openShift(ShiftModel shift) async {
    // 1. Local Save
    await _shiftBox.put(shift.id, shift);

    // 2. Sync to Supabase (Best Effort)
    try {
      await _supabase.from('cash_shifts').insert({
        'id': shift.id,
        'branch_id': shift.branchId,
        'cashier_id': shift.cashierId,
        'start_cash': shift.startCash,
        'expected_end_cash': shift.expectedEndCash,
        'status': 'open',
        'opened_at': shift.openTime.toIso8601String(),
        'cashier_name':
            shift.cashierName, // Store JSON/Aux data if possible, or ignore
      });
    } catch (e) {
      // Offline or Error: Log it, but don't block
      print('Sync Error (Open Shift): $e');
    }
  }

  @override
  Future<void> closeShift(
    String shiftId,
    double actualEndCash,
    String? note,
  ) async {
    // 1. Local Save
    final shift = _shiftBox.get(shiftId);
    if (shift != null) {
      shift.actualEndCash = actualEndCash;
      shift.note = note;
      shift.status = 'closed';
      shift.closeTime = DateTime.now();
      await shift.save();

      // 2. Sync to Supabase (Best Effort)
      try {
        await _supabase
            .from('cash_shifts')
            .update({
              'actual_end_cash': actualEndCash,
              'note': note,
              'status': 'closed',
              'closed_at': shift.closeTime?.toIso8601String(),
              'expected_end_cash':
                  shift.expectedEndCash, // Update final expected amount
            })
            .eq('id', shiftId);
      } catch (e) {
        print('Sync Error (Close Shift): $e');
      }
    }
  }

  @override
  Future<void> updateShift(ShiftModel shift) async {
    await shift.save();
    // Use this for incremental updates if needed
  }

  @override
  double calculateExpectedCash(
    ShiftModel shift,
    double transactionTotal,
    String paymentMethod,
  ) {
    if (paymentMethod.toLowerCase() == 'tunai' ||
        paymentMethod.toLowerCase() == 'cash') {
      return shift.expectedEndCash + transactionTotal;
    }
    return shift.expectedEndCash;
  }
}
