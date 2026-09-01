import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/storefront/product_door_flow.dart';
import '../../widgets/ui/feedback.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.slug, required this.id});

  final String slug;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(publishedProductsProvider(slug));
    return products.when(
      loading: () => const DinoLoading(),
      error: (e, _) => WhimsicalError(
        message: e.toString(),
        onRetry: () => ref.invalidate(publishedProductsProvider(slug)),
      ),
      data: (items) {
        final product = items.where((p) => p.id == id).firstOrNull;
        if (product == null) {
          return WhimsicalEmpty(
            title: 'That charm wandered off',
            body: 'It might be unpublished, or the link is a little stale.',
            action: TextButton(
              onPressed: () => context.go('/shop/$slug'),
              child: const Text('Back to the shop'),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go('/shop/$slug'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.plum,
                    minimumSize: const Size(44, 44),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('All charms'),
                ),
              ),
            ),
            Expanded(child: ProductDoorFlow(product: product)),
          ],
        );
      },
    );
  }
}
