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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final correct = selections.asMap().entries.where(
          (e) => e.value != null && e.value == questions[e.key].correctIndex,
    ).length;

    final wrong = selections.asMap().entries.where(
          (e) => e.value != null && e.value != questions[e.key].correctIndex,
    ).length;

    final skipped = selections.where((s) => s == null).length;
    final percent = ((correct / total) * 100).toInt();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER SCORE (THEME)
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Score",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$score pt",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================
            // CARTE RESULTATS
            // =====================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Analyse du quiz",
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // POURCENTAGE CERCLE
                  // =====================
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent / 100),
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
                            SizedBox(
                              height: 160,
                              width: 160,
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 14,
                                color: colors.secondary,
                                backgroundColor:
                                colors.onSurface.withValues(alpha: 0.15),
                              ),
                            ),
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "$animatedPercent%",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "réussite",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // =====================
                  // STATS (VERT / ROUGE OK)
                  // =====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(height: 4),
                          Text("$correct correctes"),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.cancel, color: Colors.red),
                          const SizedBox(height: 4),
                          Text("$wrong incorrectes"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.remove_circle,
                            color:
                            colors.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 4),
                          Text("$skipped ignorées"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // =====================
            // ACTIONS
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.main),
                      child: const Text("Retour à l'accueil"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      context.push(
                        '/answers',
                        extra: {
                          'questions': questions,
                          'selections': selections,
                        },
                      );
                    },
                    child: const Text("Voir vos réponses"),
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
