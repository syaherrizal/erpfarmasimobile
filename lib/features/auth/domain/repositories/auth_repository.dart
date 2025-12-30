import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;
  Future<AuthResponse> signInWithEmail(String email, String password);
  Future<AuthResponse> signInWithGoogle();
  Future<void> signOut();
  Future<Map<String, dynamic>?> getUserProfile(String userId);
}
