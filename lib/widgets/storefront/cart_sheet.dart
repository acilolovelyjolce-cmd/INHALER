import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../config/validators.dart';
import '../../models/order_request.dart';
import '../../models/owner_profile.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_button.dart';
import '../ui/whimsical_sheet.dart';
import '../ui/whimsical_text_field.dart';
import 'mix_bill.dart';

enum _CartStep { bag, pay, details, done }

class CartSheet extends ConsumerStatefulWidget {
  const CartSheet({super.key, required this.slug, required this.shopName});

  final String slug;
  final String shopName;

  @override
  ConsumerState<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends ConsumerState<CartSheet> {
  var _step = _CartStep.bag;
  PaymentMethod? _method;

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    if (_step == _CartStep.done) {
      return SheetScaffold(
        title: 'Order in',
        child: ConfirmationView(ownerName: widget.shopName, method: _method),
      );
    }

    if (lines.isEmpty) {
      return const SheetScaffold(
        title: 'Your cart',
        child: WhimsicalEmpty(
          title: 'Cart is empty',
          body: 'Tap a charm, walk through the doors, then add it here.',
        ),
      );
    }

    return SheetScaffold(
      title: switch (_step) {
        _CartStep.bag => 'Your cart',
        _CartStep.pay => 'How will you pay?',
        _CartStep.details => 'Almost there',
        _CartStep.done => 'Order in',
      },
      child: switch (_step) {
        _CartStep.bag => _BagStep(
            slug: widget.slug,
            onCheckout: () => setState(() => _step = _CartStep.pay),
          ),
        _CartStep.pay => _PayStep(
            slug: widget.slug,
            selected: _method,
            onSelect: (method) => setState(() {
              _method = method;
              _step = _CartStep.details;
            }),
            onBack: () => setState(() => _step = _CartStep.bag),
          ),
        _CartStep.details => CheckoutForm(
            slug: widget.slug,
            shopName: widget.shopName,
            method: _method!,
            onBack: () => setState(() => _step = _CartStep.pay),
            onDone: () => setState(() => _step = _CartStep.done),
          ),
        _CartStep.done => ConfirmationView(ownerName: widget.shopName, method: _method),
      },
    );
  }
}

class _BagStep extends ConsumerWidget {
  const _BagStep({required this.slug, required this.onCheckout});

  final String slug;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartProvider);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: lines.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final line = lines[index];
              return DecoratedBox(
                decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (line.imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: ContainedMedia(url: line.imageUrl!, padding: 6),
                              ),
                            ),
                          if (line.imageUrl != null) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              line.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      MixBill(
                        data: MixBillData.fromCartLine(line),
                        showProductName: false,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: QuantityStepper(
                          value: line.quantity,
                          onChanged: (v) =>
                              ref.read(cartProvider.notifier).setQuantity(index, v),
                        ),
                      ),
                    ],
                  ),
                ),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: WhimsicalButton(label: 'checkout', expand: true, onPressed: onCheckout),
        ),
      ],
    );
  }
}

class _PayStep extends ConsumerWidget {
  const _PayStep({
    required this.slug,
    required this.selected,
    required this.onSelect,
    required this.onBack,
  });

  final String slug;
  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pick one first. Then we’ll take your name.', style: AppTypography.bodySmall),
          const SizedBox(height: 16),
          _PayCard(
            title: 'E-wallet',
            body: 'GCash / Maya — we’ll show the shop QR next.',
            selected: selected == PaymentMethod.eWallet,
            onTap: () => onSelect(PaymentMethod.eWallet),
          ),
          const SizedBox(height: 12),
          _PayCard(
            title: 'Cash',
            body: 'Pay when you pick up or meet the owner.',
            selected: selected == PaymentMethod.cash,
            onTap: () => onSelect(PaymentMethod.cash),
          ),
          const Spacer(),
          TextButton(onPressed: onBack, child: const Text('back to cart')),
        ],
      ),
    );
  }
}

class _PayCard extends StatelessWidget {
  const _PayCard({
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: AppMotion.squish,
        scale: selected ? 1.02 : 1,
        child: DecoratedBox(
          decoration: stickerFill(
            color: selected ? AppColors.petal : AppColors.cloud,
            pressed: selected,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.displaySmall),
                const SizedBox(height: 6),
                Text(body, style: AppTypography.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CheckoutForm extends ConsumerStatefulWidget {
  const CheckoutForm({
    super.key,
    required this.slug,
    required this.shopName,
    required this.method,
    required this.onBack,
    required this.onDone,
  });

  final String slug;
  final String shopName;
  final PaymentMethod method;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  ConsumerState<CheckoutForm> createState() => _CheckoutFormState();
}

class _CheckoutFormState extends ConsumerState<CheckoutForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _note = TextEditingController();
  final _honeypot = TextEditingController();
  var _busy = false;

  OwnerProfile? get _shop => ref.watch(shopProfileProvider(widget.slug)).valueOrNull;

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
    try {
      final lines = ref.read(cartProvider);
      final items = [
        for (final line in lines)
          OrderItem(
            productId: line.productId,
            productName: line.productName,
            variantSelection: line.variantSelection,
            quantity: line.quantity,
            priceAtOrder: line.price,
            paracord: line.paracord?.toJson(),
            trinkets: [for (final item in line.trinkets) item.toJson()],
          ),
      ];
      await ref.read(ordersRepositoryProvider).submit(
            shopSlug: widget.slug,
            customerName: _name.text.trim(),
            customerContact: _contact.text.trim(),
            items: items,
            totalAmount: ref.read(cartProvider.notifier).total,
            customerNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
            honeypot: _honeypot.text,
            paymentMethod: widget.method,
          );
      ref.invalidate(publishedProductsProvider(widget.slug));
      ref.read(cartProvider.notifier).clear();
      ref.read(submitLockProvider.notifier).lock();
      if (mounted) widget.onDone();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qr = _shop?.ewalletQrUrl;
    final lines = ref.watch(cartProvider);
    final total = lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text('Your order', style: AppTypography.title),
          const SizedBox(height: 10),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MixBill(data: MixBillData.fromCartLine(line)),
                ),
              ),
            ),
          Row(
            children: [
              const Text('Grand total', style: AppTypography.title),
              const Spacer(),
              Text(Formatters.php(total), style: AppTypography.displaySmall),
            ],
          ),
          const SizedBox(height: 18),
          if (widget.method == PaymentMethod.eWallet) ...[
            Text('Scan to pay', style: AppTypography.title),
            const SizedBox(height: 8),
            if (qr == null || qr.isEmpty)
              Text(
                'The owner hasn’t uploaded a QR yet. You can still send the order and they’ll share it.',
                style: AppTypography.bodySmall,
              )
            else
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: DecoratedBox(
                    decoration: stickerFill(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: ContainedMedia(url: qr, padding: 12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ] else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Cash it is. The owner will confirm pickup or meetup.',
                style: AppTypography.bodySmall,
              ),
            ),
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
            validator: Validators.name,
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
            label: 'place order',
            expand: true,
            busy: _busy,
            onPressed: _submit,
          ),
          TextButton(onPressed: widget.onBack, child: const Text('change payment')),
        ],
      ),
    );
  }
}

class ConfirmationView extends StatelessWidget {
  const ConfirmationView({super.key, required this.ownerName, this.method});

  final String ownerName;
  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
      child: Column(
        children: [
          const AnimatedCheck(size: 72),
          const SizedBox(height: 16),
          Text(
            'Yay! Your order is in',
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            method == PaymentMethod.cash
                ? '$ownerName will reach out to confirm cash pickup.'
                : '$ownerName will match your e-wallet payment and confirm.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
