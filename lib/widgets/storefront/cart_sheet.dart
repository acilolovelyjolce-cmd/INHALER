import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../config/validators.dart';
import '../../models/order_request.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_button.dart';
import '../ui/whimsical_sheet.dart';
import '../ui/whimsical_text_field.dart';

class CartSheet extends ConsumerWidget {
  const CartSheet({super.key, required this.slug, required this.shopName});

  final String slug;
  final String shopName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    if (lines.isEmpty) {
      return const SheetScaffold(
        title: 'Your request',
        child: WhimsicalEmpty(
          title: 'Nothing in here yet',
          body: 'Add a charm from the shop and it will land in this little tray.',
        ),
      );
    }

    return SheetScaffold(
      title: 'Your request',
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              itemCount: lines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final line = lines[index];
                return Row(
                  children: [
                    if (line.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: SmartProductImage(url: line.imageUrl!),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.productName, style: AppTypography.price),
                          if (line.variantSelection.isNotEmpty)
                            Text(
                              line.variantSelection.values.join(' · '),
                              style: AppTypography.bodySmall,
                            ),
                          Text(Formatters.php(line.lineTotal), style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    QuantityStepper(
                      value: line.quantity,
                      onChanged: (v) => ref.read(cartProvider.notifier).setQuantity(index, v),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                const Text('Total', style: AppTypography.title),
                const Spacer(),
                Text(
                  Formatters.php(ref.read(cartProvider.notifier).total),
                  style: AppTypography.displaySmall,
                ),
              ],
            ),
          ),
          RequestForm(slug: slug, shopName: shopName),
        ],
      ),
    );
  }
}

class RequestForm extends ConsumerStatefulWidget {
  const RequestForm({super.key, required this.slug, required this.shopName});

  final String slug;
  final String shopName;

  @override
  ConsumerState<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _note = TextEditingController();
  final _honeypot = TextEditingController();
  var _busy = false;
  var _done = false;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _note.dispose();
    _honeypot.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (ref.read(submitLockProvider.notifier).isLocked) return;
    setState(() => _busy = true);
    final lines = ref.read(cartProvider);
    final items = [
      for (final line in lines)
        OrderItem(
          productId: line.productId,
          productName: line.productName,
          variantSelection: line.variantSelection,
          quantity: line.quantity,
          priceAtOrder: line.price,
        ),
    ];
    // TODO v2: integrate PayMongo/GCash payment link here
    await ref.read(ordersRepositoryProvider).submit(
          shopSlug: widget.slug,
          customerName: _name.text.trim(),
          customerContact: _contact.text.trim(),
          items: items,
          totalAmount: ref.read(cartProvider.notifier).total,
          customerNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
          honeypot: _honeypot.text,
        );
    ref.read(cartProvider.notifier).clear();
    ref.read(submitLockProvider.notifier).lock();
    if (mounted) {
      setState(() {
        _busy = false;
        _done = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return ConfirmationView(ownerName: widget.shopName);
    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Offstage(
              offstage: true,
              child: TextFormField(
                controller: _honeypot,
                decoration: const InputDecoration(hintText: 'website'),
              ),
            ),
            WhimsicalTextField(
              controller: _name,
              label: 'Your name',
              validator: (v) => Validators.requiredField(v, label: 'Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            WhimsicalTextField(
              controller: _contact,
              label: 'Contact (mobile or social)',
              hint: 'GCash number, IG, or FB name',
              validator: Validators.contact,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            WhimsicalTextField(
              controller: _note,
              label: 'Note (optional)',
              maxLines: 3,
              hint: 'Gift wrap, pickup, shade of mint…',
            ),
            const SizedBox(height: 16),
            WhimsicalButton(
              label: 'Send request',
              expand: true,
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmationView extends StatelessWidget {
  const ConfirmationView({super.key, required this.ownerName});

  final String ownerName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: Column(
        children: [
          const AnimatedCheck(size: 72),
          const SizedBox(height: 16),
          Text(
            'Yay! Your request is in 🦕💌',
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$ownerName will reach out to confirm.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
