import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/pos_product_repository.dart';
import '../models/hive/product_model.dart';

class PosProductRepositoryImpl implements PosProductRepository {
  final SupabaseClient _supabase;
  final Box<ProductModel> _productBox;

  PosProductRepositoryImpl(this._supabase, this._productBox);

  @override
  Future<Either<Failure, void>> syncProducts(
    String organizationId,
    String branchId,
  ) async {
    try {
      // Fetch from Supabase
      // Join inventory_items (stock & price) with products (name, sku, unit)
      final response = await _supabase
          .from('inventory_items')
          .select('''
        stock_on_hand,
        price_sell,
        product:products (
          id,
          name,
          sku,
          base_unit,
          barcode
        )
      ''')
          .eq('organization_id', organizationId)
          .eq('branch_id', branchId);

      // Check if response is empty
      if ((response as List).isEmpty) {
        return const Right(null);
      }

      final List<dynamic> data = response;
      final Map<String, ProductModel> newProducts = {};

      for (var item in data) {
        final productData = item['product'];
        if (productData != null) {
          final productModel = ProductModel(
            id: productData['id'],
            name: productData['name'],
            sku: productData['sku'],
            price: (item['price_sell'] as num).toDouble(),
            stock: (item['stock_on_hand'] as num).toInt(),
            unit: productData['base_unit'],
            barcode: productData['barcode'],
          );
          newProducts[productModel.id] = productModel;
        }
      }

      // Update Hive (Full replace or merge? Full replace for safe sync)
      await _productBox.clear();
      await _productBox.putAll(newProducts);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> getAllProducts() async {
    try {
      final products = _productBox.values.toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductModel>>> searchProducts(
    String query,
  ) async {
    try {
      if (query.isEmpty) {
        return getAllProducts();
      }
      final products = _productBox.values.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.sku.toLowerCase().contains(query.toLowerCase()) ||
            (p.barcode?.contains(query) ?? false);
      }).toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
