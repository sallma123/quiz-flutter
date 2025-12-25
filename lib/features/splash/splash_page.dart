import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page Splash
/// Affiche le logo au démarrage de l'application avec une animation douce
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  // Contrôleur de l'animation
  late AnimationController _controller;

  // Animation de fondu (fade)
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Initialisation du contrôleur d'animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Animation avec une courbe douce
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Lancement de l'animation
    _controller.forward();

    // Délai avant la navigation vers la page de connexion
    Timer(const Duration(milliseconds: 1000), () {
      context.go('/login');
    });
  }

  @override
  void dispose() {
    // Libération des ressources de l'animation
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDF4F4),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Logo de l'application
              Image.asset(
                'assets/logoo.png',
                width: 220,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
