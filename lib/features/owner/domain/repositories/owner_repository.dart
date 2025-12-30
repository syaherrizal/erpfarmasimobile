import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class OwnerRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats(
    String organizationId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getRecentTransactions(
    String organizationId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getOrganization(
    String organizationId,
  );
  Future<Either<Failure, void>> updateOrganization(
    String organizationId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getBranches(
    String organizationId,
  );
  Future<Either<Failure, void>> addBranch(Map<String, dynamic> data);
  Future<Either<Failure, void>> updateBranch(
    String branchId,
    Map<String, dynamic> data,
  );
}
