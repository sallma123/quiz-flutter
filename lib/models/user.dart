import 'package:hive/hive.dart';

/// Modèle utilisateur
/// Représente un utilisateur enregistré dans l’application
@HiveType(typeId: 0)
class User extends HiveObject {

  // Identifiant unique de l’utilisateur (UUID ou timestamp)
  @HiveField(0)
  String id;

  // Nom de l’utilisateur
  @HiveField(1)
  String name;

  // Adresse email de l’utilisateur
  @HiveField(2)
  String email;

  // Mot de passe haché
  // Le mot de passe n’est jamais stocké en clair
  @HiveField(3)
  String passwordHash;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
  });
}
