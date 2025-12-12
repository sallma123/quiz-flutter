import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user.dart';
import 'models/user_adapter.dart';
import 'core/hive_init.dart'; // ⬅️ AJOUT IMPORTANT

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 1) Initialiser Hive + Questions (notre nouvelle fonction)
  await initHiveAndSeed();

  // 🔥 2) Initialisation Hive existante (Users)
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('users');

  print("DEBUG: users loaded: ${Hive.box<User>('users').length}");

  // Lancement de l'app avec Riverpod
  runApp(const ProviderScope(child: QuizApp()));
}

class QuizApp extends ConsumerWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Quiz App',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
