import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz/providers/router_provider.dart';

import 'core/theme.dart';
import 'core/hive_init.dart';

import 'models/user.dart';
import 'models/user_adapter.dart';

/// Point d’entrée principal de l’application
Future<void> main() async {

  // Assure l’initialisation correcte de Flutter avant tout traitement
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Hive et chargement des questions et de l’historique
  await initHiveAndSeed();

  // Enregistrement de l’adapter User si nécessaire
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(UserAdapter());
  }

  // Ouverture de la box Hive pour les utilisateurs
  await Hive.openBox<User>('users');

  // Affichage du nombre d’utilisateurs chargés (debug)
  debugPrint(
    "DEBUG: users loaded: ${Hive.box<User>('users').length}",
  );

  // Lancement de l’application avec Riverpod
  runApp(const ProviderScope(child: QuizApp()));
}

/// Widget principal de l’application
class QuizApp extends ConsumerWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // Récupération du routeur géré par Riverpod
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Quiz App',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
