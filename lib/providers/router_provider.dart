import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/navigation/main_navigation.dart';
import '../features/home/home_page.dart';
import '../features/home/quiz_page.dart';
import '../features/home/result_page.dart';
import '../features/home/answers_page.dart';
import '../features/splash/splash_page.dart';

/// Provider du routeur de l’application
/// Gère la navigation et la redirection selon l’état d’authentification
final routerProvider = Provider<GoRouter>((ref) {

  // État actuel de l’authentification
  final authState = ref.watch(authControllerProvider);

  return GoRouter(

    // Page affichée au démarrage de l’application
    initialLocation: AppRoutes.splash,

    /// Logique de redirection automatique
    /// Empêche l’accès aux pages protégées sans connexion
    redirect: (context, state) {

      // Vérifie si l’utilisateur est connecté
      final isAuthenticated =
          authState.status == AuthStatus.authenticated;

      // Vérifie si la route est liée à l’authentification
      final isAuthRoute =
          state.location == AppRoutes.login ||
              state.location == AppRoutes.signup;

      // Vérifie si la route actuelle est la Splash
      final isSplash = state.location == AppRoutes.splash;

      // La Splash est toujours accessible
      if (isSplash) return null;

      // Utilisateur non connecté → redirection vers login
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Utilisateur connecté → accès direct à la page principale
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.main;
      }

      // Aucune redirection nécessaire
      return null;
    },

    /// Définition de toutes les routes de l’application
    routes: [

      // Page Splash affichée au lancement
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashPage(),
      ),

      // Pages d’authentification
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),

      // Navigation principale (Bottom Navigation)
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const MainNavigationPage(),
      ),

      // Page d’accueil
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),

      // Page du quiz
      // Les informations sont transmises via "extra"
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final extra = state.extra;

          // Vérification de sécurité
          if (extra == null || extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(
                child: Text("Erreur : données du quiz manquantes"),
              ),
            );
          }

          return QuizPage(
            categoryId: extra['categoryId'] as String,
            title: extra['title'] as String,
          );
        },
      ),

      // Page des résultats du quiz
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final extra = state.extra;

          // Vérification des données reçues
          if (extra == null || extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(
                child: Text("Erreur : résultat introuvable"),
              ),
            );
          }

          return ResultPage(
            score: extra['score'] as int,
            total: extra['total'] as int,
            questions: extra['questions'],
            selections: extra['selections'],
          );
        },
      ),

      // Page d’affichage des réponses
      GoRoute(
        path: AppRoutes.answers,
        builder: (context, state) {
          final extra = state.extra;

          // Vérification des données reçues
          if (extra == null || extra is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(
                child: Text("Erreur : réponses introuvables"),
              ),
            );
          }

          return AnswersPage(
            questions: extra['questions'],
            selections: extra['selections'],
          );
        },
      ),
    ],
  );
});
