import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:erpfarmasimobile/features/auth/presentation/bloc/permission/permission_state.dart';

class PermissionCubit extends Cubit<PermissionState> {
  final SupabaseClient _supabase;

  PermissionCubit(this._supabase) : super(PermissionInitial());

  Future<void> loadPermissions(String userId, String organizationId) async {
    emit(PermissionLoading());
    try {
      // 1. Get user_role_id from profiles
      final profileResponse = await _supabase
          .from('profiles')
          .select('role_id')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse == null) {
        emit(const PermissionError('Profil pengguna tidak ditemukan.'));
        return;
      }

      final roleId = profileResponse['role_id'];

      if (roleId == null) {
        emit(const PermissionError('Role tidak ditemukan untuk user ini.'));
        return;
      }

      // 2. Get permissions for this role
      final permissionsResponse = await _supabase
          .from('role_permissions')
          .select('permissions(code)')
          .eq('role_id', roleId);

      final List<dynamic> data = permissionsResponse as List<dynamic>;
      final permissions = data
          .map(
            (e) => (e['permissions'] as Map<String, dynamic>)['code'] as String,
          )
          .toSet();

      emit(PermissionLoaded(permissions: permissions));
    } catch (e) {
      emit(PermissionError('Gagal memuat permission: ${e.toString()}'));
    }
  }

  bool hasPermission(String permissionCode) {
    if (state is PermissionLoaded) {
      return (state as PermissionLoaded).permissions.contains(permissionCode);
    }
    return false;
  }

  void reset() {
    emit(PermissionInitial());
  }
}
