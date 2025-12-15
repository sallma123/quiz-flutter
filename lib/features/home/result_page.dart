import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/question.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final List<Question> questions;
  final List<int?> selections;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.questions,
    required this.selections,
  });

  @override
  Widget build(BuildContext context) {
    final correct = selections.asMap().entries.where(
            (e) => e.value != null && e.value == questions[e.key].correctIndex
    ).length;

    final wrong = selections.asMap().entries.where(
            (e) => e.value != null && e.value != questions[e.key].correctIndex
    ).length;

    final skipped = selections.where((s) => s == null).length;

    final percent = ((correct / total) * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER SCORE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF9C77FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Score",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$score pt",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CARTE RESULTATS
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Analyse du quiz",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // POURCENTAGE CERCLE
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: percent / 100),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        final animatedPercent = (value * 100).round();

                        return SizedBox(
                          height: 160,
                          width: 160,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cercle de progression animé
                              SizedBox(
                                height: 160,
                                width: 160,
                                child: CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 14,
                                  color: const Color(0xFF9C77FF),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                              ),

                              // Cercle blanc intérieur
                              Container(
                                height: 120,
                                width: 120,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),

                              // Texte animé au centre
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "$animatedPercent%",
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "réussite",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),



                  const SizedBox(height: 20),

                  // STATS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          Text("$correct correctes"),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.cancel, color: Colors.red),
                          Text("$wrong incorrectes"),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.remove_circle, color: Colors.grey),
                          Text("$skipped ignorées"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C77FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => context.go(AppRoutes.main),
                      child: const Text("Retour à l'accueil"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      // future: page voir les réponses
                    },
                    child: const Text(
                      "Voir vos réponses",
                      style: TextStyle(color: Colors.purple),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
