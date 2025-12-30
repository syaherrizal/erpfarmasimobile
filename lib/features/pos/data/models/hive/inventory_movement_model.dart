import 'package:hive/hive.dart';

part 'inventory_movement_model.g.dart';

@HiveType(typeId: 5)
class InventoryMovementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String? batchId;

  @HiveField(3)
  final int quantityChange;

  @HiveField(4)
  final String movementType; // 'sale', 'adjustment', 'void', 'transfer'

  @HiveField(5)
  final int balanceAfter;

  @HiveField(6)
  final String? referenceId;

  @HiveField(7)
  final String organizationId;

  @HiveField(8)
  final String branchId;

  @HiveField(9)
  final DateTime createdAt;

  InventoryMovementModel({
    required this.id,
    required this.productId,
    this.batchId,
    required this.quantityChange,
    required this.movementType,
    required this.balanceAfter,
    this.referenceId,
    required this.organizationId,
    required this.branchId,
    required this.createdAt,
  });
}
