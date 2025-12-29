import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/hive/transaction_model.dart';

abstract class PosTransactionRepository {
  Future<Either<Failure, void>> saveTransaction(TransactionModel transaction);
  Future<Either<Failure, void>> syncPendingTransactions();
  Future<Either<Failure, List<TransactionModel>>> getRecentTransactions();
}
