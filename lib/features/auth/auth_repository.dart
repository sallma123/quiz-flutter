import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import '../../models/user.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final Box<User> _usersBox = Hive.box<User>('users');
  final _uuid = const Uuid();

  String _hashPassword(String password, {required String salt}) {
    final s = salt + password;
    final bytes = utf8.encode(s);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Recherche sûre : retourne User? (nullable) si non trouvé
  User? _findUserByEmail(String email) {
    for (final u in _usersBox.values) {
      if (u.email.toLowerCase() == email.toLowerCase()) {
        return u;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // vérifie si email existe déjà
    final existing = _findUserByEmail(email);
    if (existing != null) {
      throw Exception('Un compte existe déjà pour cet email.');
    }

    final id = _uuid.v4();
    final passwordHash = _hashPassword(password, salt: id); // salt = id
    final user = User(id: id, name: name, email: email, passwordHash: passwordHash);
    await _usersBox.put(id, user);

    final token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
    return {'token': token, 'user': {'id': id, 'name': name, 'email': email}};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final user = _findUserByEmail(email);
    if (user == null) {
      // aucun utilisateur trouvé : renvoyer une erreur claire
      throw Exception('Email ou mot de passe incorrect.');
    }

    final hashed = _hashPassword(password, salt: user.id);
    if (hashed != user.passwordHash) {
      throw Exception('Email ou mot de passe incorrect.');
    }

    final token = 'local_token_${DateTime.now().millisecondsSinceEpoch}';
    return {'token': token, 'user': {'id': user.id, 'name': user.name, 'email': user.email}};
  }

  Future<void> logout() async {
    // rien à faire côté Hive local; token géré par secure storage
    return;
  }

  // utilitaires
  List<User> getAllUsers() => _usersBox.values.toList();
  User? getUserByEmail(String email) => _findUserByEmail(email);
}
