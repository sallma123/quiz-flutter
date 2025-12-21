import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import 'auth_controller.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.signup(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _pwdCtrl.text,
    );

    final state = ref.read(authControllerProvider);
    if (!mounted) return;

    if (state.status == AuthStatus.authenticated) {
      context.go(AppRoutes.home);
    } else if (state.status == AuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage ?? 'Erreur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // 🌥️ BACKGROUND NUAGEUX (même que login)
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

                    // 🧠 LOGO
                    Image.asset(
                      'assets/logoo.png',
                      height: 130,
                    ),

                    const SizedBox(height: 12),

                    // ➖ TIRET DÉCORATIF
                    Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.secondary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📝 TEXTE DISCRET
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

                    // 📦 CARD FORMULAIRE
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
                            _buildField(
                              controller: _nameCtrl,
                              label: 'Nom',
                              hint: 'Ton nom',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _emailCtrl,
                              label: 'Email',
                              hint: 'exemple@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _pwdCtrl,
                              label: 'Mot de passe',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscure: true,
                            ),
                            const SizedBox(height: 28),

                            // 🔵 BOUTON PREMIUM (dégradé)
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
                                  onPressed: authState.status ==
                                      AuthStatus.loading
                                      ? null
                                      : _submit,
                                  child: authState.status ==
                                      AuthStatus.loading
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

                    // 🔗 LOGIN
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

/// 🌥️ PAINTER DES NUAGES (IDENTIQUE AU LOGIN)
class CloudBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
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

    final backCloud = Paint()..color = Colors.white.withOpacity(0.35);
    final pathBack = Path()
      ..moveTo(0, size.height * 0.28)
      ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.20,
          size.width * 0.5,
          size.height * 0.28)
      ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.36,
          size.width,
          size.height * 0.28)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(pathBack, backCloud);

    final frontCloud = Paint()..color = Colors.white.withOpacity(0.7);
    final pathFront = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.35,
          size.width * 0.5,
          size.height * 0.42)
      ..quadraticBezierTo(
          size.width * 0.75,
          size.height * 0.50,
          size.width,
          size.height * 0.42)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(pathFront, frontCloud);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
