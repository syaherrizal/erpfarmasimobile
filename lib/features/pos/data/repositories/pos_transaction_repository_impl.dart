import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/pos_transaction_repository.dart';
import '../models/hive/transaction_model.dart';

class PosTransactionRepositoryImpl implements PosTransactionRepository {
  final SupabaseClient _supabase;
  final Box<TransactionModel> _transactionBox;

  PosTransactionRepositoryImpl(this._supabase, this._transactionBox);

  @override
  Future<Either<Failure, void>> saveTransaction(
    TransactionModel transaction,
  ) async {
    try {
      await _transactionBox.add(transaction);
      // Trigger sync in background (fire and forget or wait)
      // For now, let's just save. Sync can be triggered by a worker or manual check.
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingTransactions() async {
    try {
      final pendingTransactions = _transactionBox.values
          .where((t) => t.status == 'pending')
          .toList();

      if (pendingTransactions.isEmpty) {
        return const Right(null);
      }

      for (var transaction in pendingTransactions) {
        // Prepare Supabase Payload
        // 1. Insert Transaction Header
        final headerResponse = await _supabase
            .from('transactions')
            .insert({
              'organization_id': 'ORG_ID_PLACEHOLDER', // TODO: Get from session
              'branch_id': 'BRANCH_ID_PLACEHOLDER', // TODO: Get from session
              'transaction_number':
                  'TRX-${transaction.id}', // Simple generation
              'total_amount': transaction.totalAmount,
              'created_at': DateTime.fromMillisecondsSinceEpoch(
                transaction.createdAtEpoch,
              ).toIso8601String(),
              'sync_status': 'synced',
              // Other required fields...
            })
            .select()
            .single();

        final transactionId = headerResponse['id'];

        // 2. Insert Transaction Items
        final itemsPayload = transaction.items
            .map(
              (item) => {
                'transaction_id': transactionId,
                'product_id': item.productId,
                'quantity': item.quantity,
                'price_at_sale': item.price,
              },
            )
            .toList();

        await _supabase.from('transaction_items').insert(itemsPayload);

        // 3. Mark as synced in Hive
        transaction.status = 'synced';
        await transaction.save();
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionModel>>>
  getRecentTransactions() async {
    try {
      final transactions = _transactionBox.values.toList();
      // Sort desc
      transactions.sort((a, b) => b.createdAtEpoch.compareTo(a.createdAtEpoch));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
