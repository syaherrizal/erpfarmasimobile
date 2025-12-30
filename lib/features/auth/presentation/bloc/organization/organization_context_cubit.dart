import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'organization_context_state.dart';

class OrganizationContextCubit extends Cubit<OrganizationContextState> {
  final SupabaseClient _supabase;

  OrganizationContextCubit(this._supabase)
    : super(OrganizationContextInitial());

  Future<void> loadOrganizationContext(String userId) async {
    emit(OrganizationContextLoading());

    try {
      // 1. Fetch Profile and Validate Organization Context
      final profileResponse = await _supabase
          .from('profiles')
          .select('organization_id, status')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse == null) {
        emit(
          const OrganizationContextError(
            'Profil pengguna tidak ditemukan. Silakan hubungi admin.',
          ),
        );
        return;
      }

      final String? orgId = profileResponse['organization_id'];
      final String? userStatus = profileResponse['status'];

      if (orgId == null) {
        emit(
          const OrganizationContextError(
            'Akun Anda belum terdaftar di organisasi manapun.',
          ),
        );
        return;
      }

      // Handle null status as active if requested by system context or allowed
      if (userStatus != null && userStatus != 'active') {
        emit(
          const OrganizationContextError(
            'Status akun Anda tidak aktif. Silakan hubungi admin.',
          ),
        );
        return;
      }

      // 2. Fetch Organization Data
      final orgResponse = await _supabase
          .from('organizations')
          .select('*')
          .eq('id', orgId)
          .maybeSingle();

      if (orgResponse == null) {
        emit(
          const OrganizationContextError('Data organisasi tidak ditemukan.'),
        );
        return;
      }

      emit(
        OrganizationContextLoaded(
          organizationId: orgId,
          organizationName: orgResponse['name'] ?? 'Unknown Organization',
          organizationLogo: orgResponse['logo_url'],
          organizationData: orgResponse,
        ),
      );
    } catch (e) {
      emit(OrganizationContextError('Gagal memuat konteks organisasi: $e'));
    }
  }

  void reset() {
    emit(OrganizationContextInitial());
  }
}
