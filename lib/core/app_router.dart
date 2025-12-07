import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/home/home_page.dart';

// Petite implémentation de base : Splash redirige vers login/home (ici always login)
final router = GoRouter(
  initialLocation: AppRoutes.splash,
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
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple splash qui redirige vers login après 1s
    Future.microtask(() => Future.delayed(const Duration(seconds: 1), () {
      context.go(AppRoutes.login);
    }));
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
