import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/history_record.dart';
import '../../models/user.dart';

import 'profile_widgets.dart';
import 'profile_sheets.dart';
import 'profile_utils.dart';

/// Page Profil
/// Affiche les informations utilisateur, statistiques, niveau et succès
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Box Hive contenant l'historique des quiz
    final historyBox = Hive.box<HistoryRecord>('history');

    return Scaffold(
      backgroundColor: colors.background,

      // Écoute les changements de l'utilisateur
      body: ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('users').listenable(),
        builder: (context, userBox, _) {

          // Création d’un utilisateur par défaut si aucun n’existe
          if (userBox.values.isEmpty) {
            userBox.add(
              User(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: "Utilisateur",
                email: "utilisateur@quiz.app",
                passwordHash: "",
              ),
            );
          }

          // Récupération de l'utilisateur courant
          final user = userBox.values.first;

          // Récupération de l'historique des quiz
          final history = historyBox.values.toList();

          // Calcul des statistiques globales
          final totalQuiz = history.length;
          final totalScore =
          history.fold<int>(0, (sum, h) => sum + h.score);
          final totalQuestions =
          history.fold<int>(0, (sum, h) => sum + h.totalQuestions);

          // Calcul du pourcentage global de réussite
          final percent = totalQuestions == 0
              ? 0
              : ((totalScore / (totalQuestions * 10)) * 100).round();

          // Détermination du niveau utilisateur selon le score
          int level = 1;
          if (totalScore >= 700) {
            level = 4;
          } else if (totalScore >= 300) {
            level = 3;
          } else if (totalScore >= 100) {
            level = 2;
          }

          // Paliers de score pour chaque niveau
          final levelSteps = [0, 100, 300, 700, 1200];

          // Progression dans le niveau actuel
          final progress = level == 4
              ? 1.0
              : (totalScore - levelSteps[level - 1]) /
              (levelSteps[level] - levelSteps[level - 1]);

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  // En-tête du profil (infos utilisateur + actions)
                  ProfileHeader(
                    user: user,
                    onEditProfile: () =>
                        showEditProfileSheet(context, user),
                    onChangePassword: () =>
                        showChangePasswordSheet(context, user),
                    onLogout: () =>
                        showLogoutDialog(context, ref),
                  ),

                  const SizedBox(height: 16),

                  // Cartes de statistiques principales
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ProfileStatCard(
                          icon: Icons.quiz,
                          label: "Quiz",
                          value: "$totalQuiz",
                        ),
                        ProfileStatCard(
                          icon: Icons.star,
                          label: "Score",
                          value: "$totalScore",
                        ),
                        ProfileStatCard(
                          icon: Icons.trending_up,
                          label: "Réussite",
                          value: "$percent%",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Section du niveau et de la progression
                  ProfileSectionCard(
                    title: "Niveau $level",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          color: colors.secondary,
                          backgroundColor:
                          colors.secondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$totalScore / ${levelSteps[level]} pts",
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Section des succès et badges
                  ProfileSectionCard(
                    title: "Succès",
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedBadge(
                            icon: Icons.flag,
                            active: totalQuiz >= 1,
                            label: "Premier quiz",
                            description:
                            "Compléter votre premier quiz",
                          ),
                        ),
                        Expanded(
                          child: AnimatedBadge(
                            icon: Icons.star,
                            active: totalScore >= 100,
                            label: "100 points",
                            description:
                            "Atteindre un score total de 100 points",
                          ),
                        ),
                        Expanded(
                          child: AnimatedBadge(
                            icon: Icons.whatshot,
                            active: totalQuiz >= 3,
                            label: "Série",
                            description:
                            "Jouer au moins 3 quiz",
                          ),
                        ),
                        Expanded(
                          child: AnimatedBadge(
                            icon: Icons.emoji_events,
                            active: percent >= 80,
                            label: "Expert",
                            description:
                            "Avoir un taux de réussite supérieur à 80%",
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Section d’analyse personnalisée
                  ProfileSectionCard(
                    title: "Analyse personnelle",
                    child: Column(
                      children: [
                        ProfileInsightCard(
                          icon: Icons.check_circle,
                          color: Colors.green,
                          title: "Point fort",
                          message: totalQuiz == 0
                              ? "Aucun point fort détecté pour le moment."
                              : "Bonne régularité dans vos quiz.",
                        ),
                        const SizedBox(height: 12),
                        ProfileInsightCard(
                          icon: Icons.trending_down,
                          color: Colors.orange,
                          title: "À améliorer",
                          message: percent < 50
                              ? "Essayez de revoir vos réponses."
                              : "Continuez à progresser.",
                        ),
                        const SizedBox(height: 12),
                        ProfileInsightCard(
                          icon: Icons.lightbulb,
                          color: Colors.blue,
                          title: "Conseil",
                          message: buildProfileAdvice(
                            totalQuiz: totalQuiz,
                            percent: percent,
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
        },
      ),
    );
  }
}
