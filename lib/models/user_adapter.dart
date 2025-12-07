import 'package:hive/hive.dart';
import 'package:quiz/models/user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final email = reader.readString();
    final passwordHash = reader.readString();
    return User(id: id, name: name, email: email, passwordHash: passwordHash);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.passwordHash);
  }
}
