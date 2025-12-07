import 'package:hive/hive.dart';



@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id; // par ex. timestamp ou uuid

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String passwordHash; // stocke le haché (ne pas stocker le mdp en clair)

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
  });
}
