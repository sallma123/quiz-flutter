import 'package:hive/hive.dart';
import 'question.dart';

part 'history_record.g.dart';

@HiveType(typeId: 2)
class HistoryRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final int score;

  @HiveField(5)
  final int totalQuestions;

  @HiveField(6)
  final List<Question> questions;

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
