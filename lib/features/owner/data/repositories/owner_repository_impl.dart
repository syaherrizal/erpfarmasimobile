import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import 'package:erpfarmasimobile/features/owner/domain/repositories/owner_repository.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  final SupabaseClient _supabase;

  OwnerRepositoryImpl(this._supabase);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats(
    String organizationId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).toIso8601String();

      // Simple implementation: count transactions and sum total_amount for today
      final response = await _supabase
          .from('transactions')
          .select('total_amount')
          .eq('organization_id', organizationId)
          .gte('created_at', startOfDay);

      double totalSales = 0;
      for (final row in response) {
        totalSales += (row['total_amount'] as num).toDouble();
      }

      return Right({
        'today_sales': totalSales,
        'today_transactions': response.length,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRecentTransactions(
    String organizationId,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('organization_id', organizationId)
          .order('created_at', ascending: false)
          .limit(10);

      return Right(List<Map<String, dynamic>>.from(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
