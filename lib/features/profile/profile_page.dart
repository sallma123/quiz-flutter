import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Nom : ${auth.name}", style: const TextStyle(fontSize: 18)),
            Text("Email : ${auth.email}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Se déconnecter"),
            ),
          ],
        ),
      ),
    );
  }
}
