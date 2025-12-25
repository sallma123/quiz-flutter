import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/question.dart';
import '../models/history_record.dart';

/// Initialise Hive et charge les données de base (questions et historique)
Future<void> initHiveAndSeed() async {

  // Initialisation de Hive pour Flutter
  await Hive.initFlutter();

  // Enregistrement de l'adapter Question si non enregistré
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(QuestionAdapter());
  }

  // Enregistrement de l'adapter HistoryRecord si non enregistré
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HistoryRecordAdapter());
  }

  // Ouverture de la box des questions
  final questionBox = await Hive.openBox<Question>('questions');

  // Ouverture de la box de l'historique
  await Hive.openBox<HistoryRecord>('history');

  // Vérifie si les questions sont déjà chargées pour éviter un double chargement
  if (questionBox.isNotEmpty) {
    print("Questions déjà chargées ✔️");
    return;
  }

  // Chargement des questions par catégorie
  await _loadCategory(questionBox, 'gen');
  await _loadCategory(questionBox, 'science');
  await _loadCategory(questionBox, 'sport');
  await _loadCategory(questionBox, 'myth');
  await _loadCategory(questionBox, 'geo');
  await _loadCategory(questionBox, 'his');

  print("Toutes les questions importées");
}

/// Charge les questions d'une catégorie depuis un fichier JSON vers Hive
Future<void> _loadCategory(Box<Question> box, String category) async {

  // Chemin du fichier JSON de la catégorie
  final String path = 'assets/questions/$category.json';

  // Lecture du fichier JSON depuis les assets
  final String jsonString = await rootBundle.loadString(path);

  // Décodage du contenu JSON
  final List<dynamic> data = jsonDecode(jsonString);

  // Parcours de toutes les questions
  for (final q in data) {

    // Création de l'objet Question
    final question = Question(
      id: q['id'] as String,
      categoryId: q['categoryId'] as String,
      text: q['text'] as String,
      options: List<String>.from(q['options']),
      correctIndex: q['correctIndex'] as int,
    );

    // Enregistrement de la question dans Hive
    await box.put(question.id, question);
  }
}
