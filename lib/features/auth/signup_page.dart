import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import 'auth_controller.dart';

/// Page d'inscription de l'application
/// Permet à un nouvel utilisateur de créer un compte
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {

  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();

  // Contrôleur du champ nom
  final _nameCtrl = TextEditingController();

  // Contrôleur du champ email
  final _emailCtrl = TextEditingController();

  // Contrôleur du champ mot de passe
  final _pwdCtrl = TextEditingController();

  /// Libère les ressources quand la page est détruite
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  /// Méthode appelée lors du clic sur "S'inscrire"
  /// Gère la validation et la création du compte
  Future<void> _submit() async {

    // Vérifie si le formulaire est valide
    if (!_formKey.currentState!.validate()) return;

    // Récupère le contrôleur d'authentification
    final notifier = ref.read(authControllerProvider.notifier);

    // Appel de la méthode signup
    await notifier.signup(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
    );

    // Lecture de l'état après l'inscription
    final state = ref.read(authControllerProvider);

    // Vérifie que le widget est encore monté
    if (!mounted) return;

    // Si inscription réussie → redirection vers la page d'accueil
    if (state.status == AuthStatus.authenticated) {
      context.go(AppRoutes.home);
    }
    // En cas d'erreur → affichage d'un message
    else if (state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    // État actuel de l'authentification
    final authState = ref.watch(authControllerProvider);

    // Couleurs du thème de l'application
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

                    // Élément décoratif sous le logo
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.secondary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Texte d'information
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Créer un compte pour commencer',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Carte contenant le formulaire d'inscription
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

                            // Champ Nom
                            _buildField(
                              controller: _nameCtrl,
                              label: 'Nom',
                              hint: 'Ton nom',
                              icon: Icons.person_outline,
                            ),

                            const SizedBox(height: 16),

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

                            // Bouton d'inscription avec dégradé
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

                                  // Affiche un loader pendant l'inscription
                                  child: authState.status == AuthStatus.loading
                                      ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    "S'inscrire",
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

                    // Lien vers la page de connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Tu as déjà un compte ? ",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text(
                            'Se connecter',
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

  /// Champ de formulaire réutilisable (nom, email, mot de passe)
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

      // Validation des champs
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Champ requis';
        if (keyboardType == TextInputType.emailAddress && !v.contains('@')) {
          return 'Email invalide';
        }
        if (obscure && v.length < 6) {
          return 'Mot de passe min 6 caractères';
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
/// Identique à celui utilisé dans la page Login
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

    // Nuage arrière
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

    // Nuage avant
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
