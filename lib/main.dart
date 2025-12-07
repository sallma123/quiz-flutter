import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/app_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/user.dart';
import 'models/user_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive (base de données locale)
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter()); // enregistré ici
  await Hive.openBox<User>('users');   // box pour stocker les users
  final box = Hive.box<User>('users');
  print('DEBUG: Hive box users opened. count=${box.length}');
  for (final u in box.values) {
    print('DEBUG: user id=${u.id}, name=${u.name}, email=${u.email}, pwdHash=${u.passwordHash}');
  }

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
