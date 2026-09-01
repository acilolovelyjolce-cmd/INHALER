import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/env.dart';
import '../../config/validators.dart';
import '../../providers/auth_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/doodles/dino_mascot.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit({bool preview = false}) async {
    if (!preview && !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).signIn(
            preview ? 'preview@whimsical.local' : _email.text.trim(),
            preview ? 'preview' : _password.text,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = 'Could not sign in. Check your email and password.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const DinoMascot(size: 92),
                    const SizedBox(height: 12),
                    Text('Welcome back', style: AppTypography.displayMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Add products on this phone, then share your shop link. Customers browse in their browser.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    WhimsicalTextField(
                      controller: _email,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 14),
                    WhimsicalTextField(
                      controller: _password,
                      label: 'Password',
                      obscureText: true,
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.password],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.cancelled)),
                    ],
                    const SizedBox(height: 22),
                    WhimsicalButton(
                      label: 'Sign in',
                      expand: true,
                      busy: _busy,
                      onPressed: _submit,
                    ),
                    if (AppConfig.useDemo) ...[
                      const SizedBox(height: 12),
                      WhimsicalButton(
                        label: 'Preview dashboard',
                        kind: WhimsicalButtonKind.ghost,
                        expand: true,
                        onPressed: () => _submit(preview: true),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Debug preview uses local sample data. Point API_URL at the Dart server to use MongoDB Atlas.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
