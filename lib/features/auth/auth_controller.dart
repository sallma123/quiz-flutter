import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

enum AuthStatus { unknown, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? name;
  final String? email;
  final String? errorMessage;

  const AuthState._({
    required this.status,
    this.token,
    this.name,
    this.email,
    this.errorMessage,
  });

  const AuthState.unknown() : this._(status: AuthStatus.unknown);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.authenticated(String token, String name, String email)
      : this._(status: AuthStatus.authenticated, token: token, name: name, email: email);
  const AuthState.error(String message) : this._(status: AuthStatus.error, errorMessage: message);
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';

  AuthController(this._repo, this._secureStorage) : super(const AuthState.unknown()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final token = await _secureStorage.read(key: _tokenKey);
    final name = await _secureStorage.read(key: _nameKey);
    final email = await _secureStorage.read(key: _emailKey);
    if (token != null && email != null && name != null) {
      state = AuthState.authenticated(token, name, email);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();
      final res = await _repo.signup(name: name, email: email, password: password);
      final token = res['token'] as String;
      final user = res['user'] as Map<String, dynamic>;
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _nameKey, value: user['name'] as String);
      await _secureStorage.write(key: _emailKey, value: user['email'] as String);
      state = AuthState.authenticated(token, user['name'] as String, user['email'] as String);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      state = const AuthState.loading();
      final res = await _repo.login(email: email, password: password);
      final token = res['token'] as String;
      final user = res['user'] as Map<String, dynamic>;
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(key: _nameKey, value: user['name'] as String);
      await _secureStorage.write(key: _emailKey, value: user['email'] as String);
      state = AuthState.authenticated(token, user['name'] as String, user['email'] as String);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    try {
      state = const AuthState.loading();
      await _repo.logout();
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _nameKey);
      await _secureStorage.delete(key: _emailKey);
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// provider pour le controller
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthController(repo, storage);
});
