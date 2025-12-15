// lib/features/home/quiz_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/question_provider.dart';
import '../../providers/quiz_providers.dart';

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
  int timer = 15;
  Timer? countdown;

  void startTimer() {
    countdown?.cancel();
    timer = 15;

    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer == 0) {
        t.cancel();
        // Passe à la question suivante automatiquement
        final ctrl = ref.read(quizControllerProvider.notifier);
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

    // Charger les 5 questions et démarrer timer
    ref.read(randomQuestionsProvider(widget.categoryId).future).then((list) {
      ref.read(quizControllerProvider.notifier).setQuestions(list);
      startTimer();
    });
  }

  @override
  void dispose() {
    countdown?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final ctrl = ref.read(quizControllerProvider.notifier);

    if (quizState.questions.isEmpty) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final q = quizState.questions[quizState.currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER VIOLET
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF9C77FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // Timer circulaire
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        timer.toString(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // INDICATEURS 1 2 3 4 5
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(quizState.questions.length, (i) {
                      final isActive = i == quizState.currentIndex;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${i + 1}",
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF9C77FF)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // CARTE QUESTION
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =====================
            // OPTIONS A B C D
            // =====================
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, i) {
                  final selected = quizState.selections[quizState.currentIndex];
                  final isSelected = selected == i;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isSelected
                            ? const Color(0xFF9C77FF)
                            : const Color(0xFFD6C9FF),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        ctrl.selectOption(i);
                      },
                      child: Row(
                        children: [
                          // Lettre A, B, C, D
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9C77FF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

// =====================
// BOUTON SUIVANT / TERMINER + QUITTER
// =====================
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Si pas toutes les réponses → on passe à la question suivante
                      if (!ctrl.isFinished()) {
                        ctrl.nextQuestion();
                        startTimer();
                      }
                      else {
                        ctrl.submitQuiz();
                        context.go(
                          '/result',
                          extra: {
                            'score': quizState.score,
                            'total': quizState.questions.length,
                            'questions': quizState.questions,
                            'selections': quizState.selections,
                          },
                        );

                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C77FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    // Texte dynamique : "Suivant" ou "Terminer"
                    child: Text(
                      ctrl.isFinished() ? "Terminer le quiz" : "Suivant",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

// Bouton quitter -> retour HomePage
                TextButton(
                  onPressed: () {
                    countdown?.cancel();  // stop timer proprement
                    context.go(AppRoutes.main);  // retour direct à la page d'accueil
                  },
                  child: const Text(
                    "Quitter",
                    style: TextStyle(color: Colors.purple, fontSize: 16),
                  ),
                ),

              ],
            ),


            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
