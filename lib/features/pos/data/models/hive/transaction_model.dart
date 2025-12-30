import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionItemModel extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? unitName;

  TransactionItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.unitName,
  });

  double get total => price * quantity;
}

@HiveType(typeId: 3)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int createdAtEpoch; // Store as int for easier Hive handling

  @HiveField(2)
  final double totalAmount;

  @HiveField(3)
  final List<TransactionItemModel> items;

  @HiveField(4)
  String status; // 'pending', 'synced'

  @HiveField(5)
  final String organizationId;

  @HiveField(6)
  final String branchId;

  @HiveField(7)
  final String cashierId;

  @HiveField(8)
  final String paymentMethod;

  @HiveField(9)
  final String shiftId;

  TransactionModel({
    required this.id,
    required this.createdAtEpoch,
    required this.totalAmount,
    required this.items,
    this.status = 'pending',
    required this.organizationId,
    required this.branchId,
    required this.cashierId,
    required this.paymentMethod,
    required this.shiftId,
  });
}
