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

    // =====================
    // USER (création auto si vide)
    // =====================
    final user = userBox.values.isNotEmpty
        ? userBox.values.first
        : () {
      final u = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Utilisateur",
        email: "utilisateur@quiz.app",
        passwordHash: "",
      );
      userBox.add(u);
      return u;
    }();

    final history = historyBox.values.toList();

    // =====================
    // STATS GLOBALES
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

    final levelSteps = [0, 100, 300, 700, 1200];
    final progress = level == 4
        ? 1.0
        : (totalScore - levelSteps[level - 1]) /
        (levelSteps[level] - levelSteps[level - 1]);

    // =====================
    // CATÉGORIES (ANALYSE)
    // =====================
    final Map<String, int> categoryCount = {};
    for (final h in history) {
      categoryCount[h.title] =
          (categoryCount[h.title] ?? 0) + 1;
    }

    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestCategory =
    sortedCategories.isNotEmpty ? sortedCategories.first.key : null;
    final weakCategory =
    sortedCategories.length > 1 ? sortedCategories.last.key : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
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
                    // Avatar avec initiale
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name[0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9C77FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              decoration:
                              const InputDecoration(labelText: "Nom"),
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
                      icon:
                      const Icon(Icons.edit, color: Colors.white),
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
              // NIVEAU
              // =====================
              _SectionCard(
                title: "Niveau $level",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF9C77FF),
                          borderRadius: BorderRadius.circular(10),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "$totalScore / ${levelSteps[level]} pts",
                      style:
                      const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

// =====================
// SUCCÈS / BADGES
// =====================
              _SectionCard(
                title: "Succès",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AnimatedBadge(
                      icon: Icons.flag,
                      active: totalQuiz >= 1,
                      label: "Premier quiz",
                      description: "Compléter votre premier quiz",
                    ),
                    AnimatedBadge(
                      icon: Icons.star,
                      active: totalScore >= 100,
                      label: "100 points",
                      description: "Atteindre un score total de 100 points",
                    ),
                    AnimatedBadge(
                      icon: Icons.whatshot,
                      active: totalQuiz >= 3,
                      label: "Série",
                      description: "Jouer au moins 3 quiz",
                    ),
                    AnimatedBadge(
                      icon: Icons.emoji_events,
                      active: percent >= 80,
                      label: "Expert",
                      description: "Avoir un taux de réussite supérieur à 80%",
                    ),
                  ],
                ),
              ),


// =====================
// ANALYSE PERSONNELLE (MODERNE)
// =====================
              _SectionCard(
                title: "Analyse personnelle",
                child: Column(
                  children: [
                    // POINT FORT
                    _InsightCard(
                      icon: Icons.check_circle,
                      color: Colors.green,
                      title: "Point fort",
                      message: bestCategory != null
                          ? "Tu réussis le mieux dans la catégorie « $bestCategory »."
                          : "Aucun point fort détecté pour le moment.",
                    ),

                    const SizedBox(height: 12),

                    // À AMÉLIORER
                    _InsightCard(
                      icon: Icons.trending_down,
                      color: Colors.orange,
                      title: "À améliorer",
                      message: weakCategory != null
                          ? "La catégorie « $weakCategory » mérite plus d'entraînement."
                          : "Aucune faiblesse détectée pour le moment.",
                    ),

                    const SizedBox(height: 12),

                    // CONSEIL
                    _InsightCard(
                      icon: Icons.lightbulb,
                      color: Colors.blue,
                      title: "Conseil",
                      message: _buildAdvice(
                        totalQuiz: totalQuiz,
                        percent: percent,
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================
// WIDGETS
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
        padding: const EdgeInsets.all(14),
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
              style:
              const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(title,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String label;

  const _Badge(
      {required this.icon, required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    final color =
    active ? const Color(0xFF9C77FF) : Colors.grey;

    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
class AnimatedBadge extends StatefulWidget {
  final IconData icon;
  final bool active;
  final String label;
  final String description;

  const AnimatedBadge({
    super.key,
    required this.icon,
    required this.active,
    required this.label,
    required this.description,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // Lancer l'animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon,
              size: 48,
              color: const Color(0xFF9C77FF),
            ),
            const SizedBox(height: 12),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
    widget.active ? const Color(0xFF9C77FF) : Colors.grey;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onLongPress: () => _showExplanation(context),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(.15),
              child: Icon(widget.icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  const _InsightCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13),
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
// =====================
// CONSEIL PERSONNALISÉ
// =====================
String _buildAdvice({
  required int totalQuiz,
  required int percent,
}) {
  if (totalQuiz == 0) {
    return "Commence par jouer ton premier quiz pour débloquer l'analyse.";
  }

  if (percent >= 80) {
    return "Excellent niveau ! Essaie des catégories plus difficiles.";
  }

  if (percent >= 50) {
    return "Bon travail. Concentre-toi sur tes catégories les plus faibles.";
  }

  return "Prends ton temps, relis les réponses et rejoue régulièrement.";
}

