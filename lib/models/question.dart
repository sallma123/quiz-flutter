import 'package:hive/hive.dart';
part 'question.g.dart';

@HiveType(typeId: 1)
class Question extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId; // ex: 'gen','sport','myth',...

  @HiveField(2)
  String text;

  @HiveField(3)
  List<String> options;

  @HiveField(4)
  int correctIndex;

  Question({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}
