import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../owner/domain/repositories/owner_repository.dart';
import 'owner_organization_state.dart';

class OwnerOrganizationCubit extends Cubit<OwnerOrganizationState> {
  final OwnerRepository _repository;

  OwnerOrganizationCubit(this._repository) : super(OwnerOrganizationInitial());

  Future<void> loadOrganization(String organizationId) async {
    emit(OwnerOrganizationLoading());
    final result = await _repository.getOrganization(organizationId);
    result.fold(
      (failure) => emit(OwnerOrganizationError(failure.message)),
      (data) => emit(OwnerOrganizationLoaded(data)),
    );
  }

  Future<void> updateOrganization(
    String organizationId,
    Map<String, dynamic> data,
  ) async {
    emit(OwnerOrganizationUpdating());
    final result = await _repository.updateOrganization(organizationId, data);
    result.fold((failure) => emit(OwnerOrganizationError(failure.message)), (
      _,
    ) {
      // Reload data to reflect changes
      loadOrganization(organizationId);
      // We emit success first to show snackbar, but then we load.
      // Actually, loadOrganization emits Loading -> Loaded.
      // If we want to show success message, we might need to handle it in UI listener.
      // Let's emit Success then immediately load.
      // Note: Emitting Success might clear the UI form if not handled carefully,
      // but here we want to show a success message.
      // Let's retry: loadOrganization call is async.
      // We can emit Success, and the UI listener can trigger a reload or simply valid.
      // But better: Emit Success, and let UI decide to refresh.
      // Actually, standard pattern: Update -> Success -> Refresh.
      emit(
        const OwnerOrganizationSuccess('Data organisasi berhasil diperbarui'),
      );
      loadOrganization(organizationId);
    });
  }
}
