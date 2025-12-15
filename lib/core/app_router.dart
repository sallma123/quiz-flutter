// lib/core/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Routes & pages utilisées
import '../features/home/create_quiz_page.dart';
import '../features/home/quiz_page.dart';
import 'constants.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/home/home_page.dart';
import '../features/navigation/main_navigation.dart';
import '../features/home/result_page.dart';
import '../features/home/answers_page.dart';

final router = GoRouter(
  initialLocation: AppRoutes.splash,
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Page introuvable')),
  ),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainNavigationPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra as Map;

        return ResultPage(
          score: extra['score'],
          total: extra['total'],
          questions: extra['questions'],
          selections: extra['selections'],
        );
      },
    ),
    GoRoute(
      path: '/answers',
      builder: (context, state) {
        final extra = state.extra as Map;

        return AnswersPage(
          questions: extra['questions'],
          selections: extra['selections'],
        );
      },
    ),


    // Route /quiz : on parse state.location pour être compatible toutes versions
   GoRoute(
      path: AppRoutes.quiz,
      builder: (context, state) {
        final uri = Uri.parse(state.location);
        final id = uri.queryParameters['id'] ?? '';
        final title = uri.queryParameters['title'] ?? 'Quiz';
        return QuizPage(categoryId: id, title: title);
      },
    ),

    GoRoute(
      path: AppRoutes.createQuiz,
      builder: (context, state) => const CreateQuizPage(),
    ),
  ],
);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800)).then((_) {
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
