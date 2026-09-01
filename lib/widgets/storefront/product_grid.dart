import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/formatters.dart';
import '../../models/product.dart';
import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_badge.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.slug,
    required this.products,
  });

  final String slug;
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Product>>{};
    for (final product in products) {
      grouped.putIfAbsent(product.category, () => []).add(product);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= Breakpoints.medium
            ? 3
            : width >= 520
                ? 2
                : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 14),
                child: Text(entry.key, style: AppTypography.displaySmall),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                clipBehavior: Clip.none,
                itemCount: entry.value.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: cols >= 3 ? 0.76 : 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = entry.value[index];
                  return _ProductTile(
                    product: product,
                    onTap: () => context.go('/shop/$slug/product/${product.id}'),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sold = product.stockStatus == StockStatus.soldOut;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: sold ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 6, 8),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: stickerFill(color: AppColors.cloud, radius: AppRadii.image),
                      child: ClipRRect(
                        borderRadius: AppRadii.imageBorder,
                        child: product.imageUrls.isEmpty
                            ? const ColoredBox(color: AppColors.sky)
                            : Transform.translate(
                                offset: const Offset(0, 8),
                                child: SmartProductImage(url: product.imageUrls.first),
                              ),
                      ),
                    ),
                  ),
                  if (sold)
                    const Positioned(
                      left: 10,
                      bottom: 10,
                      child: WhimsicalBadge(label: 'all gone for now'),
                    ),
                  if (product.stockStatus == StockStatus.madeToOrder)
                    const Positioned(
                      left: 10,
                      bottom: 10,
                      child: WhimsicalBadge(label: 'made to order', color: AppColors.meadow),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(Formatters.php(product.price), style: AppTypography.price),
                if (product.compareAtPrice != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    Formatters.php(product.compareAtPrice!),
                    style: AppTypography.bodySmall.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
