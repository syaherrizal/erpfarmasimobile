import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl(this._supabase);

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*, organization:organizations(*), role:roles(*)')
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _supabase.from('profiles').update(data).eq('id', userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getLoginHistory(String userId) async {
    try {
      final response = await _supabase
          .from('login_history')
          .select()
          .eq('user_id', userId)
          .order('login_at', ascending: false)
          .limit(10); // Limit to last 10 sessions for now
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
