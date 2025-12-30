import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/product_model.dart';
import 'package:erpfarmasimobile/features/pos/data/models/hive/transaction_model.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/pos_product_repository.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/pos_transaction_repository.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/inventory_repository.dart';

// Events
abstract class PosEvent extends Equatable {
  const PosEvent();
  @override
  List<Object> get props => [];
}

class PosInitialDataRequested extends PosEvent {
  const PosInitialDataRequested();
}

class PosSyncTransactionsRequested extends PosEvent {}

class PosTransactionSaved extends PosEvent {
  final TransactionModel transaction;
  const PosTransactionSaved(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class PosSearchRequested extends PosEvent {
  final String query;
  const PosSearchRequested(this.query);
  @override
  List<Object> get props => [query];
}

// States
abstract class PosState extends Equatable {
  const PosState();
  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {}

class PosLoading extends PosState {}

class PosLoaded extends PosState {
  final List<ProductModel> products;

  const PosLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class PosError extends PosState {
  final String message;
  const PosError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class PosBloc extends Bloc<PosEvent, PosState> {
  final PosProductRepository _productRepository;
  final PosTransactionRepository _transactionRepository;
  final InventoryRepository _inventoryRepository;

  PosBloc(
    this._productRepository,
    this._transactionRepository,
    this._inventoryRepository,
  ) : super(PosInitial()) {
    on<PosInitialDataRequested>(_onInitialDataRequested);
    on<PosSyncTransactionsRequested>(_onSyncTransactionsRequested);
    on<PosTransactionSaved>(_onTransactionSaved);
    on<PosSearchRequested>(_onSearchRequested);
  }

  /// Loads products directly from Local Hive storage.
  /// Remote sync is handled independently by ProductSyncCubit.
  Future<void> _onInitialDataRequested(
    PosInitialDataRequested event,
    Emitter<PosState> emit,
  ) async {
    emit(PosLoading());
    final localResult = await _productRepository.getAllProducts();

    localResult.fold(
      (failure) => emit(PosError(failure.message)),
      (products) => emit(PosLoaded(products: products)),
    );
  }

  Future<void> _onTransactionSaved(
    PosTransactionSaved event,
    Emitter<PosState> emit,
  ) async {
    // 1. Process Inventory Deductions (FEFO) locally
    for (final item in event.transaction.items) {
      final invResult = await _inventoryRepository.processSale(
        productId: item.productId,
        unitName: item.unitName ?? 'pcs',
        quantity: item.quantity.toDouble(),
        conversionFactor: 1.0, // TODO: Fetch from ProductConversionModel box
        transactionId: event.transaction.id,
        organizationId: event.transaction.organizationId,
        branchId: event.transaction.branchId,
      );

      invResult.fold((failure) {
        // Log failure but continue? Or fail the whole transaction?
        // Web rules usually imply UI should prevent selling more than stock
        // but if it happens, we might need a rollback logic.
        // For now, we emit error state to notify UI.
        emit(PosError("Inventory Error: ${failure.message}"));
      }, (_) => null);
    }

    // 2. Save Transaction to outbox
    await _transactionRepository.saveTransaction(event.transaction);

    // 3. Automatically trigger sync check for outbox
    add(PosSyncTransactionsRequested());

    // 4. Finalize: Optional UI feedback or refresh
    // We don't necessarily need to emit Loaded here unless products list changed significantly
    // But since stock changed, a refresh helps.
    add(const PosInitialDataRequested());
  }

  Future<void> _onSyncTransactionsRequested(
    PosSyncTransactionsRequested event,
    Emitter<PosState> emit,
  ) async {
    await _transactionRepository.syncPendingTransactions();
  }

  Future<void> _onSearchRequested(
    PosSearchRequested event,
    Emitter<PosState> emit,
  ) async {
    if (state is PosLoaded) {
      final result = await _productRepository.searchProducts(event.query);
      result.fold(
        (failure) => emit(PosError(failure.message)),
        (products) => emit(PosLoaded(products: products)),
      );
    }
  }
}
