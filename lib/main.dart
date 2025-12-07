import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive (base de données locale)
  await Hive.initFlutter();

  // Lancement de l'app avec Riverpod (state management)
  runApp(const ProviderScope(child: QuizApp()));
}

class QuizApp extends ConsumerWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Quiz App',
      theme: appTheme,           // <- notre thème personnalisé
      routerConfig: router,      // <- navigation GoRouter
      debugShowCheckedModeBanner: false,
    );
  }
}
