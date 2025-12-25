import 'package:hive/hive.dart';
import 'package:quiz/models/user.dart';

/// Adapter Hive pour la classe User
/// Permet de sauvegarder et lire un utilisateur depuis Hive
class UserAdapter extends TypeAdapter<User> {

  // Identifiant unique de l’adapter (doit être unique dans tout le projet)
  @override
  final int typeId = 0;

  /// Méthode appelée par Hive pour lire un utilisateur depuis le stockage
  @override
  User read(BinaryReader reader) {

    // Lecture des champs dans le même ordre que l’écriture
    final id = reader.readString();
    final name = reader.readString();
    final email = reader.readString();
    final passwordHash = reader.readString();

    // Reconstruction de l’objet User
    return User(
      id: id,
      name: name,
      email: email,
      passwordHash: passwordHash,
    );
  }

  /// Méthode appelée par Hive pour enregistrer un utilisateur
  @override
  void write(BinaryWriter writer, User obj) {

    // Écriture des champs dans un ordre précis
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.passwordHash);
  }
}
