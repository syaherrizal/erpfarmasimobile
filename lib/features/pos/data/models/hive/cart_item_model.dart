import 'package:hive/hive.dart';
import 'product_model.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 2)
class CartItemModel extends HiveObject {
  @HiveField(0)
  final ProductModel product;

  @HiveField(1)
  final int quantity;

  CartItemModel({required this.product, required this.quantity});

  double get total => product.price * quantity;
}
