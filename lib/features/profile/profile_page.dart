import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../models/history_record.dart';
import '../../models/user.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyBox = Hive.box<HistoryRecord>('history');
    final userBox = Hive.box<User>('users');

    final user = userBox.values.isNotEmpty
        ? userBox.values.first
        : () {
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Utilisateur",
        email: "utilisateur@quiz.app",
        passwordHash: "",
      );
      userBox.add(newUser);
      return newUser;
    }();


    final history = historyBox.values.toList();

    // =====================
    // CALCULS STATS
    // =====================
    final totalQuiz = history.length;
    final totalScore =
    history.fold<int>(0, (sum, h) => sum + h.score);
    final totalQuestions =
    history.fold<int>(0, (sum, h) => sum + h.totalQuestions);

    final percent = totalQuestions == 0
        ? 0
        : ((totalScore / (totalQuestions * 10)) * 100).round();

    // =====================
    // NIVEAU
    // =====================
    int level = 1;
    if (totalScore >= 700) {
      level = 4;
    } else if (totalScore >= 300) {
      level = 3;
    } else if (totalScore >= 100) {
      level = 2;
    }

    final nextLevelScore = [0, 100, 300, 700, 1200];
    final progress = level == 4
        ? 1.0
        : (totalScore - nextLevelScore[level - 1]) /
        (nextLevelScore[level] - nextLevelScore[level - 1]);

    // =====================
    // CATÉGORIES FAVORITES
    // =====================
    final Map<String, int> categoryCount = {};
    for (final h in history) {
      categoryCount[h.title] =
          (categoryCount[h.title] ?? 0) + 1;
    }

    final favoriteCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // HEADER PROFIL
            // =====================
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
                  // Avatar
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Nom
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Modifier profil
                  TextButton.icon(
                    onPressed: () async {
                      final controller =
                      TextEditingController(text: user.name);

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Modifier le profil"),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: "Nom",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text("Annuler"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                user.name = controller.text;
                                user.save();
                                Navigator.pop(context);
                              },
                              child: const Text("Enregistrer"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Modifier le profil",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // STATS
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard("Quiz", totalQuiz.toString(), Icons.quiz),
                  _StatCard(
                      "Score", "$totalScore pts", Icons.star),
                  _StatCard(
                      "Réussite", "$percent%", Icons.trending_up),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // PROGRESSION
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Niveau $level",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFF9C77FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =====================
            // CATÉGORIES FAVORITES
            // =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: favoriteCategories.isEmpty
                      ? [
                    const Chip(
                      label: Text("Aucune donnée"),
                    )
                  ]
                      : favoriteCategories.take(3).map((e) {
                    return Chip(
                      label: Text(e.key),
                      backgroundColor:
                      const Color(0xFF9C77FF)
                          .withOpacity(.15),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// WIDGET STAT
// =====================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF9C77FF)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
