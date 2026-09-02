import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../config/validators.dart';
import '../../models/parts_catalog.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/dashboard/part_form_sheet.dart';
import '../../widgets/dashboard/product_form_sheet.dart';
import '../../widgets/ui/feedback.dart';
import '../../widgets/ui/whimsical_badge.dart';
import '../../widgets/ui/whimsical_button.dart';
import '../../widgets/ui/whimsical_sheet.dart';
import '../../widgets/ui/whimsical_text_field.dart';

enum _CatalogSection { inhalers, paracords, trinkets }

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  var _section = _CatalogSection.inhalers;

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(ownerProductsProvider);
    final parts = ref.watch(ownerPartsProvider);

    return catalog.when(
      loading: () => const DinoLoading(),
      error: (e, _) => WhimsicalError(
        message: e.toString(),
        onRetry: () {
          ref.invalidate(ownerProductsProvider);
          ref.invalidate(ownerPartsProvider);
        },
      ),
      data: (products) {
        final bag = parts.valueOrNull ??
            PartsCatalog(
              paracords: _unique(products, (p) => p.paracords),
              trinkets: _unique(products, (p) => p.trinkets),
            );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Catalog',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.displayMedium,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'bulk') _bulk(context, ref, products);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'bulk', child: Text('Bulk price adjust')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final section in _CatalogSection.values) ...[
                                ChoiceChip(
                                  label: Text(switch (section) {
                                    _CatalogSection.inhalers => 'Inhalers',
                                    _CatalogSection.paracords => 'Paracords',
                                    _CatalogSection.trinkets => 'Trinkets',
                                  }),
                                  selected: _section == section,
                                  onSelected: (_) => setState(() => _section = section),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      WhimsicalButton(
                        label: 'Add',
                        icon: Icons.add,
                        compact: true,
                        onPressed: () => _openAdd(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: _body(products, bag)),
          ],
        );
      },
    );
  }

  Widget _body(List<Product> products, PartsCatalog bag) {
    if (_section == _CatalogSection.inhalers) {
      if (products.isEmpty) {
        return const WhimsicalEmpty(
          title: 'No inhalers yet',
          body: 'Add an inhaler and every paracord and trinket in the catalog will be offered with it.',
        );
      }
      return ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: products.length,
        onReorder: (oldIndex, newIndex) async {
          var nextIndex = newIndex;
          if (nextIndex > oldIndex) nextIndex--;
          final next = [...products];
          final item = next.removeAt(oldIndex);
          next.insert(nextIndex, item);
          try {
            await ref.read(productsRepositoryProvider).reorder(next);
          } catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString())),
              );
            }
            ref.invalidate(ownerProductsProvider);
          }
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
            onDuplicate: () => ref.read(productsRepositoryProvider).duplicate(product),
            onToggle: (v) => ref.read(productsRepositoryProvider).upsert(
                  product.copyWith(isPublished: v, updatedAt: DateTime.now()),
                ),
            onDelete: () => _deleteProduct(context, ref, product),
          );
        },
      );
    }

    final trinket = _section == _CatalogSection.trinkets;
    final options = trinket ? bag.trinkets : bag.paracords;
    if (options.isEmpty) {
      return WhimsicalEmpty(
        title: trinket ? 'No trinkets yet' : 'No paracords yet',
        body: trinket
            ? 'Add a charm once. It will show up as an option on every inhaler.'
            : 'Add a cord color once. It will show up as an option on every inhaler.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        return _PartRow(
          option: option,
          onEdit: () => showWhimsicalSheet(
            context: context,
            builder: (_) => PartFormSheet(trinket: trinket, existing: option),
          ),
          onDelete: () => _deletePart(context, option),
        );
      },
    );
  }

  Future<void> _openAdd(BuildContext context) {
    return showWhimsicalSheet(
      context: context,
      builder: (_) => switch (_section) {
        _CatalogSection.inhalers => const ProductFormSheet(),
        _CatalogSection.paracords => const PartFormSheet(trinket: false),
        _CatalogSection.trinkets => const PartFormSheet(trinket: true),
      },
    );
  }

  List<ProductOption> _unique(List<Product> products, List<ProductOption> Function(Product) pick) {
    final out = <String, ProductOption>{};
    for (final product in products) {
      for (final option in pick(product)) {
        out[option.id] = option;
      }
    }
    return out.values.toList();
  }

  Future<void> _bulk(BuildContext context, WidgetRef ref, List<Product> products) async {
    if (products.isEmpty) return;
    var percent = true;
    final amount = TextEditingController(text: '10');
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust prices'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'This updates every inhaler in the catalog.',
                      style: AppTypography.bodySmall,
                    ),
                    SwitchListTile(
                      title: Text(percent ? 'Percent' : 'Flat ₱'),
                      value: percent,
                      onChanged: (v) => setState(() => percent = v),
                    ),
                    WhimsicalTextField(
                      controller: amount,
                      label: percent ? 'Percent' : 'Amount',
                      hint: percent ? '10 or -10' : '40 or -40',
                      validator: Validators.signedAmount,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
    if (ok == true) {
      try {
        await ref.read(productsRepositoryProvider).bulkAdjustPrice(
              percent: percent,
              amount: double.tryParse(amount.text.replaceAll(RegExp(r'[₱,\s]'), '')) ?? 0,
            );
        ref.invalidate(ownerProductsProvider);
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      }
    }
    amount.dispose();
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref, Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete this inhaler?'),
          content: Text(
            '${product.name} will leave the catalog and the public shop. Cords and trinkets stay.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await ref.read(productsRepositoryProvider).delete(product.id);
    }
  }

  Future<void> _deletePart(BuildContext context, ProductOption option) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove this option?'),
          content: Text(
            '${option.name} will leave every inhaler.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        );
      },
    );
    if (ok == true && context.mounted) {
      await ref.read(productsRepositoryProvider).deletePart(option.id);
    }
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.option,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductOption option;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cloud,
        borderRadius: AppRadii.cardBorder,
        child: InkWell(
          onTap: onEdit,
          borderRadius: AppRadii.cardBorder,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: option.imageUrl == null
                        ? const ColoredBox(color: AppColors.blush)
                        : SmartProductImage(url: option.imageUrl!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.price,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Formatters.php(option.price)}  ·  ${option.stock} left',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'del') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'del', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.price,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.php(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall,
                      ),
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
