import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/transaction_model.dart';
import 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final Box<TransactionModel> _transactionBox;

  TransactionHistoryCubit(this._transactionBox)
    : super(TransactionHistoryInitial());

  void loadTransactions() {
    emit(TransactionHistoryLoading());
    try {
      final transactions = _transactionBox.values.toList()
        ..sort((a, b) => b.createdAtEpoch.compareTo(a.createdAtEpoch));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      double totalRevenueToday = 0;
      int successCount = 0;
      int voidCount = 0;
      int pendingSyncCount = 0;

      for (var tx in transactions) {
        final txDate = DateTime.fromMillisecondsSinceEpoch(tx.createdAtEpoch);
        final isToday =
            txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;

        if (tx.status != 'void') {
          if (isToday) {
            totalRevenueToday += tx.totalAmount;
            successCount++;
          }
        } else {
          if (isToday) voidCount++;
        }

        // Count totals for the day?
        // Wait, the image says "Transaksi Sukses: 1 Penjualan selesai HARI INI".
        // So counts are for TODAY.

        if (tx.status == 'pending') {
          pendingSyncCount++;
        }
      }

      // Recalculate counts based strictly on Image logic:
      // Omset Hari Ini: Revenue of VALID transactions TODAY.
      // Transaksi Sukses: Count of VALID transactions TODAY.
      // Void / Batal: Count of VOID transactions TODAY.
      // Pending Sync: Total Pending (All time? or Today? Usually All Time pending upload).

      // Resetting counters to be precise
      totalRevenueToday = 0;
      successCount = 0;
      voidCount = 0;
      pendingSyncCount = 0;

      for (var tx in transactions) {
        final txDate = DateTime.fromMillisecondsSinceEpoch(tx.createdAtEpoch);
        final isToday =
            txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;

        if (isToday) {
          if (tx.status != 'void') {
            totalRevenueToday += tx.totalAmount;
            successCount++;
          } else {
            voidCount++;
          }
        }

        if (tx.status == 'pending') {
          pendingSyncCount++;
        }
      }

      final todayTransactions = transactions.where((tx) {
        final txDate = DateTime.fromMillisecondsSinceEpoch(tx.createdAtEpoch);
        return txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
      }).toList();

      emit(
        TransactionHistoryLoaded(
          transactions: todayTransactions,
          totalRevenueToday: totalRevenueToday,
          successCount: successCount,
          voidCount: voidCount,
          pendingSyncCount: pendingSyncCount,
        ),
      );
    } catch (e) {
      emit(TransactionHistoryError('Failed to load transactions: $e'));
    }
  }
}
