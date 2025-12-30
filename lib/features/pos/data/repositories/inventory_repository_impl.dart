import 'package:fpdart/fpdart.dart';
import 'package:erpfarmasimobile/core/error/failures.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_batch_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/inventory_movement_model.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/inventory_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final Box<InventoryBatchModel> _batchBox;
  final Box<InventoryMovementModel> _movementBox;

  InventoryRepositoryImpl(this._batchBox, this._movementBox);

  @override
  Future<Either<Failure, List<InventoryMovementModel>>> processSale({
    required String productId,
    required String unitName,
    required double quantity,
    required double conversionFactor,
    required String transactionId,
    required String organizationId,
    required String branchId,
  }) async {
    try {
      // 1. Convert to base unit quantity
      final double baseUnitQtyDouble = quantity * conversionFactor;
      int baseUnitQty = baseUnitQtyDouble
          .ceil(); // Inventory uses integers for base units

      // 2. Get batches for this product, sorted by expired_date (FEFO)
      final allBatches =
          _batchBox.values
              .where(
                (b) =>
                    b.productId == productId &&
                    b.organizationId == organizationId &&
                    b.branchId == branchId &&
                    b.quantityReal > 0,
              )
              .toList()
            ..sort((a, b) => a.expiredDate.compareTo(b.expiredDate));

      if (allBatches.isEmpty && baseUnitQty > 0) {
        return Left(CacheFailure('Stok tidak tersedia untuk produk ini'));
      }

      final List<InventoryMovementModel> movements = [];
      int remainingToDeduct = baseUnitQty;

      // 3. Loop through batches to deduct quantity
      for (var batch in allBatches) {
        if (remainingToDeduct <= 0) break;

        final int deductFromThisBatch = remainingToDeduct > batch.quantityReal
            ? batch.quantityReal
            : remainingToDeduct;

        final int balanceAfter = batch.quantityReal - deductFromThisBatch;

        // Update batch
        await _batchBox.put(
          batch.id,
          batch.copyWith(quantityReal: balanceAfter),
        );

        // Record movement
        final movement = InventoryMovementModel(
          id: const Uuid().v4(),
          productId: productId,
          batchId: batch.id,
          quantityChange: -deductFromThisBatch,
          movementType: 'sale',
          balanceAfter: balanceAfter,
          referenceId: transactionId,
          organizationId: organizationId,
          branchId: branchId,
          createdAt: DateTime.now(),
        );

        await _movementBox.add(movement);
        movements.add(movement);

        remainingToDeduct -= deductFromThisBatch;
      }

      if (remainingToDeduct > 0) {
        return Left(
          CacheFailure('Stok tidak mencukupi (Kurang $remainingToDeduct unit)'),
        );
      }

      return Right(movements);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<void> clearAll() async {
    await _batchBox.clear();
    await _movementBox.clear();
  }

  @override
  Future<void> reconcileBatches(List<InventoryBatchModel> batches) async {
    await _batchBox.clear();
    final Map<String, InventoryBatchModel> batchMap = {
      for (var b in batches) b.id: b,
    };
    await _batchBox.putAll(batchMap);
  }
}
