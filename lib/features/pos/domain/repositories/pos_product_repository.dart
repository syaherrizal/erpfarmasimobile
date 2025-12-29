import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/hive/product_model.dart'; // Domain should use entities, but using Hive model as entity for simplicity in offline-first

abstract class PosProductRepository {
  Future<Either<Failure, void>> syncProducts(
    String organizationId,
    String branchId,
  );
  Future<Either<Failure, List<ProductModel>>> searchProducts(String query);
  Future<Either<Failure, List<ProductModel>>> getAllProducts();
}
