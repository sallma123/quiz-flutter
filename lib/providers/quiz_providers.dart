import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/question.dart';

/// État du quiz
/// Contient toutes les informations nécessaires pendant un quiz
class QuizState {

  // Liste des questions du quiz
  final List<Question> questions;

  // Index de la question actuellement affichée
  final int currentIndex;

  // Réponses sélectionnées par l’utilisateur (null si aucune réponse)
  final List<int?> selections;

  // Score total calculé après la soumission du quiz
  final int score;

  // Indique si le quiz a été soumis ou non
  final bool submitted;

  QuizState({
    required this.questions,
    this.currentIndex = 0,
    List<int?>? selections,
    this.score = 0,
    this.submitted = false,
  }) : selections = selections ??
      List<int?>.filled(questions.length, null);

  /// Permet de créer une nouvelle copie de l’état avec des valeurs modifiées
  QuizState copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<int?>? selections,
    int? score,
    bool? submitted,
  }) {

    // Gestion correcte de la liste des sélections
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

/// Contrôleur du quiz
/// Gère toute la logique métier du quiz
class QuizController extends StateNotifier<QuizState> {

  QuizController() : super(QuizState(questions: []));

  /// Initialise le quiz avec une nouvelle liste de questions
  void setQuestions(List<Question> q) {
    state = QuizState(
      questions: q,
      currentIndex: 0,
      selections: List<int?>.filled(q.length, null),
      submitted: false,
      score: 0,
    );
  }

  /// Enregistre la réponse choisie pour la question courante
  void selectOption(int index) {
    if (state.submitted) return;

    final newSelections = [...state.selections];
    newSelections[state.currentIndex] = index;

    state = state.copyWith(selections: newSelections);
  }

  /// Passe à la question suivante
  void nextQuestion() {
    if (state.currentIndex < state.questions.length - 1) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
      );
    }
  }

  /// Revient à la question précédente
  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
      );
    }
  }

  /// Vérifie si l’utilisateur est à la dernière question
  bool isFinished() {
    return state.currentIndex + 1 >= state.questions.length;
  }

  /// Vérifie si toutes les questions ont une réponse
  bool allAnswered() {
    return !state.selections.contains(null);
  }

  /// Calcule le score final et marque le quiz comme terminé
  void submitQuiz() {
    int total = 0;

    for (int i = 0; i < state.questions.length; i++) {
      final selected = state.selections[i];
      if (selected != null &&
          selected == state.questions[i].correctIndex) {
        total += 10;
      }
    }

    state = state.copyWith(
      score: total,
      submitted: true,
    );
  }

  /// Redémarre le quiz avec les mêmes questions mélangées
  void restart() {
    final reshuffled = [...state.questions]..shuffle(Random());
    setQuestions(reshuffled);
  }
}

/// Provider Riverpod du contrôleur de quiz
final quizControllerProvider =
StateNotifierProvider<QuizController, QuizState>(
      (ref) => QuizController(),
);
