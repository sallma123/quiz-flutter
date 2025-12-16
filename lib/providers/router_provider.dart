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

      return null; // 🔥 PAS DE BOUCLE
    },

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const MainNavigationPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.createQuiz,
        builder: (_, __) => const CreateQuizPage(),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) {
          final uri = Uri.parse(state.location);
          return QuizPage(
            categoryId: uri.queryParameters['id'] ?? '',
            title: uri.queryParameters['title'] ?? 'Quiz',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultPage(
            score: extra['score'],
            total: extra['total'],
            questions: extra['questions'],
            selections: extra['selections'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.answers,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return AnswersPage(
            questions: extra['questions'],
            selections: extra['selections'],
          );
        },
      ),
    ],
  );
});
