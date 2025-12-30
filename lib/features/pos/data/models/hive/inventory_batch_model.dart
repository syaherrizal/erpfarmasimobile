import 'package:hive/hive.dart';

part 'inventory_batch_model.g.dart';

@HiveType(typeId: 4)
class InventoryBatchModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String batchNumber;

  @HiveField(3)
  final DateTime expiredDate;

  @HiveField(4)
  final int quantityReal;

  @HiveField(5)
  final double priceBuy;

  @HiveField(6)
  final String organizationId;

  @HiveField(7)
  final String branchId;

  InventoryBatchModel({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.expiredDate,
    required this.quantityReal,
    required this.priceBuy,
    required this.organizationId,
    required this.branchId,
  });

  InventoryBatchModel copyWith({int? quantityReal}) {
    return InventoryBatchModel(
      id: id,
      productId: productId,
      batchNumber: batchNumber,
      expiredDate: expiredDate,
      quantityReal: quantityReal ?? this.quantityReal,
      priceBuy: priceBuy,
      organizationId: organizationId,
      branchId: branchId,
    );
  }
}
