import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'branch_context_state.dart';

class BranchContextCubit extends Cubit<BranchContextState> {
  final SupabaseClient _supabase;

  BranchContextCubit(this._supabase) : super(BranchContextInitial());

  Future<void> loadMemberships(String userId, String organizationId) async {
    emit(BranchContextLoading());
    try {
      final response = await _supabase
          .from('user_branch_memberships')
          .select('*, branch:branches(*)')
          .eq('user_id', userId)
          .eq('organization_id', organizationId)
          .eq('is_active', true);

      final List<dynamic> data = response as List<dynamic>;

      if (data.isEmpty) {
        emit(
          const BranchContextError('Anda tidak terdaftar di cabang manapun.'),
        );
        return;
      }

      final branches = data.map((e) => e as Map<String, dynamic>).toList();

      if (branches.length == 1) {
        final branch = branches.first;
        emit(
          BranchContextLoaded(
            memberships: branches,
            selectedBranchId: branch['branch_id'],
            selectedBranchName: branch['branch']['name'],
            organizationId: organizationId,
          ),
        );
      } else {
        // Find default branch if any
        final defaultBranch = branches.firstWhere(
          (e) => e['is_default'] == true,
          orElse: () => branches.first,
        );

        emit(
          BranchContextLoaded(
            memberships: branches,
            selectedBranchId: defaultBranch['branch_id'],
            selectedBranchName: defaultBranch['branch']['name'],
            organizationId: organizationId,
            isSelectionRequired: true,
          ),
        );
      }
    } catch (e) {
      emit(BranchContextError('Gagal memuat data cabang: ${e.toString()}'));
    }
  }

  void selectBranch(Map<String, dynamic> membership) {
    if (state is BranchContextLoaded) {
      final currentState = state as BranchContextLoaded;
      emit(
        currentState.copyWith(
          selectedBranchId: membership['branch_id'],
          selectedBranchName: membership['branch']['name'],
          isSelectionRequired: false,
        ),
      );
    }
  }

  void reset() {
    emit(BranchContextInitial());
  }
}
