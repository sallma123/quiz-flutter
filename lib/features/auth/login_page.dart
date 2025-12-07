import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/app_router.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // pour l'instant navigation directe (à remplacer par Auth logic)
                context.go(AppRoutes.home);
              },
              child: const Text('Se connecter'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.signup),
              child: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
