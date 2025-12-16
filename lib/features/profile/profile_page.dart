import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/adapters.dart';

import '../../models/history_record.dart';
import '../../models/user.dart';
import '../../core/constants.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import '../auth/auth_controller.dart';

String hashPassword(String password, String userId) {
  final bytes = utf8.encode(userId + password); // ⚠️ même logique que AuthRepository
  return sha256.convert(bytes).toString();
}


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyBox = Hive.box<HistoryRecord>('history');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: ValueListenableBuilder<Box<User>>(
        valueListenable: Hive.box<User>('users').listenable(),
        builder: (context, userBox, _) {
          // =====================
          // USER (obligatoirement existant)
          // =====================
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

          final user = userBox.values.first;
          final history = historyBox.values.toList();

          // =====================
          // STATS
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
          // LEVEL
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

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // =====================
                  // HEADER
                  // =====================
                  Stack(
                    children: [
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
                            const SizedBox(height: 8),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // MODIFIER PROFIL
                            TextButton.icon(
                              onPressed: () =>
                                  _showEditProfileSheet(context, user),
                              icon:
                              const Icon(Icons.edit, color: Colors.white),
                              label: const Text(
                                "Modifier le profil",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                            // CHANGER MOT DE PASSE
                            TextButton.icon(
                              onPressed: () =>
                                  _showChangePasswordSheet(context, user),
                              icon:
                              const Icon(Icons.lock, color: Colors.white),
                              label: const Text(
                                "Changer le mot de passe",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LOGOUT
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.logout),
                          color: Colors.white,
                          onPressed: () => _showLogoutDialog(context, ref),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // STATS
                  // =====================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _StatCard("Quiz", "$totalQuiz", Icons.quiz),
                        _StatCard(
                            "Score", "$totalScore pts", Icons.star),
                        _StatCard(
                            "Réussite", "$percent%", Icons.trending_up),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================
                  // LEVEL
                  // =====================
                  _SectionCard(
                    title: "Niveau $level",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF9C77FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "$totalScore / ${levelSteps[level]} pts",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}

// =====================
// HELPERS & WIDGETS
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
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12)),
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
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// =====================
// LOGOUT
// =====================
void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Déconnexion"),
      content: const Text("Voulez-vous vraiment vous déconnecter ?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);

            // 🔥 LOGOUT CENTRALISÉ
            ref.read(authControllerProvider.notifier).logout();
          },
          child: const Text("Déconnexion"),
        ),
      ],
    ),
  );
}


// =====================
// EDIT PROFILE
// =====================
void _showEditProfileSheet(BuildContext context, User user) {
  final nameCtrl = TextEditingController(text: user.name);
  final emailCtrl = TextEditingController(text: user.email);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: ListView(
              controller: scrollController,
              children: [
                // ===== HANDLE
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const Text(
                  "Modifier le profil",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      user.name = nameCtrl.text.trim();
                      user.email = emailCtrl.text.trim();
                      user.save();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Enregistrer"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
void _showChangePasswordSheet(BuildContext context, User user) {
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.45,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // HANDLE
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const Text(
                      "Changer le mot de passe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ANCIEN MOT DE PASSE
                    TextField(
                      controller: oldCtrl,
                      obscureText: !showOld,
                      decoration: InputDecoration(
                        labelText: "Ancien mot de passe",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showOld
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => showOld = !showOld),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NOUVEAU MOT DE PASSE
                    TextField(
                      controller: newCtrl,
                      obscureText: !showNew,
                      decoration: InputDecoration(
                        labelText: "Nouveau mot de passe",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => showNew = !showNew),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONFIRMATION
                    TextField(
                      controller: confirmCtrl,
                      obscureText: !showConfirm,
                      decoration: InputDecoration(
                        labelText: "Confirmer le mot de passe",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => showConfirm = !showConfirm),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BOUTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 1️⃣ Vérifier ancien mot de passe (HASHÉ)
                          final oldHashed =
                          hashPassword(oldCtrl.text, user.id);

                          if (oldHashed != user.passwordHash) {
                            _showSnack(
                              context,
                              "Ancien mot de passe incorrect",
                            );
                            return;
                          }

                          // 2️⃣ Vérifier nouveau mot de passe
                          if (newCtrl.text.length < 6) {
                            _showSnack(
                              context,
                              "Le mot de passe doit contenir au moins 6 caractères",
                            );
                            return;
                          }

                          if (newCtrl.text != confirmCtrl.text) {
                            _showSnack(
                              context,
                              "Les mots de passe ne correspondent pas",
                            );
                            return;
                          }

                          // 3️⃣ Sauvegarde HASHÉE
                          user.passwordHash =
                              hashPassword(newCtrl.text, user.id);
                          user.save();

                          Navigator.pop(context);
                          _showSnack(
                            context,
                            "Mot de passe mis à jour avec succès",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Mettre à jour"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}


void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}

