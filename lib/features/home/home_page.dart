import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.startQuiz),
              child: const Text('Start Quiz (vide pour l\'instant)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.createQuiz),
              child: const Text('Create Quiz (vide pour l\'instant)'),
            ),
          ],
        ),
      ),
    );
  }
}
