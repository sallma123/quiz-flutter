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

  /// Initialise le quiz avec une liste de questions (5 choix)
  void setQuestions(List<Question> q) {
    state = QuizState(questions: List<Question>.from(q));
  }

  /// Sélectionne une option pour la question courante.
  /// Ne calcule pas le score et n'avance pas : permet modification avant submit.
  void selectOption(int optionIndex) {
    final idx = state.currentIndex;
    final selections = List<int?>.from(state.selections);
    if (idx < selections.length) {
      selections[idx] = optionIndex;
      state = state.copyWith(selections: selections);
    }
  }

  /// Aller à la question suivante (si possible)
  void nextQuestion() {
    if (state.currentIndex + 1 < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Aller à la question précédente (si possible)
  void previousQuestion() {
    if (state.currentIndex - 1 >= 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Vérifie si toutes les questions ont une réponse (sélections non-null)
  bool allAnswered() {
    return !state.selections.contains(null) && state.questions.isNotEmpty;
  }

  /// Soumettre le quiz : calcule le score (10 points par bonne réponse)
  void submitQuiz() {
    int total = 0;
    for (var i = 0; i < state.questions.length; i++) {
      final sel = state.selections[i];
      if (sel != null && sel == state.questions[i].correctIndex) {
        total += 10;
      }
    }
    state = state.copyWith(score: total, submitted: true);
  }

  /// Recommencer (reset)
  void restart() {
    final q = List<Question>.from(state.questions)..shuffle(Random());
    state = QuizState(questions: q);
  }
}

final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) => QuizController());
