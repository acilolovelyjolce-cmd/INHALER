import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_badge.dart';
import '../ui/whimsical_button.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  const ProductDetailView({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  var _page = 0;
  var _qty = 1;
  late Map<String, String> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {
      for (final entry in (widget.product.variants ?? {}).entries)
        if (entry.value is List && (entry.value as List).isNotEmpty)
          entry.key: '${(entry.value as List).first}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final sold = product.stockStatus == StockStatus.soldOut;
    final images = product.imageUrls.isEmpty ? <String>[] : product.imageUrls;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              PageView.builder(
                itemCount: images.isEmpty ? 1 : images.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  if (images.isEmpty) {
                    return const DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.cloud,
                        borderRadius: AppRadii.imageBorder,
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: AppRadii.imageBorder,
                    child: ColoredBox(
                      color: AppColors.cloud,
                      child: SmartProductImage(url: images[index]),
                    ),
                  );
                },
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < images.length; i++)
                        Container(
                          width: i == _page ? 16 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: ShapeDecoration(
                            color: i == _page ? AppColors.plum : AppColors.petal,
                            shape: const StadiumBorder(),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        if (sold)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: WhimsicalBadge(label: 'all gone for now'),
            ),
          ),
        Text(product.name, style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(Formatters.php(product.price), style: AppTypography.displaySmall),
            if (product.compareAtPrice != null) ...[
              const SizedBox(width: 10),
              Text(
                Formatters.php(product.compareAtPrice!),
                style: AppTypography.bodySmall.copyWith(decoration: TextDecoration.lineThrough),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Text(product.description, style: AppTypography.body),
        const SizedBox(height: 20),
        for (final entry in (product.variants ?? {}).entries) ...[
          Text(entry.key, style: AppTypography.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in (entry.value is List ? entry.value as List : const []))
                ChoiceChip(
                  label: Text('$option'),
                  selected: _selection[entry.key] == '$option',
                  onSelected: (_) => setState(() => _selection[entry.key] = '$option'),
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            QuantityStepper(value: _qty, onChanged: (v) => setState(() => _qty = v)),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 20),
        WhimsicalButton(
          label: sold ? 'Join the waitlist vibe' : 'Add to request',
          expand: true,
          onPressed: sold
              ? null
              : () {
                  ref.read(cartProvider.notifier).add(
                        CartLine(
                          productId: product.id,
                          productName: product.name,
                          price: product.price,
                          quantity: _qty,
                          imageUrl: product.imageUrls.isEmpty ? null : product.imageUrls.first,
                          variantSelection: _selection,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} added to your request')),
                  );
                },
        ),
      ],
    );
  }
}
