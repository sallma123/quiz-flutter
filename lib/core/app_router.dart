// lib/core/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/home/home_page.dart';

// Router principal
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

/// SplashScreen sécurisé : utiliser initState + vérification `mounted`
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Délai court puis redirection. Toujours vérifier mounted avant d'utiliser context.
    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (!mounted) return; // protège contre l'erreur "deactivated widget"
      // Ici on redirige vers la page de connexion. Plus tard tu peux
      // remplacer la logique par une vérification d'auth (token) et aller vers /home.
      context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
