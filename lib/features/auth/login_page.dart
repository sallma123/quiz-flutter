import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import 'auth_controller.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authControllerProvider.notifier);
    await notifier.login(email: _emailCtrl.text.trim(), password: _pwdCtrl.text);
    final state = ref.read(authControllerProvider);
    if (state.status == AuthStatus.authenticated) {
      // rediriger vers home
      if (!mounted) return;
      context.go(AppRoutes.home);
    } else if (state.status == AuthStatus.error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Erreur')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Connexion', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildRoundedField(controller: _emailCtrl, label: 'Email', hint: 'ton@exemple.com', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildRoundedField(controller: _pwdCtrl, label: 'Mot de passe', hint: '••••••', obscure: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading ? null : _submit,
                          child: authState.status == AuthStatus.loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Se connecter'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text("Si tu n'as pas de compte, crée-le :", style: TextStyle(color: Colors.grey[700]))),
                TextButton(
                  onPressed: () => context.go(AppRoutes.signup),
                  child: const Text('Créer un compte', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Champ requis';
        if (!obscure && keyboardType == TextInputType.emailAddress && !v.contains('@')) return 'Email invalide';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00C853))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00C853))),
      ),
    );
  }
}
