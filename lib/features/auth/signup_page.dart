import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import 'auth_controller.dart';
import 'package:go_router/go_router.dart';

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
    await notifier.signup(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), password: _pwdCtrl.text);
    final state = ref.read(authControllerProvider);
    if (state.status == AuthStatus.authenticated) {
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
                Text('Inscription', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildRoundedField(controller: _nameCtrl, label: 'Nom'),
                      const SizedBox(height: 12),
                      _buildRoundedField(controller: _emailCtrl, label: 'Email', keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildRoundedField(controller: _pwdCtrl, label: 'Mot de passe', obscure: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: authState.status == AuthStatus.loading ? null : _submit,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A19C)),
                          child: authState.status == AuthStatus.loading ? const CircularProgressIndicator(color: Colors.white) : const Text('S\'inscrire'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(child: Text("Tu as déjà un compte ?", style: TextStyle(color: Colors.grey[700]))),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Se connecter', style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
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
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Champ requis';
        if (!obscure && keyboardType == TextInputType.emailAddress && !v.contains('@')) return 'Email invalide';
        if (obscure && v.length < 6) return 'Mot de passe min 6 caractères';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00A19C))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00A19C))),
      ),
    );
  }
}
