import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../auth/auth_controller.dart';
import 'profile_utils.dart';

/// Affiche une boîte de dialogue de confirmation de déconnexion
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

/// Affiche une feuille modale pour modifier les informations du profil
void showEditProfileSheet(BuildContext context, User user) {

  // Contrôleurs des champs nom et email
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

                // Poignée visuelle de la feuille
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

                // Champ nom
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                const SizedBox(height: 16),

                // Champ email
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton de sauvegarde
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

/// Affiche une feuille modale pour changer le mot de passe
void showChangePasswordSheet(BuildContext context, User user) {

  // Contrôleurs des champs mot de passe
  final oldCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  // États pour afficher ou masquer les mots de passe
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

                    // Poignée visuelle
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

                    // Champ ancien mot de passe
                    _passwordField(
                      controller: oldCtrl,
                      label: "Ancien mot de passe",
                      show: showOld,
                      onToggle: () =>
                          setState(() => showOld = !showOld),
                    ),

                    const SizedBox(height: 16),

                    // Champ nouveau mot de passe
                    _passwordField(
                      controller: newCtrl,
                      label: "Nouveau mot de passe",
                      show: showNew,
                      onToggle: () =>
                          setState(() => showNew = !showNew),
                    ),

                    const SizedBox(height: 16),

                    // Champ confirmation du mot de passe
                    _passwordField(
                      controller: confirmCtrl,
                      label: "Confirmer le mot de passe",
                      show: showConfirm,
                      onToggle: () =>
                          setState(() => showConfirm = !showConfirm),
                    ),

                    const SizedBox(height: 30),

                    // Bouton de mise à jour du mot de passe
                    ElevatedButton(
                      onPressed: () {

                        // Vérification de l'ancien mot de passe
                        final oldHashed =
                        hashPassword(oldCtrl.text, user.id);

                        if (oldHashed != user.passwordHash) {
                          showProfileSnack(
                            context,
                            "Ancien mot de passe incorrect",
                          );
                          return;
                        }

                        // Vérification de la longueur du nouveau mot de passe
                        if (newCtrl.text.length < 6) {
                          showProfileSnack(
                            context,
                            "Mot de passe trop court",
                          );
                          return;
                        }

                        // Vérification de la confirmation
                        if (newCtrl.text != confirmCtrl.text) {
                          showProfileSnack(
                            context,
                            "Les mots de passe ne correspondent pas",
                          );
                          return;
                        }

                        // Mise à jour du mot de passe
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

/// Widget visuel indiquant que la feuille peut être glissée
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

/// Champ de saisie de mot de passe avec option afficher / masquer
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
