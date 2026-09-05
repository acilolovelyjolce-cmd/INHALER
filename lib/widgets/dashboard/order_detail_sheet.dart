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
  late final TextEditingController _name;
  late final TextEditingController _contact;
  late final TextEditingController _customerNote;
  late final TextEditingController _notes;
  late List<_ItemDraft> _items;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _name = TextEditingController(text: widget.order.customerName);
    _contact = TextEditingController(text: widget.order.customerContact);
    _customerNote = TextEditingController(text: widget.order.customerNote ?? '');
    _notes = TextEditingController(text: widget.order.internalNotes ?? '');
    _items = [for (final item in widget.order.items) _ItemDraft(item)];
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _customerNote.dispose();
    _notes.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  List<OrderItem> get _draftItems => [for (final item in _items) item.toItem()];

  double get _draftTotal =>
      _draftItems.fold<double>(0, (sum, item) => sum + item.priceAtOrder * item.quantity);

  Future<void> _save(OrderRequest next) async {
    final previous = _order;
    setState(() {
      _busy = true;
      _order = next;
    });
    try {
      await ref.read(ordersRepositoryProvider).update(next);
      ref.invalidate(ownerProductsProvider);
      ref.invalidate(ordersInboxProvider);
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

  Future<void> _saveDetails() async {
    final nameError = Validators.name(_name.text);
    final contactError = Validators.contact(_contact.text);
    if (nameError != null || contactError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError ?? contactError!)),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An order needs at least one item.')),
      );
      return;
    }
    final note = Validators.cleanMultiline(_customerNote.text);
    await _save(
      _order.copyWith(
        customerName: Validators.cleanLine(_name.text),
        customerContact: Validators.cleanLine(_contact.text),
        customerNote: note.isEmpty ? null : note,
        internalNotes: Validators.cleanMultiline(_notes.text),
        items: _draftItems,
        totalAmount: _draftTotal,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: Validators.cleanLine(_name.text).isEmpty ? _order.customerName : Validators.cleanLine(_name.text),
      actions: WhimsicalButton(
        label: 'Save changes',
        expand: true,
        busy: _busy,
        onPressed: _saveDetails,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text(
            [
              Formatters.dayTime.format(_order.createdAt.toLocal()),
              if (_order.paymentMethod != null) _order.paymentMethod!.label,
            ].join(' · '),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 18),
          Text('Guest details', style: AppTypography.title),
          const SizedBox(height: 10),
          WhimsicalTextField(
            controller: _name,
            label: 'Name',
            validator: Validators.name,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          WhimsicalTextField(
            controller: _contact,
            label: 'Contact',
            validator: Validators.contact,
          ),
          const SizedBox(height: 12),
          WhimsicalTextField(
            controller: _customerNote,
            label: 'Customer note',
            hint: 'Pickup, gift wrap, shade of mint…',
            maxLines: 3,
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final method in PaymentMethod.values)
                ChoiceChip(
                  label: Text(method.label),
                  selected: _order.paymentMethod == method,
                  onSelected: (_) => _save(
                    _order.copyWith(paymentMethod: method, updatedAt: DateTime.now()),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Items', style: AppTypography.title),
          const SizedBox(height: 6),
          Text(
            'Change the name, quantity, or peso amount. Save changes writes it to the request and the till.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < _items.length; i++)
            _ItemEditor(
              draft: _items[i],
              canRemove: _items.length > 1,
              onChanged: () => setState(() {}),
              onRemove: () {
                setState(() {
                  _items.removeAt(i).dispose();
                });
              },
            ),
          const Divider(height: 32),
          Row(
            children: [
              const Text('Total', style: AppTypography.title),
              const Spacer(),
              Text(Formatters.php(_draftTotal), style: AppTypography.displaySmall),
            ],
          ),
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

class _ItemDraft {
  _ItemDraft(this.source)
      : productName = TextEditingController(text: source.productName),
        price = TextEditingController(text: source.priceAtOrder.toStringAsFixed(0)),
        quantity = source.quantity;

  final OrderItem source;
  final TextEditingController productName;
  final TextEditingController price;
  int quantity;

  OrderItem toItem() {
    return source.copyWith(
      productName: Validators.cleanLine(productName.text).isEmpty
          ? source.productName
          : Validators.cleanLine(productName.text),
      priceAtOrder: Validators.parseMoney(price.text) ?? source.priceAtOrder,
      quantity: quantity < 1 ? 1 : quantity,
    );
  }

  void dispose() {
    productName.dispose();
    price.dispose();
  }
}

class _ItemEditor extends StatelessWidget {
  const _ItemEditor({
    required this.draft,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final _ItemDraft draft;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: stickerFill(radius: 22, stroke: AppStroke.inkThin),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MixBill(data: MixBillData.fromOrderItem(draft.toItem())),
              const SizedBox(height: 12),
              WhimsicalTextField(
                controller: draft.productName,
                label: 'Item name',
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: 12),
              WhimsicalTextField(
                controller: draft.price,
                label: 'Price each',
                keyboardType: TextInputType.number,
                onChanged: (_) => onChanged(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  QuantityStepper(
                    value: draft.quantity,
                    max: 99,
                    onChanged: (value) {
                      draft.quantity = value;
                      onChanged();
                    },
                  ),
                  const Spacer(),
                  if (canRemove)
                    TextButton(
                      onPressed: onRemove,
                      child: const Text('Remove item'),
                    ),
                ],
              ),
            ],
          ),
        ),
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
