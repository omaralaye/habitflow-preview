import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    HapticFeedback.lightImpact();
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signup(String email, String password) async {
    HapticFeedback.lightImpact();
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    HapticFeedback.lightImpact();
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  bool isAuthenticated() {
    return getCurrentUser() != null;
  }
}
