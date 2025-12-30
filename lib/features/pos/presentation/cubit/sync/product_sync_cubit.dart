import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erpfarmasimobile/features/pos/domain/repositories/pos_product_repository.dart';

// State
abstract class ProductSyncState extends Equatable {
  const ProductSyncState();
  @override
  List<Object?> get props => [];
}

class ProductSyncInitial extends ProductSyncState {}

class ProductSyncLoading extends ProductSyncState {
  final String stage;
  final double progress;
  const ProductSyncLoading({this.stage = '', this.progress = 0.0});
  @override
  List<Object?> get props => [stage, progress];
}

class ProductSyncSuccess extends ProductSyncState {
  final DateTime lastSync;
  const ProductSyncSuccess(this.lastSync);
  @override
  List<Object?> get props => [lastSync];
}

class ProductSyncError extends ProductSyncState {
  final String message;
  const ProductSyncError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class ProductSyncCubit extends Cubit<ProductSyncState> {
  final PosProductRepository _repository;

  ProductSyncCubit(this._repository) : super(ProductSyncInitial());

  Future<void> sync(String organizationId, String branchId) async {
    emit(
      const ProductSyncLoading(stage: 'Menyinkronkan Produk...', progress: 0.1),
    );

    // 1. Sync Products
    final productResult = await _repository.syncProducts(
      organizationId,
      branchId,
    );
    if (productResult.isLeft()) {
      productResult.fold((f) => emit(ProductSyncError(f.message)), (_) => null);
      return;
    }

    emit(
      const ProductSyncLoading(stage: 'Menyinkronkan Stok...', progress: 0.4),
    );

    // 2. Sync Inventory Batches
    final batchResult = await _repository.syncInventoryBatches(
      organizationId,
      branchId,
    );
    if (batchResult.isLeft()) {
      batchResult.fold((f) => emit(ProductSyncError(f.message)), (_) => null);
      return;
    }

    emit(
      const ProductSyncLoading(
        stage: 'Menyinkronkan Konversi Satuan...',
        progress: 0.7,
      ),
    );

    // 3. Sync Product Conversions
    final conversionResult = await _repository.syncProductConversions(
      organizationId,
    );
    if (conversionResult.isLeft()) {
      conversionResult.fold(
        (f) => emit(ProductSyncError(f.message)),
        (_) => null,
      );
      return;
    }

    emit(ProductSyncSuccess(DateTime.now()));
  }
}
