// lib/core/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/home/home_page.dart';
import '../features/navigation/main_navigation.dart'; // <-- Assure-toi que ce fichier existe

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
    // Route principale qui contient la BottomNavigationBar
    GoRoute(
      path: AppRoutes.main,
      builder: (context, state) => const MainNavigationPage(),
    ),
    // Optionnel : garder home route si tu as besoin d'un accès direct
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
    Future.delayed(const Duration(milliseconds: 800)).then((_) {
      if (!mounted) return;
      // Par défaut on envoie vers la page de login.
      // Plus tard tu pourras vérifier l'état d'auth et aller vers AppRoutes.main si connecté.
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
