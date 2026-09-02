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

class PartFormSheet extends ConsumerStatefulWidget {
  const PartFormSheet({super.key, required this.trinket, this.existing});

  final bool trinket;
  final ProductOption? existing;

  @override
  ConsumerState<PartFormSheet> createState() => _PartFormSheetState();
}

class _PartFormSheetState extends ConsumerState<PartFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  String? _imageUrl;
  var _uploading = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _price = TextEditingController(
      text: existing == null ? '' : existing.price.toStringAsFixed(0),
    );
    _stock = TextEditingController(text: existing == null ? '0' : '${existing.stock}');
    _imageUrl = existing?.imageUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 55,
      maxWidth: 1024,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final url = await ref.read(productsRepositoryProvider).uploadImage(
            await file.readAsBytes(),
            ownerId: ref.read(authProvider).valueOrNull?.userId,
          );
      setState(() => _imageUrl = url);
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
      final option = ProductOption(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _name.text.trim(),
        price: double.tryParse(_price.text.replaceAll(RegExp(r'[₱,\s]'), '').trim()) ?? 0,
        imageUrl: _imageUrl,
        stock: int.tryParse(_stock.text.trim())?.clamp(0, 999999) ?? 0,
      );
      await ref.read(productsRepositoryProvider).upsertPart(option, trinket: widget.trinket);
      ref.invalidate(ownerPartsProvider);
      ref.invalidate(ownerProductsProvider);
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
    final label = widget.trinket ? 'trinket' : 'paracord';
    return SheetScaffold(
      title: widget.existing == null ? 'New $label' : 'Edit $label',
      actions: WhimsicalButton(
        label: widget.existing == null ? 'Add $label' : 'Save changes',
        expand: true,
        busy: _saving,
        onPressed: _save,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _uploading ? null : _pickImage,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: _imageUrl == null
                        ? ColoredBox(
                            color: AppColors.blush,
                            child: Center(
                              child: _uploading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.add_a_photo_outlined),
                            ),
                          )
                        : ContainedMedia(url: _imageUrl!, padding: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.trinket
                  ? 'This charm is offered on every inhaler. Customers can pick as many as they like.'
                  : 'This cord is offered on every inhaler. Customers pick one color.',
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
            const SizedBox(height: 18),
            WhimsicalTextField(
              controller: _name,
              label: 'Name',
              hint: widget.trinket ? 'Baby Rex' : 'Mint paracord',
              validator: Validators.name,
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
                    controller: _stock,
                    label: 'Left',
                    keyboardType: TextInputType.number,
                    validator: Validators.stock,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
