import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/storefront/cart_sheet.dart';
import '../../widgets/storefront/product_grid.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_sheet.dart';

class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(shopProfileProvider(slug));
    final products = ref.watch(publishedProductsProvider(slug));

    return profile.when(
      loading: () => const DinoLoading(),
      error: (e, _) => WhimsicalError(message: e.toString()),
      data: (shop) {
        if (shop == null) {
          return const WhimsicalEmpty(
            title: 'This shop is still packing',
            body: 'The link might be a little off — try another slug, or check back after the owner publishes.',
          );
        }

        return products.when(
          loading: () => const DinoLoading(),
          error: (e, _) => WhimsicalError(message: e.toString()),
          data: (items) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 28, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (shop.bio != null && shop.bio!.isNotEmpty)
                          Text(shop.bio!, style: AppTypography.body),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  sliver: SliverToBoxAdapter(
                    child: items.isEmpty
                        ? const WhimsicalEmpty(
                            title: 'Restocking the nest',
                            body: 'Nothing is published just yet — check back after the next tiny launch.',
                          )
                        : ProductGrid(slug: slug, products: items),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class StorefrontCartButton extends ConsumerWidget {
  const StorefrontCartButton({super.key, required this.slug, required this.shopName});

  final String slug;
  final String shopName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartProvider).fold<int>(0, (s, l) => s + l.quantity);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        WhimsicalButton(
          label: 'Request',
          kind: WhimsicalButtonKind.petal,
          onPressed: () => showWhimsicalSheet(
            context: context,
            builder: (_) => CartSheet(slug: slug, shopName: shopName),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -6,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.yolk,
              child: Text('$count', style: AppTypography.label.copyWith(fontSize: 10)),
            ),
          ),
      ],
    );
  }
}
