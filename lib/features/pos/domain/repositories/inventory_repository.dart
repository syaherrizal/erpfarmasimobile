import 'package:fpdart/fpdart.dart';
import 'package:erpfarmasimobile/core/error/failures.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_batch_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_movement_model.dart';

abstract class InventoryRepository {
  /// Deducts stock from local batches using FEFO (First Expired, First Out).
  /// [quantity] must be in base units.
  Future<Either<Failure, List<InventoryMovementModel>>> processSale({
    required String productId,
    required String unitName,
    required double quantity, // Original sale quantity
    required double conversionFactor,
    required String transactionId,
    required String organizationId,
    required String branchId,
  });

  /// Clears local inventory data (for sync reconciliation).
  Future<void> clearAll();

  /// Updates local batches from server authoritative data.
  Future<void> reconcileBatches(List<InventoryBatchModel> batches);
}
