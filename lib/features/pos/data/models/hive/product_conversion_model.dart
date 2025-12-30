import 'package:hive/hive.dart';

part 'product_conversion_model.g.dart';

@HiveType(typeId: 6)
class ProductConversionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String unitName;

  @HiveField(3)
  final double conversionFactor;

  ProductConversionModel({
    required this.id,
    required this.productId,
    required this.unitName,
    required this.conversionFactor,
  });
}
