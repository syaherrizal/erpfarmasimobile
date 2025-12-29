import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String sku;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stock;

  @HiveField(5)
  final String? unit;

  @HiveField(6)
  final String? barcode;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stock,
    this.unit,
    this.barcode,
  });
}
