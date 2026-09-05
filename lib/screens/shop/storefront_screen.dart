import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_client.dart';
import '../../models/catalog_sort.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/doodles/dino_mascot.dart';
import '../../widgets/storefront/cart_sheet.dart';
import '../../widgets/storefront/product_grid.dart';
import '../../widgets/ui/atelier_backdrop.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/page_canvas.dart';
import '../../widgets/ui/shop_mark.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_sheet.dart';

class StorefrontScreen extends ConsumerWidget {
  const StorefrontScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(shopProfileProvider(slug));
    final products = ref.watch(publishedProductsProvider(slug));

    final shop = profile.valueOrNull;
    final items = products.valueOrNull;
    void retry() {
      ref.invalidate(shopProfileProvider(slug));
      ref.invalidate(publishedProductsProvider(slug));
    }

    if (products.hasError && items == null) {
      return AtelierBackdrop(
        child: WhimsicalError(message: products.error.toString(), onRetry: retry),
      );
    }
    if (profile.hasError && shop == null && items == null && !products.isLoading) {
      return AtelierBackdrop(
        child: WhimsicalError(message: profile.error.toString(), onRetry: retry),
      );
    }
    if (items == null && (profile.isLoading || products.isLoading)) {
      return const AtelierBackdrop(child: DinoLoading());
    }
    if (shop == null && (items == null || items.isEmpty) && !profile.hasError && !profile.isLoading) {
      return const AtelierBackdrop(
        child: WhimsicalEmpty(
          title: 'This shop is still packing',
          body: 'The link might be a little off — try another slug, or check back after the owner publishes.',
        ),
      );
    }

    final catalog = CatalogSort.parse(shop?.catalogSort).apply(items ?? const []);
    final bio = shop?.bio;
    final headline = shop?.headline?.trim() ?? '';
    return AtelierBackdrop(
      child: _WarmShopImages(
        products: catalog,
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PageCanvas(
              maxWidth: AppLayout.storefrontMax,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (headline.isNotEmpty)
                    Row(
                      children: [
                        ShopMark(
                          logoUrl: shop?.logoUrl,
                          size: 72,
                          fallback: CatPose.strawberry,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            headline,
                            style: AppTypography.displayMedium,
                          ),
                        ),
                      ],
                    ),
                  if (headline.isNotEmpty) const SizedBox(height: 12),
                  Text(
                    (bio != null && bio.isNotEmpty)
                        ? bio
                        : 'Squishy pastel keychains, made-to-order dinos, and little shells you can tap to request.',
                    style: AppTypography.body.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: AppLayout.storefrontMax),
                  child: CreamPanel(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                    child: catalog.isEmpty
                        ? const WhimsicalEmpty(
                            title: 'Restocking the nest',
                            body: 'Nothing is published just yet — check back after the next tiny launch.',
                          )
                        : ProductGrid(slug: slug, products: catalog),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _WarmShopImages extends StatefulWidget {
  const _WarmShopImages({required this.products, required this.child});

  final List<Product> products;
  final Widget child;

  @override
  State<_WarmShopImages> createState() => _WarmShopImagesState();
}

class _WarmShopImagesState extends State<_WarmShopImages> {
  var _warmed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmed) return;
    _warmed = true;
    for (final product in widget.products.take(8)) {
      if (product.imageUrls.isEmpty) continue;
      final url = ApiClient.resolveMedia(product.imageUrls.first);
      if (url.startsWith('http://') || url.startsWith('https://')) {
        precacheImage(NetworkImage(url), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
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
          label: 'Cart',
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
