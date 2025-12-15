// lib/providers/quiz_providers.dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';

class QuizState {
  final List<Question> questions;
  final int currentIndex;
  final List<int?> selections; // sélection par question (index de l'option ou null)
  final int score; // score calculé après submit
  final bool submitted; // true si l'utilisateur a appuyé sur Submit

  QuizState({
    required this.questions,
    this.currentIndex = 0,
    List<int?>? selections,
    this.score = 0,
    this.submitted = false,
  }) : selections = selections ?? List<int?>.filled(questions.length, null);

  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<int?>? selections,
    int? score,
    bool? submitted,
  }) {
    // Si on remplace la liste de questions, recréer les selections adaptées
    List<int?> newSelections;
    if (selections != null) {
      newSelections = selections;
    } else if (questions != null) {
      newSelections = List<int?>.filled(questions.length, null);
    } else {
      newSelections = List<int?>.from(this.selections);
    }

    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selections: newSelections,
      score: score ?? this.score,
      submitted: submitted ?? this.submitted,
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  QuizController() : super(QuizState(questions: []));

  void setQuestions(List<Question> q) {
    state = QuizState(
      questions: q,
      currentIndex: 0,
      selections: List<int?>.filled(q.length, null),
      submitted: false,
      score: 0,
    );
  }

  void selectOption(int index) {
    if (state.submitted) return;

    final newSelections = [...state.selections];
    newSelections[state.currentIndex] = index;

    state = state.copyWith(selections: newSelections);
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// 🔥 METHOD YOU WERE MISSING
  bool isFinished() {
    return state.currentIndex + 1 >= state.questions.length;
  }

  bool allAnswered() {
    return !state.selections.contains(null);
  }

  void submitQuiz() {
    int total = 0;

    for (int i = 0; i < state.questions.length; i++) {
      final selected = state.selections[i];
      if (selected != null && selected == state.questions[i].correctIndex) {
        total += 10;
      }
    }

    state = state.copyWith(score: total, submitted: true);
  }

  void restart() {
    final reshuffled = [...state.questions]..shuffle();
    setQuestions(reshuffled);
  }
}


final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) => QuizController());
