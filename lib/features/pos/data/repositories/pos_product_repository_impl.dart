import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/pos_product_repository.dart';
import '../models/hive/product_model.dart';
import '../models/hive/inventory_batch_model.dart';
import '../models/hive/product_conversion_model.dart';

class PosProductRepositoryImpl implements PosProductRepository {
  final SupabaseClient _supabase;
  final Box<ProductModel> _productBox;
  final Box<InventoryBatchModel> _batchBox;
  final Box<ProductConversionModel> _conversionBox;

  PosProductRepositoryImpl(
    this._supabase,
    this._productBox,
    this._batchBox,
    this._conversionBox,
  );

  @override
  Future<Either<Failure, void>> syncProducts(
    String organizationId,
    String branchId,
  ) async {
    try {
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

  @override
  Future<Either<Failure, void>> syncInventoryBatches(
    String organizationId,
    String branchId,
  ) async {
    try {
      final response = await _supabase
          .from('inventory_batches')
          .select()
          .eq('organization_id', organizationId)
          .eq('branch_id', branchId)
          .gt('quantity_real', 0);

      final List<dynamic> data = response;
      final Map<String, InventoryBatchModel> newBatches = {};

      for (var item in data) {
        final batch = InventoryBatchModel(
          id: item['id'],
          productId: item['product_id'],
          batchNumber: item['batch_number'],
          expiredDate: DateTime.parse(item['expired_date']),
          quantityReal: (item['quantity_real'] as num).toInt(),
          priceBuy: (item['price_buy'] as num).toDouble(),
          organizationId: organizationId,
          branchId: branchId,
        );
        newBatches[batch.id] = batch;
      }

      await _batchBox.clear();
      await _batchBox.putAll(newBatches);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncProductConversions(
    String organizationId,
  ) async {
    try {
      final response = await _supabase
          .from('product_conversions')
          .select()
          .eq('organization_id', organizationId);

      final List<dynamic> data = response;
      final Map<String, ProductConversionModel> newConversions = {};

      for (var item in data) {
        final conversion = ProductConversionModel(
          id: item['id'],
          productId: item['product_id'],
          unitName: item['unit_name'],
          conversionFactor: (item['conversion_factor'] as num).toDouble(),
        );
        newConversions[conversion.id] = conversion;
      }

      await _conversionBox.clear();
      await _conversionBox.putAll(newConversions);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
