import 'dart:async';

import '../core/app_settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    HapticUtil.lightImpact();
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signup(String email, String password) async {
    HapticUtil.lightImpact();
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    HapticUtil.lightImpact();
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://callback',
    );
  }

  Future<void> logout() async {
    HapticUtil.lightImpact();
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  bool isAuthenticated() {
    return getCurrentUser() != null;
  }

  StreamSubscription<AuthState> onAuthChange(void Function(AuthState) cb) {
    return _client.auth.onAuthStateChange.listen(cb);
  }
}
