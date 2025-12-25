import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../../models/history_record.dart';
import '../../providers/question_provider.dart';
import '../../providers/quiz_providers.dart';

/// Page de déroulement du quiz
/// Affiche les questions, gère le temps, les réponses et le score
class QuizPage extends ConsumerStatefulWidget {

  final String categoryId;
  final String title;

  const QuizPage({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {

  // Temps restant pour chaque question (en secondes)
  int timer = 15;

  // Timer utilisé pour le compte à rebours
  Timer? countdown;

  /// Démarre ou redémarre le timer
  void startTimer() {
    countdown?.cancel();
    timer = 15;

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        t.cancel();

        final ctrl = ref.read(quizControllerProvider.notifier);

        // Passe automatiquement à la question suivante
        if (!ctrl.isFinished()) {
          ctrl.nextQuestion();
          startTimer();
        }
      } else {
        setState(() => timer--);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Chargement des questions aléatoires de la catégorie
    ref
        .read(randomQuestionsProvider(widget.categoryId).future)
        .then((list) {

      // Initialisation du quiz avec les questions
      ref.read(quizControllerProvider.notifier).setQuestions(list);

      // Démarrage du timer
      startTimer();
    });
  }

  @override
  void dispose() {
    // Arrêt du timer lors de la destruction de la page
    countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // État actuel du quiz
    final quizState = ref.watch(quizControllerProvider);

    // Contrôleur du quiz
    final ctrl = ref.read(quizControllerProvider.notifier);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Affichage d'un loader tant que les questions ne sont pas chargées
    if (quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Question courante
    final q = quizState.questions[quizState.currentIndex];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [

            // En-tête du quiz (timer + progression)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [

                  // Affichage du timer
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.secondary,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        timer.toString(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Indicateurs de progression des questions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      quizState.questions.length,
                          (i) {
                        final isActive = i == quizState.currentIndex;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: isActive
                                ? colors.secondary
                                : Colors.white54,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${i + 1}",
                              style: TextStyle(
                                color: isActive
                                    ? colors.primary
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Carte affichant la question
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: theme.cardTheme.shadowColor != null
                    ? [
                  BoxShadow(
                    color: theme.cardTheme.shadowColor!,
                    blurRadius:
                    theme.cardTheme.elevation ?? 4,
                  ),
                ]
                    : [],
              ),
              child: Text(
                q.text,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Liste des options de réponse
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, i) {

                  final selected =
                  quizState.selections[quizState.currentIndex];
                  final isSelected = selected == i;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? colors.secondary
                            : colors.secondary.withOpacity(0.25),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      // Sélection de la réponse
                      onPressed: () => ctrl.selectOption(i),

                      child: Row(
                        children: [

                          // Lettre de l'option
                          Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Texte de l'option
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Boutons d'action (suivant / terminer / quitter)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // Bouton principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {

                        // Passage à la question suivante
                        if (!ctrl.isFinished()) {
                          ctrl.nextQuestion();
                          startTimer();
                        }
                        // Fin du quiz
                        else {
                          ctrl.submitQuiz();

                          final quizState =
                          ref.read(quizControllerProvider);

                          // Sauvegarde dans l'historique
                          final historyBox =
                          Hive.box<HistoryRecord>('history');

                          final record = HistoryRecord(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            categoryId: widget.categoryId,
                            title: widget.title,
                            dateTime: DateTime.now(),
                            score: quizState.score,
                            totalQuestions:
                            quizState.questions.length,
                            questions: quizState.questions,
                            selections: quizState.selections,
                          );

                          await historyBox.add(record);

                          // Navigation vers la page résultat
                          context.go(
                            AppRoutes.result,
                            extra: {
                              'score': quizState.score,
                              'total':
                              quizState.questions.length,
                              'questions':
                              quizState.questions,
                              'selections':
                              quizState.selections,
                            },
                          );
                        }
                      },
                      child: Text(
                        ctrl.isFinished()
                            ? "Terminer le quiz"
                            : "Suivant",
                      ),
                    ),
                  ),

                  // Bouton quitter le quiz
                  TextButton(
                    onPressed: () {
                      countdown?.cancel();
                      context.go(AppRoutes.main);
                    },
                    child: const Text("Quitter"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
