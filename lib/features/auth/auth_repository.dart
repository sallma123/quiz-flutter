import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import '../../models/user.dart';
import 'package:uuid/uuid.dart';

/// Repository d'authentification
/// Contient toute la logique métier liée aux utilisateurs
/// (inscription, connexion, sécurité des mots de passe)
class AuthRepository {

  // Box Hive contenant les utilisateurs
  final Box<User> _usersBox = Hive.box<User>('users');

  // Générateur d'identifiants uniques
  final _uuid = const Uuid();

  /// Hachage du mot de passe avec SHA-256
  /// Utilise un salt (identifiant utilisateur) pour plus de sécurité
  String _hashPassword(String password, {required String salt}) {
    final s = salt + password;
    final bytes = utf8.encode(s);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Recherche sécurisée d'un utilisateur par email
  /// Retourne null si aucun utilisateur n'est trouvé
  User? _findUserByEmail(String email) {
    for (final u in _usersBox.values) {
      if (u.email.toLowerCase() == email.toLowerCase()) {
        return u;
      }
    }
    return null;
  }

  /// Inscription d'un nouvel utilisateur
  /// Vérifie l'unicité de l'email et enregistre l'utilisateur
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {

    // Vérifie si un compte existe déjà pour cet email
    final existing = _findUserByEmail(email);
    if (existing != null) {
      throw Exception('Un compte existe déjà pour cet email.');
    }

    // Génération d'un identifiant unique
    final id = _uuid.v4();

    // Hachage du mot de passe avec salt = id utilisateur
    final passwordHash = _hashPassword(password, salt: id);

    // Création de l'utilisateur
    final user = User(
      id: id,
      name: name,
      email: email,
      passwordHash: passwordHash,
    );

    // Enregistrement dans Hive
    await _usersBox.put(id, user);

    // Génération d'un token local (simulation backend)
    final token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';

    // Retour des données utiles
    return {
      'token': token,
      'user': {
        'id': id,
        'name': name,
        'email': email,
      }
    };
  }

  /// Connexion d'un utilisateur existant
  /// Vérifie l'email et le mot de passe
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    // Recherche de l'utilisateur par email
    final user = _findUserByEmail(email);
    if (user == null) {
      throw Exception('Email ou mot de passe incorrect.');
    }

    // Hachage du mot de passe saisi
    final hashed = _hashPassword(password, salt: user.id);

    // Comparaison avec le hash stocké
    if (hashed != user.passwordHash) {
      throw Exception('Email ou mot de passe incorrect.');
    }

    // Génération d'un token local
    final token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';

    // Retour des données utilisateur
    return {
      'token': token,
      'user': {
        'id': user.id,
        'name': user.name,
        'email': user.email,
      }
    };
  }

  /// Déconnexion (locale)
  Future<void> logout() async {
    return;
  }

  /// Retourne la liste de tous les utilisateurs enregistrés
  List<User> getAllUsers() => _usersBox.values.toList();

  /// Retourne un utilisateur à partir de son email
  User? getUserByEmail(String email) => _findUserByEmail(email);
}
