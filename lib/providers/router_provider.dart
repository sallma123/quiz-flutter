import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/navigation/main_navigation.dart';
import '../features/home/home_page.dart';
import '../features/home/create_quiz_page.dart';
import '../features/home/quiz_page.dart';
import '../features/home/result_page.dart';
import '../features/home/answers_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,

    // ============================
    // 🔁 REDIRECTION AUTH
    // ============================
    redirect: (context, state) {
      final isAuthenticated =
          authState.status == AuthStatus.authenticated;

      final isAuthRoute =
          state.location == AppRoutes.login ||
              state.location == AppRoutes.signup;

      // 🚫 NON CONNECTÉ → LOGIN
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // ✅ CONNECTÉ → MAIN
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.main;
      }

      return null; // ✅ PAS DE BOUCLE
    },

    // ============================
    // 📍 ROUTES
    // ============================
    routes: [
      // 🔐 AUTH
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),

      // 🧭 MAIN NAVIGATION
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const MainNavigationPage(),
      ),

      // 🏠 HOME
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),

      // ➕ CREATE QUIZ
      GoRoute(
        path: AppRoutes.createQuiz,
        builder: (_, __) => const CreateQuizPage(),
      ),

      // ❓ QUIZ (via extra)
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final extra = state.extra;

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

      // 🏁 RESULT
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final extra = state.extra;

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

      // 📋 ANSWERS
      GoRoute(
        path: AppRoutes.answers,
        builder: (context, state) {
          final extra = state.extra;

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
