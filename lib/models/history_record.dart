import 'package:hive/hive.dart';
import 'question.dart';

part 'history_record.g.dart';

/// Modèle HistoryRecord
/// Représente l’historique d’un quiz joué par l’utilisateur
@HiveType(typeId: 2)
class HistoryRecord extends HiveObject {

  // Identifiant unique de l’historique
  @HiveField(0)
  final String id;

  // Identifiant de la catégorie du quiz
  @HiveField(1)
  final String categoryId;

  // Titre du quiz (nom de la catégorie)
  @HiveField(2)
  final String title;

  // Date et heure de passage du quiz
  @HiveField(3)
  final DateTime dateTime;

  // Score obtenu lors du quiz
  @HiveField(4)
  final int score;

  // Nombre total de questions du quiz
  @HiveField(5)
  final int totalQuestions;

  // Liste des questions du quiz
  @HiveField(6)
  final List<Question> questions;

  // Réponses sélectionnées par l’utilisateur
  // Chaque valeur correspond à l’index de la réponse choisie
  @HiveField(7)
  final List<int?> selections;

  HistoryRecord({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.dateTime,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.selections,
  });
}
