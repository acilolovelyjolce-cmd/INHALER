import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../config/validators.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_button.dart';
import '../ui/whimsical_sheet.dart';
import '../ui/whimsical_text_field.dart';

class ProductFormSheet extends ConsumerStatefulWidget {
  const ProductFormSheet({super.key, this.existing});

  final Product? existing;

  @override
  ConsumerState<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends ConsumerState<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _compare;
  late final TextEditingController _category;
  late List<String> _images;
  late StockStatus _stock;
  late bool _published;
  final _variantKeys = <TextEditingController>[];
  final _variantValues = <TextEditingController>[];
  var _uploading = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(0));
    _compare = TextEditingController(
      text: p?.compareAtPrice == null ? '' : p!.compareAtPrice!.toStringAsFixed(0),
    );
    _category = TextEditingController(text: p?.category ?? 'Dino Series');
    _images = [...?p?.imageUrls];
    _stock = p?.stockStatus ?? StockStatus.available;
    _published = p?.isPublished ?? true;
    final variants = p?.variants;
    if (variants != null && variants.isNotEmpty) {
      for (final entry in variants.entries) {
        _variantKeys.add(TextEditingController(text: entry.key));
        final values = entry.value is List ? (entry.value as List).join(', ') : '${entry.value}';
        _variantValues.add(TextEditingController(text: values));
      }
    } else {
      _addVariantRow(key: 'color', values: 'Mint, Blush', notify: false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _compare.dispose();
    _category.dispose();
    for (final c in [..._variantKeys, ..._variantValues]) {
      c.dispose();
    }
    super.dispose();
  }

  void _addVariantRow({String key = '', String values = '', bool notify = true}) {
    void apply() {
      _variantKeys.add(TextEditingController(text: key));
      _variantValues.add(TextEditingController(text: values));
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  Map<String, dynamic> _variantsMap() {
    final map = <String, dynamic>{};
    for (var i = 0; i < _variantKeys.length; i++) {
      final key = _variantKeys[i].text.trim();
      if (key.isEmpty) continue;
      map[key] = _variantValues[i]
          .text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return map;
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 92);
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    final repo = ref.read(productsRepositoryProvider);
    final auth = ref.read(authProvider).valueOrNull;
    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        final url = await repo.uploadImage(bytes, ownerId: auth?.userId);
        _images.add(url);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.existing;
    final auth = ref.read(authProvider).valueOrNull;
    final product = Product(
      id: existing?.id ?? const Uuid().v4(),
      ownerId: existing?.ownerId ?? auth?.userId,
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.replaceAll(',', '').trim()),
      compareAtPrice: _compare.text.trim().isEmpty
          ? null
          : double.tryParse(_compare.text.replaceAll(',', '').trim()),
      imageUrls: _images,
      category: _category.text.trim(),
      variants: _variantsMap(),
      stockStatus: _stock,
      isPublished: _published,
      sortOrder: existing?.sortOrder ?? 99,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(productsRepositoryProvider).upsert(product);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: widget.existing == null ? 'New charm' : 'Edit product',
      actions: WhimsicalButton(
        label: widget.existing == null ? 'Add to catalog' : 'Save changes',
        expand: true,
        busy: _saving,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < _images.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadii.imageBorder,
                            child: SizedBox(
                              width: 96,
                              height: 120,
                              child: SmartProductImage(url: _images[i]),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.cloud,
                                foregroundColor: AppColors.plum,
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => setState(() => _images.removeAt(i)),
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GestureDetector(
                    onTap: _uploading ? null : _pickImages,
                    child: Container(
                      width: 96,
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: AppRadii.imageBorder,
                      ),
                      child: Center(
                        child: _uploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            WhimsicalTextField(
              controller: _name,
              label: 'Name',
              hint: 'Baby Rex Inhaler Keychain',
              validator: (v) => Validators.requiredField(v, label: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            WhimsicalTextField(
              controller: _description,
              label: 'Description',
              maxLines: 4,
              validator: (v) => Validators.requiredField(v, label: 'Description'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: WhimsicalTextField(
                    controller: _price,
                    label: 'Price (₱)',
                    keyboardType: TextInputType.number,
                    validator: Validators.price,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WhimsicalTextField(
                    controller: _compare,
                    label: 'Compare at',
                    keyboardType: TextInputType.number,
                    validator: Validators.optionalPrice,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            WhimsicalTextField(
              controller: _category,
              label: 'Category',
              hint: 'Dino Series',
              validator: (v) => Validators.requiredField(v, label: 'Category'),
            ),
            const SizedBox(height: 18),
            Text('Variants', style: AppTypography.title),
            const SizedBox(height: 8),
            for (var i = 0; i < _variantKeys.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: WhimsicalTextField(controller: _variantKeys[i], hint: 'color'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: WhimsicalTextField(
                        controller: _variantValues[i],
                        hint: 'Mint, Blush',
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _variantKeys.removeAt(i).dispose();
                          _variantValues.removeAt(i).dispose();
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addVariantRow,
                icon: const Icon(Icons.add),
                label: const Text('Add option'),
              ),
            ),
            const SizedBox(height: 8),
            Text('Stock', style: AppTypography.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in StockStatus.values)
                  ChoiceChip(
                    label: Text(s.label),
                    selected: _stock == s,
                    onSelected: (_) => setState(() => _stock = s),
                  ),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Published on the public link', style: AppTypography.body),
              value: _published,
              onChanged: (v) => setState(() => _published = v),
            ),
          ],
        ),
      ),
    );
  }
}
