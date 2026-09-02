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
  late List<String> _images;
  late StockStatus _stock;
  late bool _published;
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
    _images = [...?p?.imageUrls];
    _stock = p?.stockStatus ?? StockStatus.available;
    _published = p?.isPublished ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _compare.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 55, maxWidth: 1024);
    if (files.isEmpty) return;
    setState(() => _uploading = true);
    final repo = ref.read(productsRepositoryProvider);
    final auth = ref.read(authProvider).valueOrNull;
    try {
      final payloads = await Future.wait(files.map((file) => file.readAsBytes()));
      final urls = await Future.wait(
        payloads.map((bytes) => repo.uploadImage(bytes, ownerId: auth?.userId)),
      );
      _images.addAll(urls);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final existing = widget.existing;
      final auth = ref.read(authProvider).valueOrNull;
      final parts = await ref.read(productsRepositoryProvider).fetchParts();
      final product = Product(
        id: existing?.id ?? const Uuid().v4(),
        ownerId: existing?.ownerId ?? auth?.userId,
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: double.parse(_price.text.replaceAll(RegExp(r'[₱,\s]'), '').trim()),
        compareAtPrice: _compare.text.trim().isEmpty
            ? null
            : double.tryParse(_compare.text.replaceAll(RegExp(r'[₱,\s]'), '').trim()),
        imageUrls: _images,
        category: '',
        paracords: parts.paracords,
        trinkets: parts.trinkets,
        stockStatus: _stock,
        isPublished: _published,
        sortOrder: existing?.sortOrder ?? 99,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await ref.read(productsRepositoryProvider).upsert(product);
      ref.invalidate(ownerProductsProvider);
      ref.invalidate(ownerPartsProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = ref.watch(ownerPartsProvider).valueOrNull;
    final cordCount = parts?.paracords.length ?? 0;
    final charmCount = parts?.trinkets.length ?? 0;

    return SheetScaffold(
      title: widget.existing == null ? 'New inhaler' : 'Edit inhaler',
      actions: WhimsicalButton(
        label: widget.existing == null ? 'Add inhaler' : 'Save changes',
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
              validator: Validators.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            WhimsicalTextField(
              controller: _description,
              label: 'Description',
              maxLines: 4,
              validator: (v) => Validators.optionalText(v, max: 600, label: 'Description'),
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
            const SizedBox(height: 18),
            Text(
              '$cordCount paracords and $charmCount trinkets will be offered with this inhaler automatically. Add those in Catalog.',
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
            const SizedBox(height: 18),
            Text('Availability', style: AppTypography.label),
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
