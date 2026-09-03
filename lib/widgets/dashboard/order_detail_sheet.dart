import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../config/validators.dart';
import '../../models/order_request.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_badge.dart';
import '../ui/whimsical_button.dart';
import '../ui/whimsical_sheet.dart';
import '../ui/whimsical_text_field.dart';
import 'delete_order.dart';
import '../storefront/mix_bill.dart';

class OrderDetailSheet extends ConsumerStatefulWidget {
  const OrderDetailSheet({super.key, required this.order});

  final OrderRequest order;

  @override
  ConsumerState<OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends ConsumerState<OrderDetailSheet> {
  late OrderRequest _order;
  late final TextEditingController _notes;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _notes = TextEditingController(text: widget.order.internalNotes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save(OrderRequest next) async {
    final previous = _order;
    setState(() {
      _busy = true;
      _order = next;
    });
    try {
      await ref.read(ordersRepositoryProvider).update(next);
      ref.invalidate(ownerProductsProvider);
    } catch (e) {
      if (mounted) {
        setState(() => _order = previous);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: _order.customerName,
      actions: WhimsicalButton(
        label: 'Save notes',
        expand: true,
        busy: _busy,
        onPressed: () => _save(_order.copyWith(internalNotes: Validators.cleanMultiline(_notes.text))),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text(_order.customerContact, style: AppTypography.bodySmall),
          const SizedBox(height: 6),
          Text(
            [
              Formatters.dayTime.format(_order.createdAt.toLocal()),
              if (_order.paymentMethod != null) _order.paymentMethod!.label,
            ].join(' · '),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 20),
          Text('Status', style: AppTypography.title),
          const SizedBox(height: 12),
          _Stepper(
            current: _order.status,
            onSelect: (status) => _save(_order.copyWith(status: status, updatedAt: DateTime.now())),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _save(
                _order.copyWith(status: OrderStatus.cancelled, updatedAt: DateTime.now()),
              ),
              child: const Text('Cancel request'),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                final gone = await confirmAndDeleteOrder(
                  context: context,
                  ref: ref,
                  order: _order,
                );
                if (gone && context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Delete request'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Payment', style: AppTypography.title),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final pay in PaymentStatus.values)
                ChoiceChip(
                  label: Text(pay.label),
                  selected: _order.paymentStatus == pay,
                  onSelected: (_) =>
                      _save(_order.copyWith(paymentStatus: pay, updatedAt: DateTime.now())),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Items', style: AppTypography.title),
          const SizedBox(height: 10),
          for (final item in _order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MixBill(data: MixBillData.fromOrderItem(item)),
                ),
              ),
            ),
          const Divider(height: 32),
          Row(
            children: [
              const Text('Total', style: AppTypography.title),
              const Spacer(),
              Text(Formatters.php(_order.totalAmount), style: AppTypography.displaySmall),
            ],
          ),
          if (_order.customerNote != null && _order.customerNote!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Customer note', style: AppTypography.title),
            const SizedBox(height: 6),
            Text(_order.customerNote!, style: AppTypography.body),
          ],
          const SizedBox(height: 20),
          WhimsicalTextField(
            controller: _notes,
            label: 'Internal notes',
            hint: 'Only you see this',
            maxLines: 3,
          ),
          if (_order.status == OrderStatus.confirmed ||
              _order.status == OrderStatus.ready)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Align(alignment: Alignment.centerLeft, child: AnimatedCheck(size: 40)),
            ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current, required this.onSelect});

  final OrderStatus current;
  final ValueChanged<OrderStatus> onSelect;

  static const _flow = [
    OrderStatus.newRequest,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _flow.indexOf(current);
    return Column(
      children: [
        for (var i = 0; i < _flow.length; i++)
          InkWell(
            onTap: () => onSelect(_flow[i]),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= currentIndex && current != OrderStatus.cancelled
                          ? AppColors.meadow
                          : AppColors.blush,
                    ),
                    child: i <= currentIndex && current != OrderStatus.cancelled
                        ? const Icon(Icons.check, size: 14, color: AppColors.plum)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(_flow[i].label, style: AppTypography.body),
                  if (i == currentIndex) ...[
                    const SizedBox(width: 8),
                    const WhimsicalBadge(label: 'now', color: AppColors.petal),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
