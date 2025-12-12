import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';

final questionsBoxProvider = Provider<Box<Question>>((ref) {
  return Hive.box<Question>('questions');
});

final randomQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, categoryId) async {
  final box = ref.watch(questionsBoxProvider);
  final list = box.values.where((q) => q.categoryId == categoryId).toList();
  list.shuffle(Random());
  return list.take(5).toList(); // 5 questions aléatoires
});
