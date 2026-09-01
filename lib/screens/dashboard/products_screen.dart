import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../config/validators.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/dashboard/product_form_sheet.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_badge.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_sheet.dart';
import '../../widgets/ui/whimsical_text_field.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(ownerProductsProvider);

    return catalog.when(
      loading: () => const DinoLoading(),
      error: (e, _) => WhimsicalError(
        message: e.toString(),
        onRetry: () => ref.invalidate(ownerProductsProvider),
      ),
      data: (products) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                children: [
                  Expanded(child: Text('Catalog', style: AppTypography.displayMedium)),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'bulk') _bulk(context, ref, products);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'bulk', child: Text('Bulk price adjust')),
                    ],
                  ),
                  WhimsicalButton(
                    label: 'Add product',
                    icon: Icons.add,
                    onPressed: () => showWhimsicalSheet(
                      context: context,
                      builder: (_) => const ProductFormSheet(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? const WhimsicalEmpty(
                      title: 'No charms yet',
                      body: 'Add your first inhaler keychain and it will bloom on the public link.',
                    )
                  : ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: products.length,
                      onReorder: (oldIndex, newIndex) async {
                        var nextIndex = newIndex;
                        if (nextIndex > oldIndex) nextIndex--;
                        final next = [...products];
                        final item = next.removeAt(oldIndex);
                        next.insert(nextIndex, item);
                        await ref.read(productsRepositoryProvider).reorder(next);
                      },
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _ProductRow(
                          key: ValueKey(product.id),
                          index: index,
                          product: product,
                          onEdit: () => showWhimsicalSheet(
                            context: context,
                            builder: (_) => ProductFormSheet(existing: product),
                          ),
                          onDuplicate: () =>
                              ref.read(productsRepositoryProvider).duplicate(product),
                          onToggle: (v) => ref.read(productsRepositoryProvider).upsert(
                                product.copyWith(isPublished: v, updatedAt: DateTime.now()),
                              ),
                          onDelete: () =>
                              ref.read(productsRepositoryProvider).delete(product.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bulk(BuildContext context, WidgetRef ref, List<Product> products) async {
    final categories = products.map((p) => p.category).toSet().toList();
    if (categories.isEmpty) return;
    var category = categories.first;
    var percent = true;
    final amount = TextEditingController(text: '10');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust prices'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: category,
                    isExpanded: true,
                    items: [
                      for (final c in categories) DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setState(() => category = v ?? category),
                  ),
                  SwitchListTile(
                    title: Text(percent ? 'Percent' : 'Flat ₱'),
                    value: percent,
                    onChanged: (v) => setState(() => percent = v),
                  ),
                  WhimsicalTextField(
                    controller: amount,
                    label: percent ? 'Percent' : 'Amount',
                    validator: Validators.price,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apply')),
              ],
            );
          },
        );
      },
    );
    if (ok == true) {
      await ref.read(productsRepositoryProvider).bulkAdjustPrice(
            category: category,
            percent: percent,
            amount: double.tryParse(amount.text) ?? 0,
          );
    }
    amount.dispose();
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    super.key,
    required this.index,
    required this.product,
    required this.onEdit,
    required this.onDuplicate,
    required this.onToggle,
    required this.onDelete,
  });

  final int index;
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (product.stockStatus) {
      StockStatus.available => AppColors.meadow,
      StockStatus.madeToOrder => AppColors.yolk,
      StockStatus.soldOut => AppColors.petal,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cloud,
        borderRadius: AppRadii.cardBorder,
        child: InkWell(
          onTap: onEdit,
          onLongPress: onDuplicate,
          borderRadius: AppRadii.cardBorder,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 64,
                    height: 72,
                    child: product.imageUrls.isEmpty
                        ? const ColoredBox(color: AppColors.blush)
                        : SmartProductImage(url: product.imageUrls.first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTypography.price),
                      const SizedBox(height: 4),
                      Text(Formatters.php(product.price), style: AppTypography.bodySmall),
                      const SizedBox(height: 6),
                      WhimsicalBadge(label: product.stockStatus.label, color: color),
                    ],
                  ),
                ),
                Switch.adaptive(value: product.isPublished, onChanged: onToggle),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'dup') onDuplicate();
                    if (v == 'del') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'dup', child: Text('Duplicate')),
                    PopupMenuItem(value: 'del', child: Text('Delete')),
                  ],
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle, color: AppColors.plumSoft),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
