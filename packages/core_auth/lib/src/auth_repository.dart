import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  const AuthUser({required this.uid, this.email, this.displayName});
  final String uid;
  final String? email;
  final String? displayName;
}

abstract class AuthRepository {
  /// Emits the signed-in user, or null when signed out.
  Stream<AuthUser?> get authState;

  AuthUser? get currentUser;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> createAccount({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  static AuthUser? _map(User? u) => u == null
      ? null
      : AuthUser(
          uid: u.id,
          email: u.email,
          displayName: u.userMetadata?['display_name'] as String?,
        );

  @override
  Stream<AuthUser?> get authState =>
      _client.auth.onAuthStateChange.map((s) => _map(s.session?.user));

  @override
  AuthUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    final r = await _client.auth.signInWithPassword(email: email, password: password);
    return _map(r.user)!;
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final r = await _client.auth.signUp(
      email: email,
      password: password,
      data: displayName == null ? null : {'display_name': displayName},
    );
    final user = _map(r.user);
    if (user == null) throw StateError('Sign-up returned no user.');
    return user;
  }

  @override
  Future<void> signOut() => _client.auth.signOut();
}
