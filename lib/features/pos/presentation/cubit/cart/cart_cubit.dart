import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/product_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/cart_item_model.dart';

// State
class CartState extends Equatable {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [items];
}

// Cubit
class CartCubit extends Cubit<CartState> {
  final Box<CartItemModel> _cartBox;

  CartCubit(this._cartBox) : super(CartState(items: _cartBox.values.toList()));

  Future<void> addToCart(ProductModel product) async {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      final updatedItem = CartItemModel(
        product: items[index].product,
        quantity: items[index].quantity + 1,
      );
      items[index] = updatedItem;
    } else {
      items.add(CartItemModel(product: product, quantity: 1));
    }

    await _persistCart(items);
    emit(CartState(items: items));
  }

  Future<void> removeFromCart(String productId) async {
    final items = List<CartItemModel>.from(state.items);
    items.removeWhere((item) => item.product.id == productId);
    await _persistCart(items);
    emit(CartState(items: items));
  }

  Future<void> updateQuantity(String productId, int delta) async {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      final newQuantity = items[index].quantity + delta;
      if (newQuantity > 0) {
        items[index] = CartItemModel(
          product: items[index].product,
          quantity: newQuantity,
        );
      } else {
        items.removeAt(index);
      }
      await _persistCart(items);
      emit(CartState(items: items));
    }
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
    emit(const CartState());
  }

  Future<void> _persistCart(List<CartItemModel> items) async {
    await _cartBox.clear();
    // We use addAll for simplicity to keep the order from the list
    await _cartBox.addAll(items);
  }
}
