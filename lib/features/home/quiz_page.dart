// lib/features/home/quiz_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/question.dart';
import '../../providers/question_provider.dart'; // provider qui charge 5 questions aléatoires
import '../../providers/quiz_providers.dart';

class QuizPage extends ConsumerStatefulWidget {
  final String categoryId;
  final String title;
  const QuizPage({super.key, required this.categoryId, required this.title});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  @override
  void initState() {
    super.initState();
    // Charger les 5 questions depuis Hive (ou provider)
    ref.read(randomQuestionsProvider(widget.categoryId).future).then((list) {
      ref.read(quizControllerProvider.notifier).setQuestions(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final ctrl = ref.read(quizControllerProvider.notifier);

    // Si aucune question chargée
    if (quizState.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final q = quizState.questions[quizState.currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Entête: progression + numéro question
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Question ${quizState.currentIndex + 1} / ${quizState.questions.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
                if (!quizState.submitted)
                  Text('Réponses remplies: ${quizState.selections.where((s) => s != null).length} / ${quizState.questions.length}'),
                if (quizState.submitted)
                  Text('Score : ${quizState.score} / ${quizState.questions.length * 10}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            // Carte question
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(q.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 16),

            // Options (A/B/C/D)
            Expanded(
              child: ListView.builder(
                itemCount: q.options.length,
                itemBuilder: (context, i) {
                  final opt = q.options[i];
                  final sel = quizState.selections[quizState.currentIndex];
                  final bool isSelected = sel != null && sel == i;
                  final bool submitted = quizState.submitted;
                  final bool isCorrect = i == q.correctIndex;

                  Color bgColor;
                  Color textColor = Colors.black;

                  if (submitted) {
                    // après submit, on montre les bonnes / mauvaises réponses
                    if (isCorrect) {
                      bgColor = Colors.green.shade100;
                      textColor = Colors.green.shade900;
                    } else if (isSelected && !isCorrect) {
                      bgColor = Colors.red.shade100;
                      textColor = Colors.red.shade900;
                    } else {
                      bgColor = Colors.white;
                    }
                  } else {
                    // avant submit : mettre en évidence la sélection
                    bgColor = isSelected ? Colors.purple.shade100 : Colors.white;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColor,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: submitted
                          ? null // verrouillé après submit
                          : () {
                        ctrl.selectOption(i); // stocke la réponse, ne passe pas à la question suivante
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Center(child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontWeight: FontWeight.bold))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(opt)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation entre questions (précédent / suivant)
            Row(
              children: [
                OutlinedButton(
                  onPressed: quizState.currentIndex > 0 && !quizState.submitted ? ctrl.previousQuestion : null,
                  child: const Text('Précédent'),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: quizState.currentIndex < quizState.questions.length - 1 && !quizState.submitted ? ctrl.nextQuestion : null,
                  child: const Text('Suivant'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bouton Submit Quiz (activé seulement si toutes les questions ont une réponse)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quizState.submitted
                    ? () {
                  // si déjà soumis, on propose de recommencer
                  ctrl.restart();
                }
                    : (ctrl.allAnswered() ? () {
                  // soumettre et afficher résultat
                  ctrl.submitQuiz();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      title: const Text('Quiz terminé'),
                      content: Text('Ton score : ${ref.read(quizControllerProvider).score} / ${quizState.questions.length * 10}'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // ferme le dialog
                          },
                          child: const Text('OK'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Rejouer
                            ctrl.restart();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Rejouer'),
                        ),
                      ],
                    ),
                  );
                } : null),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(quizState.submitted ? 'Recommencer' : 'Submit Quiz'),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
