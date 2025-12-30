import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/hive/product_model.dart';

// Model for cart item
class CartItem extends Equatable {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

// State
class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

// Cubit
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addToCart(ProductModel product) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }

    emit(CartState(items: items));
  }

  void removeFromCart(String productId) {
    final items = List<CartItem>.from(state.items);
    items.removeWhere((item) => item.product.id == productId);
    emit(CartState(items: items));
  }

  void updateQuantity(String productId, int delta) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final newQuantity = items[index].quantity + delta;
      if (newQuantity > 0) {
        items[index] = items[index].copyWith(quantity: newQuantity);
      } else {
        items.removeAt(index);
      }
      emit(CartState(items: items));
    }
  }

  void clearCart() {
    emit(const CartState());
  }
}
