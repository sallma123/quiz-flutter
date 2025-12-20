import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants.dart';
import '../../models/history_record.dart';
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

    ref
        .read(randomQuestionsProvider(widget.categoryId).future)
        .then((list) {
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = quizState.questions[quizState.currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF334155), // Bleu ardoise
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // TIMER
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFA5B4FC), // Lavande
                        width: 4,
                      ),
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

                  // INDICATEURS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(quizState.questions.length, (i) {
                      final isActive = i == quizState.currentIndex;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFA5B4FC)
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${i + 1}",
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF334155)
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
            // QUESTION
            // =====================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                q.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =====================
            // OPTIONS
            // =====================
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
                            ? const Color(0xFFA5B4FC)
                            : const Color(0xFFE0E7FF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => ctrl.selectOption(i),
                      child: Row(
                        children: [
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
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1E293B),
                              ),
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
            // ACTIONS
            // =====================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!ctrl.isFinished()) {
                          ctrl.nextQuestion();
                          startTimer();
                        } else {
                          ctrl.submitQuiz();

                          final quizState = ref.read(quizControllerProvider);

                          // 🔥 SAUVEGARDE DANS HIVE
                          final historyBox = Hive.box<HistoryRecord>('history');

                          final record = HistoryRecord(
                            id: DateTime.now().millisecondsSinceEpoch.toString(), // ✅ ID UNIQUE
                            categoryId: widget.categoryId,
                            title: widget.title,
                            dateTime: DateTime.now(),
                            score: quizState.score,
                            totalQuestions: quizState.questions.length,
                            questions: quizState.questions,
                            selections: quizState.selections,
                          );

                          await historyBox.add(record);

                          // ➜ NAVIGATION RESULT
                          context.go(
                            AppRoutes.result,
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
                        backgroundColor:
                        const Color(0xFF334155),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        ctrl.isFinished()
                            ? "Terminer le quiz"
                            : "Suivant",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      countdown?.cancel();
                      context.go(AppRoutes.main);
                    },
                    child: const Text(
                      "Quitter",
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 16,
                      ),
                    ),
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
