import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../auth/auth_controller.dart';
import 'profile_utils.dart';

/// =====================
/// LOGOUT DIALOG
/// =====================
void showLogoutDialog(BuildContext context, WidgetRef ref) {
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
          onPressed: () {
            Navigator.pop(context);
            ref.read(authControllerProvider.notifier).logout();
          },
          child: const Text("Déconnexion"),
        ),
      ],
    ),
  );
}

/// =====================
/// EDIT PROFILE SHEET
/// =====================
void showEditProfileSheet(BuildContext context, User user) {
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
                _sheetHandle(),
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
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    user.name = nameCtrl.text.trim();
                    user.email = emailCtrl.text.trim();
                    user.save();
                    Navigator.pop(context);
                  },
                  child: const Text("Enregistrer"),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// =====================
/// CHANGE PASSWORD SHEET
/// =====================
void showChangePasswordSheet(BuildContext context, User user) {
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
                  bottom:
                  MediaQuery.of(context).viewInsets.bottom + 20,
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
                    _sheetHandle(),
                    const Text(
                      "Changer le mot de passe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _passwordField(
                      controller: oldCtrl,
                      label: "Ancien mot de passe",
                      show: showOld,
                      onToggle: () =>
                          setState(() => showOld = !showOld),
                    ),

                    const SizedBox(height: 16),

                    _passwordField(
                      controller: newCtrl,
                      label: "Nouveau mot de passe",
                      show: showNew,
                      onToggle: () =>
                          setState(() => showNew = !showNew),
                    ),

                    const SizedBox(height: 16),

                    _passwordField(
                      controller: confirmCtrl,
                      label: "Confirmer le mot de passe",
                      show: showConfirm,
                      onToggle: () =>
                          setState(() => showConfirm = !showConfirm),
                    ),

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        final oldHashed =
                        hashPassword(oldCtrl.text, user.id);

                        if (oldHashed != user.passwordHash) {
                          showProfileSnack(
                            context,
                            "Ancien mot de passe incorrect",
                          );
                          return;
                        }

                        if (newCtrl.text.length < 6) {
                          showProfileSnack(
                            context,
                            "Mot de passe trop court",
                          );
                          return;
                        }

                        if (newCtrl.text != confirmCtrl.text) {
                          showProfileSnack(
                            context,
                            "Les mots de passe ne correspondent pas",
                          );
                          return;
                        }

                        user.passwordHash =
                            hashPassword(newCtrl.text, user.id);
                        user.save();

                        Navigator.pop(context);
                        showProfileSnack(
                          context,
                          "Mot de passe mis à jour",
                        );
                      },
                      child: const Text("Mettre à jour"),
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

/// =====================
/// SHEET HANDLE
/// =====================
Widget _sheetHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

/// =====================
/// PASSWORD FIELD
/// =====================
Widget _passwordField({
  required TextEditingController controller,
  required String label,
  required bool show,
  required VoidCallback onToggle,
}) {
  return TextField(
    controller: controller,
    obscureText: !show,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(show ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
    ),
  );
}
