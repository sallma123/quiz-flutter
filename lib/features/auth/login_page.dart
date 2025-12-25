import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import 'auth_controller.dart';

/// Page de connexion de l'application
/// Utilise Riverpod pour la gestion de l'état d'authentification
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {

  // Clé du formulaire pour la validation des champs
  final _formKey = GlobalKey<FormState>();

  // Contrôleur du champ email
  final _emailCtrl = TextEditingController();

  // Contrôleur du champ mot de passe
  final _pwdCtrl = TextEditingController();

  /// Libération de la mémoire quand le widget est détruit
  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  /// Méthode appelée lors du clic sur "Se connecter"
  /// Gère la validation et l'authentification
  void _submit() async {

    // Vérifie si le formulaire est valide
    if (!_formKey.currentState!.validate()) return;

    // Récupère le contrôleur d'authentification
    final notifier = ref.read(authControllerProvider.notifier);

    // Appel de la méthode login
    await notifier.login(
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
    );

    // Lecture de l'état après la tentative de connexion
    final state = ref.read(authControllerProvider);

    // Vérifie que le widget est encore monté
    if (!mounted) return;

    // Si authentification réussie → redirection vers la page principale
    if (state.status == AuthStatus.authenticated) {
      context.go(AppRoutes.main);
    }
    // En cas d'erreur → message d'erreur
    else if (state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // État global de l'authentification
    final authState = ref.watch(authControllerProvider);

    // Couleurs du thème
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [

          // Arrière-plan personnalisé avec effet nuage
          Positioned.fill(
            child: CustomPaint(
              painter: CloudBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 36),

                    // Logo de l'application
                    Image.asset(
                      'assets/logoo.png',
                      height: 130,
                    ),

                    const SizedBox(height: 12),

                    // Petit élément décoratif
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.secondary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Texte d'accueil
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bienvenue, connecte-toi pour continuer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Carte contenant le formulaire de connexion
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            // Champ Email
                            _buildField(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'exemple@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Champ Mot de passe
                            _buildField(
                              controller: _pwdCtrl,
                              label: 'Mot de passe',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),

                            const SizedBox(height: 28),

                            // Bouton de connexion
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF326ED1),
                                      Color(0xFF22C1C3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),

                                  // Désactive le bouton pendant le chargement
                                  onPressed: authState.status == AuthStatus.loading
                                      ? null
                                      : _submit,

                                  // Affiche un loader pendant la connexion
                                  child: authState.status == AuthStatus.loading
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    'Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Lien vers la page d'inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pas encore de compte ? ",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signup),
                          child: const Text(
                            'Créer un compte',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Champ de formulaire réutilisable (email / mot de passe)
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,

      // Validation simple du champ
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Champ requis';
        if (keyboardType == TextInputType.emailAddress && !v.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },

      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF0F8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Painter personnalisé pour dessiner un fond nuageux
class CloudBackgroundPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    // Dégradé de fond
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFDDF4F4),
          Color(0xFFF9FAFB),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // Nuage arrière (léger)
    final backCloud = Paint()..color = Colors.white.withOpacity(0.35);
    final pathBack = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.20, size.width * 0.5, size.height * 0.28)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.36, size.width, size.height * 0.28)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(pathBack, backCloud);

    // Nuage avant (plus visible)
    final frontCloud = Paint()..color = Colors.white.withOpacity(0.7);
    final pathFront = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.35, size.width * 0.5, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.50, size.width, size.height * 0.42)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(pathFront, frontCloud);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
