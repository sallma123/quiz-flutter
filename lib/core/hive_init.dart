import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/question.dart';
import '../models/history_record.dart';

Future<void> initHiveAndSeed() async {
  // =========================
  // INITIALISATION HIVE
  // =========================
  await Hive.initFlutter();

  // =========================
  // ENREGISTREMENT ADAPTERS
  // =========================
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HistoryRecordAdapter());
  }

  // =========================
  // RESET TEMPORAIRE (DEV ONLY)
  // =========================
  // ⚠️ À décommenter UNE SEULE FOIS
 await Hive.deleteBoxFromDisk('questions');

  // =========================
  // OUVERTURE DES BOXES
  // =========================
  final questionBox = await Hive.openBox<Question>('questions');
  await Hive.openBox<HistoryRecord>('history');

  // =========================
  // ÉVITER DOUBLE SEED
  // =========================
  if (questionBox.isNotEmpty) {
    print("Questions déjà chargées ✔️");
    return;
  }

  // =========================
  // CHARGEMENT DES CATÉGORIES
  // =========================
  await _loadCategory(questionBox, 'gen');
  await _loadCategory(questionBox, 'science');
  await _loadCategory(questionBox, 'sport');
  await _loadCategory(questionBox, 'myth');
  await _loadCategory(questionBox, 'geo');
  await _loadCategory(questionBox, 'his');

  print("Toutes les questions importées ✔️");
}

// =========================
// CHARGEMENT JSON → HIVE
// =========================
Future<void> _loadCategory(Box<Question> box, String category) async {
  final String path = 'assets/questions/$category.json';

  final String jsonString = await rootBundle.loadString(path);
  final List<dynamic> data = jsonDecode(jsonString);

  for (final q in data) {
    final question = Question(
      id: q['id'] as String,
      categoryId: q['categoryId'] as String,
      text: q['text'] as String,
      options: List<String>.from(q['options']),
      correctIndex: q['correctIndex'] as int,
    );

    await box.put(question.id, question);
  }
}
