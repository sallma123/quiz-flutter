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

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (quizState.questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final q = quizState.questions[quizState.currentIndex];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER
            // =====================
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
                  // TIMER
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

                  // INDICATEURS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    List.generate(quizState.questions.length, (i) {
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
                              color:
                              isActive ? colors.primary : Colors.white,
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
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(18),
                boxShadow: theme.cardTheme.shadowColor != null
                    ? [
                  BoxShadow(
                    color: theme.cardTheme.shadowColor!,
                    blurRadius: theme.cardTheme.elevation ?? 4,
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
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                          final quizState =
                          ref.read(quizControllerProvider);

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
