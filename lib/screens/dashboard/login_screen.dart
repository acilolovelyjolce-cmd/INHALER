import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/env.dart';
import '../../config/validators.dart';
import '../../providers/auth_provider.dart';
import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';
import '../../widgets/doodles/dino_mascot.dart';
import '../../widgets/ui/atelier_backdrop.dart';
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
    final wide = Breakpoints.isExpanded(context);

    final form = CreamPanel(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!wide) ...[
              const Center(child: FluffyCat(pose: CatPose.owner, size: 92)),
              const SizedBox(height: 12),
            ],
            Text('psst, owner', style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Squeeze in, add charms, and send your shop link to the humans.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 28),
            WhimsicalTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            WhimsicalTextField(
              controller: _password,
              label: 'Password',
              obscureText: true,
              validator: Validators.password,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.cancelled)),
            ],
            const SizedBox(height: 24),
            WhimsicalButton(
              label: 'hop in',
              expand: true,
              busy: _busy,
              onPressed: _submit,
            ),
            if (AppConfig.useDemo) ...[
              const SizedBox(height: 12),
              WhimsicalButton(
                label: 'Preview with sample data',
                kind: WhimsicalButtonKind.ghost,
                expand: true,
                onPressed: () => _submit(preview: true),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/shop/whimsical'),
              child: const Text('back to the public shop'),
            ),
          ],
        ),
      ),
    );

    final story = Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 36, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FluffyCat(pose: CatPose.owner, size: 120),
          const SizedBox(height: 20),
          Text('Whimsical', style: AppTypography.displayLarge.copyWith(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'The squishiest back pocket for your charm shop. Catalog, requests, and a link that lives on your phone.',
            style: AppTypography.body.copyWith(height: 1.55),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: AtelierBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppLayout.loginMax),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: story),
                          const SizedBox(width: 28),
                          Expanded(child: form),
                        ],
                      )
                    : form,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
