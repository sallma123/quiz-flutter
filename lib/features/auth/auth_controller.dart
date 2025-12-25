import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_repository.dart';

/// Provider du repository d'authentification
/// Contient la logique métier (login, signup, logout)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider du stockage sécurisé
/// Utilisé pour sauvegarder le token et les infos utilisateur
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// États possibles de l'authentification
enum AuthStatus {
  unknown,          // État initial (au démarrage)
  authenticated,    // Utilisateur connecté
  unauthenticated,  // Utilisateur déconnecté
  loading,          // Action en cours (login/signup)
  error,            // Erreur d'authentification
}

/// Représente l'état global de l'authentification
class AuthState {
  final AuthStatus status;
  final String? token;
  final String? name;
  final String? email;
  final String? errorMessage;

  /// Constructeur privé
  const AuthState._({
    required this.status,
    this.token,
    this.name,
    this.email,
    this.errorMessage,
  });

  /// État initial au lancement de l'application
  const AuthState.unknown() : this._(status: AuthStatus.unknown);

  /// Utilisateur non connecté
  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  /// Action en cours (chargement)
  const AuthState.loading() : this._(status: AuthStatus.loading);

  /// Utilisateur connecté avec ses informations
  const AuthState.authenticated(
      String token,
      String name,
      String email,
      ) : this._(
    status: AuthStatus.authenticated,
    token: token,
    name: name,
    email: email,
  );

  /// Erreur d'authentification
  const AuthState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);
}

/// Contrôleur d'authentification
/// Gère l'état global via Riverpod (StateNotifier)
class AuthController extends StateNotifier<AuthState> {

  // Repository contenant la logique d'authentification
  final AuthRepository _repo;

  // Stockage sécurisé pour le token et les infos utilisateur
  final FlutterSecureStorage _secureStorage;

  // Clés utilisées dans le stockage sécurisé
  static const _tokenKey = 'auth_token';
  static const _nameKey = 'auth_name';
  static const _emailKey = 'auth_email';

  /// Constructeur
  /// Appelle automatiquement la restauration de session
  AuthController(this._repo, this._secureStorage)
      : super(const AuthState.unknown()) {
    _restoreSession();
  }

  /// Restaure la session utilisateur au lancement de l'application
  /// Vérifie si un token est déjà stocké
  Future<void> _restoreSession() async {

    // Lecture des données stockées
    final token = await _secureStorage.read(key: _tokenKey);
    final name = await _secureStorage.read(key: _nameKey);
    final email = await _secureStorage.read(key: _emailKey);

    // Si toutes les infos existent → utilisateur connecté
    if (token != null && name != null && email != null) {
      state = AuthState.authenticated(token, name, email);
    }
    // Sinon → utilisateur déconnecté
    else {
      state = const AuthState.unauthenticated();
    }
  }

  /// Inscription d'un nouvel utilisateur
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Passage en état loading
      state = const AuthState.loading();

      // Appel au repository
      final res = await _repo.signup(
        name: name,
        email: email,
        password: password,
      );

      // Récupération des données
      final token = res['token'] as String;
      final user = res['user'] as Map<String, dynamic>;

      // Sauvegarde sécurisée
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(
          key: _nameKey, value: user['name'] as String);
      await _secureStorage.write(
          key: _emailKey, value: user['email'] as String);

      // Mise à jour de l'état (connecté)
      state = AuthState.authenticated(
        token,
        user['name'] as String,
        user['email'] as String,
      );
    } catch (e) {
      // Gestion des erreurs
      state = AuthState.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Connexion d'un utilisateur existant
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      // Passage en état loading
      state = const AuthState.loading();

      // Appel au repository
      final res = await _repo.login(
        email: email,
        password: password,
      );

      // Récupération des données
      final token = res['token'] as String;
      final user = res['user'] as Map<String, dynamic>;

      // Sauvegarde sécurisée
      await _secureStorage.write(key: _tokenKey, value: token);
      await _secureStorage.write(
          key: _nameKey, value: user['name'] as String);
      await _secureStorage.write(
          key: _emailKey, value: user['email'] as String);

      // Mise à jour de l'état (connecté)
      state = AuthState.authenticated(
        token,
        user['name'] as String,
        user['email'] as String,
      );
    } catch (e) {
      // Gestion des erreurs
      state = AuthState.error(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Déconnexion de l'utilisateur
  /// Met immédiatement l'état à "unauthenticated"
  void logout() {

    // Mise à jour immédiate de l'état
    state = const AuthState.unauthenticated();

    // Nettoyage du stockage sécurisé (sans bloquer l'UI)
    _secureStorage.delete(key: _tokenKey);
    _secureStorage.delete(key: _nameKey);
    _secureStorage.delete(key: _emailKey);

    // Appel optionnel au repository (si backend plus tard)
    _repo.logout();
  }
}

/// Provider global du contrôleur d'authentification
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthController(repo, storage);
});
