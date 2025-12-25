import 'package:hive/hive.dart';
part 'question.g.dart';

/// Modèle Question
/// Représente une question de quiz stockée localement avec Hive
@HiveType(typeId: 1)
class Question extends HiveObject {

  // Identifiant unique de la question
  @HiveField(0)
  String id;

  // Identifiant de la catégorie (ex : gen, sport, myth, etc.)
  @HiveField(1)
  String categoryId;

  // Texte de la question
  @HiveField(2)
  String text;

  // Liste des réponses possibles
  @HiveField(3)
  List<String> options;

  // Index de la bonne réponse dans la liste options
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
