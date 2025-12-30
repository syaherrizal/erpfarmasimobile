import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class OwnerRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats(
    String organizationId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getRecentTransactions(
    String organizationId,
  );
}
