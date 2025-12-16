import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz/providers/router_provider.dart';

import 'core/theme.dart';
import 'core/hive_init.dart';

import 'models/user.dart';
import 'models/user_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 1) Initialiser Hive + seed questions + historique
  await initHiveAndSeed();

  // 🔥 2) Initialisation Hive Users
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(UserAdapter());
  }
  await Hive.openBox<User>('users');

  debugPrint("DEBUG: users loaded: ${Hive.box<User>('users').length}");

  // 🔥 3) Lancer l'app avec Riverpod
  runApp(const ProviderScope(child: QuizApp()));
}

class QuizApp extends ConsumerWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ IMPORTANT : on écoute le routerProvider
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quiz App',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
