import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../owner/domain/repositories/owner_repository.dart';
import 'owner_branch_state.dart';

class OwnerBranchCubit extends Cubit<OwnerBranchState> {
  final OwnerRepository _repository;

  OwnerBranchCubit(this._repository) : super(OwnerBranchInitial());

  Future<void> loadBranches(String organizationId) async {
    emit(OwnerBranchLoading());
    final result = await _repository.getBranches(organizationId);
    result.fold(
      (failure) => emit(OwnerBranchError(failure.message)),
      (data) => emit(OwnerBranchLoaded(data)),
    );
  }

  Future<void> addBranch(
    String organizationId,
    Map<String, dynamic> data,
  ) async {
    emit(OwnerBranchLoading()); // Or dedicated submitting state
    // Ensure orgId is set
    final newData = Map<String, dynamic>.from(data);
    newData['organization_id'] = organizationId;

    final result = await _repository.addBranch(newData);
    result.fold((failure) => emit(OwnerBranchError(failure.message)), (_) {
      emit(const OwnerBranchSuccess('Cabang berhasil ditambahkan'));
      loadBranches(organizationId);
    });
  }

  Future<void> updateBranch(
    String organizationId,
    String branchId,
    Map<String, dynamic> data,
  ) async {
    emit(OwnerBranchLoading());
    final result = await _repository.updateBranch(branchId, data);
    result.fold((failure) => emit(OwnerBranchError(failure.message)), (_) {
      emit(const OwnerBranchSuccess('Cabang berhasil diperbarui'));
      loadBranches(organizationId);
    });
  }
}
