abstract class ProfileRepository {
  Future<Map<String, dynamic>?> getProfile(String userId);
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getLoginHistory(String userId);
}
