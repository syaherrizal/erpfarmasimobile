import 'package:erpfarmasimobile/features/pos/data/models/hive/shift_model.dart';

abstract class ShiftRepository {
  Future<ShiftModel?> getOpenShift(String branchId);
  Future<List<ShiftModel>> getShiftHistory(String branchId);
  Future<void> openShift(ShiftModel shift);
  Future<void> closeShift(String shiftId, double actualEndCash, String? note);
  Future<void> updateShift(ShiftModel shift);
  double calculateExpectedCash(
    ShiftModel shift,
    double transactionTotal,
    String paymentMethod,
  );
}
