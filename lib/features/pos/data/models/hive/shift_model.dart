import 'package:hive/hive.dart';

part 'shift_model.g.dart';

@HiveType(typeId: 10)
class ShiftModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cashierId;

  @HiveField(2)
  final String branchId;

  @HiveField(3)
  final DateTime openTime;

  @HiveField(4)
  DateTime? closeTime;

  @HiveField(5)
  final double startCash;

  @HiveField(6)
  double expectedEndCash;

  @HiveField(7)
  double? actualEndCash;

  @HiveField(8)
  String status; // 'open', 'closed'

  @HiveField(9)
  String? note;

  @HiveField(10)
  final String cashierName;

  ShiftModel({
    required this.id,
    required this.cashierId,
    required this.branchId,
    required this.openTime,
    this.closeTime,
    required this.startCash,
    required this.expectedEndCash,
    this.actualEndCash,
    this.status = 'open',
    this.note,
    required this.cashierName,
  });
}
