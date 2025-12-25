import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/question.dart';

/// Page de résultat du quiz
/// Affiche le score final, le pourcentage de réussite et le détail des réponses
class ResultPage extends StatelessWidget {

  // Score total obtenu
  final int score;

  // Nombre total de questions
  final int total;

  // Liste des questions jouées
  final List<Question> questions;

  // Réponses sélectionnées par l'utilisateur
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

    // Nombre de réponses correctes
    final correct = selections.asMap().entries.where(
          (e) => e.value != null &&
          e.value == questions[e.key].correctIndex,
    ).length;

    // Nombre de réponses incorrectes
    final wrong = selections.asMap().entries.where(
          (e) => e.value != null &&
          e.value != questions[e.key].correctIndex,
    ).length;

    // Nombre de questions ignorées
    final skipped = selections.where((s) => s == null).length;

    // Pourcentage de réussite
    final percent = ((correct / total) * 100).toInt();

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [

            // En-tête affichant le score
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

            // Carte centrale des résultats
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

                  // Titre de la section
                  Text(
                    "Analyse du quiz",
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  // Cercle animé du pourcentage de réussite
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

                            // Indicateur circulaire
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

                            // Cercle central
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                              ),
                            ),

                            // Texte du pourcentage
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

                  // Statistiques détaillées
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green),
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
                            color: colors.onSurface
                                .withValues(alpha: 0.5),
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

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  // Retour à la page d'accueil
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.main),
                      child: const Text("Retour à l'accueil"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Navigation vers la page des réponses
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
