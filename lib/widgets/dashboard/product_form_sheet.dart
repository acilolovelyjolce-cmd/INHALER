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
  late final String _id;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _compare;
  late final TextEditingController _qty;
  late List<String> _images;
  late StockStatus _stock;
  late bool _published;
  var _uploading = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _id = p?.id ?? const Uuid().v4();
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(0));
    _compare = TextEditingController(
      text: p?.compareAtPrice == null ? '' : p!.compareAtPrice!.toStringAsFixed(0),
    );
    _qty = TextEditingController(text: p == null ? '10' : '${p.stock}');
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
    _qty.dispose();
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
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    final price = Validators.parseMoney(_price.text);
    if (price == null) return;
    final qty = Validators.parseStock(_qty.text);
    if (qty == null) return;
    var status = _stock;
    if (status != StockStatus.madeToOrder) {
      if (qty <= 0) {
        status = StockStatus.soldOut;
      } else if (status == StockStatus.soldOut) {
        status = StockStatus.available;
      }
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final existing = widget.existing;
      final auth = ref.read(authProvider).valueOrNull;
      final product = Product(
        id: _id,
        ownerId: existing?.ownerId ?? auth?.userId,
        name: Validators.cleanLine(_name.text),
        description: Validators.cleanMultiline(_description.text),
        price: price,
        compareAtPrice: Validators.parseMoney(_compare.text),
        imageUrls: _images,
        category: '',
        paracords: existing?.paracords ?? const [],
        trinkets: existing?.trinkets ?? const [],
        letterings: existing?.letterings ?? const [],
        ropes: existing?.ropes ?? const [],
        specialTrinkets: existing?.specialTrinkets ?? const [],
        stock: qty,
        stockStatus: status,
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
    final letteringCount = parts?.letterings.length ?? 0;
    final ropeCount = parts?.ropes.length ?? 0;
    final specialCount = parts?.specialTrinkets.length ?? 0;

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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.price,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9₱.,\s]'))],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WhimsicalTextField(
                    controller: _compare,
                    label: 'Compare at',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: Validators.optionalPrice,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9₱.,\s]'))],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            WhimsicalTextField(
              controller: _qty,
              label: 'Left',
              hint: 'How many of this inhaler are ready',
              keyboardType: TextInputType.number,
              validator: Validators.stock,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9\s,]'))],
            ),
            const SizedBox(height: 18),
            Text(
              '$cordCount paracords, $charmCount trinkets, $letteringCount letterings, $ropeCount ropes, and $specialCount special trinkets will be offered with this inhaler automatically. Add those in Catalog.',
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
