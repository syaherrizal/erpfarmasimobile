import 'package:equatable/equatable.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/transaction_model.dart';

abstract class TransactionHistoryState extends Equatable {
  const TransactionHistoryState();

  @override
  List<Object> get props => [];
}

class TransactionHistoryInitial extends TransactionHistoryState {}

class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionModel> transactions;
  final double totalRevenueToday;
  final int successCount;
  final int voidCount;
  final int pendingSyncCount;

  const TransactionHistoryLoaded({
    required this.transactions,
    required this.totalRevenueToday,
    required this.successCount,
    required this.voidCount,
    required this.pendingSyncCount,
  });

  @override
  List<Object> get props => [
    transactions,
    totalRevenueToday,
    successCount,
    voidCount,
    pendingSyncCount,
  ];
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;

  const TransactionHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
