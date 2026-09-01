import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/catalog_providers.dart';
import '../../providers/intro_provider.dart';
import '../../theme/tokens.dart';
import '../../widgets/intro/intro_orchestrator.dart';
import 'storefront_screen.dart';

class ShopShell extends ConsumerWidget {
  const ShopShell({super.key, required this.slug, required this.child});

  final String slug;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introPlayed = ref.watch(introFlagProvider);
    final profile = ref.watch(shopProfileProvider(slug)).valueOrNull;
    final name = profile?.shopName ?? 'Whimsical';

    return Scaffold(
      backgroundColor: AppColors.blush,
      body: IntroOrchestrator(
        wordmark: name,
        hasPlayedIntro: introPlayed,
        onIntroComplete: () => ref.read(introFlagProvider.notifier).markPlayed(),
        headerTrailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => context.go('/dashboard'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.plum,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'owner den',
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.plum,
                ),
              ),
            ),
            StorefrontCartButton(slug: slug, shopName: name),
          ],
        ),
        child: child,
      ),
    );
  }
}
