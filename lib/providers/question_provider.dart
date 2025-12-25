import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

/// Provider de la box Hive contenant les questions
/// Permet d’accéder aux questions stockées localement
final questionsBoxProvider = Provider<Box<Question>>((ref) {
  return Hive.box<Question>('questions');
});

/// Provider asynchrone qui retourne 5 questions aléatoires
/// Filtrées par catégorie
final randomQuestionsProvider =
FutureProvider.family<List<Question>, String>((ref, categoryId) async {

  // Accès à la box des questions
  final box = ref.watch(questionsBoxProvider);

  // Filtrage des questions selon la catégorie choisie
  final list =
  box.values.where((q) => q.categoryId == categoryId).toList();

  // Mélange aléatoire des questions
  list.shuffle(Random());

  // Sélection de 5 questions maximum
  return list.take(5).toList();
});
