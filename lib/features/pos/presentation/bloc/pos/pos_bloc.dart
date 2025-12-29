import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/hive/product_model.dart';
import '../../../domain/repositories/pos_product_repository.dart';
import '../../../domain/repositories/pos_transaction_repository.dart';

// Events
abstract class PosEvent extends Equatable {
  const PosEvent();
  @override
  List<Object> get props => [];
}

class PosInitialDataRequested extends PosEvent {
  final String organizationId;
  final String branchId;
  const PosInitialDataRequested(this.organizationId, this.branchId);
}

class PosRefreshProductsRequested extends PosEvent {
  final String organizationId;
  final String branchId;
  const PosRefreshProductsRequested(this.organizationId, this.branchId);
}

class PosSyncTransactionsRequested extends PosEvent {}

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
  final String syncStatus; // 'synced', 'syncing', 'error'

  const PosLoaded({required this.products, this.syncStatus = 'synced'});

  PosLoaded copyWith({List<ProductModel>? products, String? syncStatus}) {
    return PosLoaded(
      products: products ?? this.products,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [products, syncStatus];
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

  PosBloc(this._productRepository, this._transactionRepository)
    : super(PosInitial()) {
    on<PosInitialDataRequested>(_onInitialDataRequested);
    on<PosRefreshProductsRequested>(_onRefreshProductsRequested);
    on<PosSyncTransactionsRequested>(_onSyncTransactionsRequested);
  }

  Future<void> _onInitialDataRequested(
    PosInitialDataRequested event,
    Emitter<PosState> emit,
  ) async {
    emit(PosLoading());
    // Load local products first
    final localResult = await _productRepository.getAllProducts();

    // Trigger background sync
    add(PosRefreshProductsRequested(event.organizationId, event.branchId));
    add(PosSyncTransactionsRequested());

    localResult.fold(
      (failure) => emit(PosError(failure.message)),
      (products) => emit(PosLoaded(products: products)),
    );
  }

  Future<void> _onRefreshProductsRequested(
    PosRefreshProductsRequested event,
    Emitter<PosState> emit,
  ) async {
    if (state is PosLoaded) {
      emit((state as PosLoaded).copyWith(syncStatus: 'syncing'));
    }

    // Sync from remote
    final syncResult = await _productRepository.syncProducts(
      event.organizationId,
      event.branchId,
    );

    // optimized: if sync success, reload local
    await syncResult.fold(
      (failure) async {
        if (state is PosLoaded) {
          emit((state as PosLoaded).copyWith(syncStatus: 'error'));
        }
      },
      (_) async {
        final newLocal = await _productRepository.getAllProducts();
        newLocal.fold((f) {}, (products) {
          emit(PosLoaded(products: products, syncStatus: 'synced'));
        });
      },
    );
  }

  Future<void> _onSyncTransactionsRequested(
    PosSyncTransactionsRequested event,
    Emitter<PosState> emit,
  ) async {
    await _transactionRepository.syncPendingTransactions();
  }
}
