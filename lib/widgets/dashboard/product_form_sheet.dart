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
  late List<_OptionDraft> _paracords;
  late List<_OptionDraft> _trinkets;
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
    _paracords = [
      for (final option in p?.paracords ?? const <ProductOption>[]) _OptionDraft.from(option),
    ];
    _trinkets = [
      for (final option in p?.trinkets ?? const <ProductOption>[]) _OptionDraft.from(option),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _compare.dispose();
    _category.dispose();
    for (final draft in [..._paracords, ..._trinkets]) {
      draft.dispose();
    }
    super.dispose();
  }

  List<ProductOption> _collect(List<_OptionDraft> drafts) {
    return [
      for (final draft in drafts)
        if (draft.name.text.trim().isNotEmpty)
          ProductOption(
            id: draft.id,
            name: draft.name.text.trim(),
            price: double.tryParse(draft.price.text.replaceAll(',', '').trim()) ?? 0,
            imageUrl: draft.imageUrl,
            stock: int.tryParse(draft.stock.text.trim())?.clamp(0, 999999) ?? 0,
          ),
    ];
  }

  Future<void> _pickOptionImage(_OptionDraft draft) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ref.read(productsRepositoryProvider).uploadImage(
            await file.readAsBytes(),
            ownerId: ref.read(authProvider).valueOrNull?.userId,
          );
      setState(() => draft.imageUrl = url);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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
      paracords: _collect(_paracords),
      trinkets: _collect(_trinkets),
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
            _OptionSection(
              title: 'Paracords',
              hint: 'Customers pick exactly one. Photo, price, and how many of this color are left.',
              drafts: _paracords,
              uploading: _uploading,
              onAdd: () => setState(() => _paracords.add(_OptionDraft.empty())),
              onRemove: (i) => setState(() => _paracords.removeAt(i).dispose()),
              onPickImage: (draft) => _pickOptionImage(draft),
            ),
            const SizedBox(height: 18),
            _OptionSection(
              title: 'Trinkets',
              hint: 'Customers can pick many. Photo, price, and leftover stock for each charm.',
              drafts: _trinkets,
              uploading: _uploading,
              onAdd: () => setState(() => _trinkets.add(_OptionDraft.empty())),
              onRemove: (i) => setState(() => _trinkets.removeAt(i).dispose()),
              onPickImage: (draft) => _pickOptionImage(draft),
            ),
            const SizedBox(height: 8),
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

class _OptionDraft {
  _OptionDraft({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  factory _OptionDraft.empty() => _OptionDraft(
        id: const Uuid().v4(),
        name: TextEditingController(),
        price: TextEditingController(),
        stock: TextEditingController(text: '0'),
      );

  factory _OptionDraft.from(ProductOption option) => _OptionDraft(
        id: option.id,
        name: TextEditingController(text: option.name),
        price: TextEditingController(text: option.price.toStringAsFixed(0)),
        stock: TextEditingController(text: '${option.stock}'),
        imageUrl: option.imageUrl,
      );

  final String id;
  final TextEditingController name;
  final TextEditingController price;
  final TextEditingController stock;
  String? imageUrl;

  void dispose() {
    name.dispose();
    price.dispose();
    stock.dispose();
  }
}

class _OptionSection extends StatelessWidget {
  const _OptionSection({
    required this.title,
    required this.hint,
    required this.drafts,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
    required this.onPickImage,
  });

  final String title;
  final String hint;
  final List<_OptionDraft> drafts;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<_OptionDraft> onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.title),
        const SizedBox(height: 4),
        Text(hint, style: AppTypography.bodySmall),
        const SizedBox(height: 10),
        for (var i = 0; i < drafts.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: uploading ? null : () => onPickImage(drafts[i]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: drafts[i].imageUrl == null
                              ? const ColoredBox(
                                  color: AppColors.sky,
                                  child: Icon(Icons.add_a_photo_outlined, size: 20),
                                )
                              : ContainedMedia(url: drafts[i].imageUrl!, padding: 6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          WhimsicalTextField(controller: drafts[i].name, hint: 'Name'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: WhimsicalTextField(
                                  controller: drafts[i].price,
                                  hint: 'Price ₱',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: WhimsicalTextField(
                                  controller: drafts[i].stock,
                                  hint: 'Left',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(i),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('Add $title'.toLowerCase()),
          ),
        ),
      ],
    );
  }
}
