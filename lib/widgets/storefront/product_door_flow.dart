import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_badge.dart';
import '../ui/whimsical_button.dart';

enum _Door { meet, paracord, trinkets, summary }

class ProductDoorFlow extends ConsumerStatefulWidget {
  const ProductDoorFlow({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDoorFlow> createState() => _ProductDoorFlowState();
}

class _ProductDoorFlowState extends ConsumerState<ProductDoorFlow> {
  var _index = 0;
  var _qty = 1;
  ProductOption? _paracord;
  final _trinkets = <ProductOption>{};

  Product get product => widget.product;

  List<_Door> get _doors {
    return [
      _Door.meet,
      if (product.paracords.isNotEmpty) _Door.paracord,
      if (product.trinkets.isNotEmpty) _Door.trinkets,
      _Door.summary,
    ];
  }

  _Door get _door => _doors[_index];

  int get _maxQty {
    var max = 99;
    if (_paracord != null) max = math.min(max, _paracord!.stock);
    for (final item in _trinkets) {
      max = math.min(max, item.stock);
    }
    return math.max(1, max);
  }

  bool get _stockOk {
    if (_paracord != null && _paracord!.stock < _qty) return false;
    for (final item in _trinkets) {
      if (item.stock < _qty) return false;
    }
    return true;
  }

  double get _unit => product.linePrice(
        paracord: _paracord,
        pickedTrinkets: _trinkets.toList(),
      );

  bool get _canNext => switch (_door) {
        _Door.meet => true,
        _Door.paracord => _paracord != null && _paracord!.stock > 0,
        _Door.trinkets => true,
        _Door.summary => _stockOk,
      };

  void _syncSelection() {
    if (_paracord != null) {
      final next = product.paracords.where((item) => item.id == _paracord!.id).firstOrNull;
      _paracord = (next == null || next.stock <= 0) ? null : next;
    }
    final kept = <ProductOption>{};
    for (final item in _trinkets) {
      final next = product.trinkets.where((option) => option.id == item.id).firstOrNull;
      if (next != null && next.stock > 0) kept.add(next);
    }
    _trinkets
      ..clear()
      ..addAll(kept);
    if (_qty > _maxQty) _qty = _maxQty;
  }

  @override
  void didUpdateWidget(ProductDoorFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _syncSelection();
    }
  }

  void _next() {
    if (_index >= _doors.length - 1) return;
    setState(() => _index++);
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index--);
  }

  void _addToCart() {
    final sold = product.stockStatus == StockStatus.soldOut;
    if (sold || !_stockOk) return;
    ref.read(cartProvider.notifier).add(
          CartLine(
            productId: product.id,
            productName: product.name,
            price: _unit,
            quantity: _qty,
            imageUrl: product.imageUrls.isEmpty ? null : product.imageUrls.first,
            variantSelection: {
              if (_paracord != null) 'paracord': _paracord!.name,
              if (_trinkets.isNotEmpty)
                'trinkets': _trinkets.map((item) => item.name).join(', '),
            },
            paracord: _paracord,
            trinkets: _trinkets.toList(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} hopped into your cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sold = product.stockStatus == StockStatus.soldOut;
    return Column(
      children: [
        _DoorTrack(index: _index, total: _doors.length, label: switch (_door) {
          _Door.meet => 'meet the inhaler',
          _Door.paracord => 'pick a paracord',
          _Door.trinkets => 'add trinkets',
          _Door.summary => 'check the mix',
        }),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.12, 0),
                    end: Offset.zero,
                  ).animate(curved),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
                    child: child,
                  ),
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_door),
              child: switch (_door) {
                _Door.meet => _MeetDoor(product: product),
                _Door.paracord => _OptionGrid(
                    title: 'One paracord',
                    subtitle: product.paracords.every((item) => item.stock <= 0)
                        ? 'These cords are all gone for now.'
                        : 'Pick a single color for the cord.',
                    options: product.paracords,
                    selectedIds: {
                      if (_paracord != null) _paracord!.id,
                    },
                    onTap: (option) {
                      if (option.stock <= 0) return;
                      setState(() => _paracord = option);
                    },
                  ),
                _Door.trinkets => _OptionGrid(
                    title: 'Trinkets',
                    subtitle: 'Tap as many as you like. Tap again to take one off.',
                    options: product.trinkets,
                    selectedIds: _trinkets.map((item) => item.id).toSet(),
                    onTap: (option) {
                      if (option.stock <= 0) return;
                      setState(() {
                        final existing =
                            _trinkets.where((item) => item.id == option.id).firstOrNull;
                        if (existing != null) {
                          _trinkets.remove(existing);
                        } else {
                          _trinkets.add(option);
                        }
                      });
                    },
                  ),
                _Door.summary => _SummaryDoor(
                    product: product,
                    paracord: _paracord,
                    trinkets: _trinkets.toList(),
                    qty: _qty,
                    maxQty: _maxQty,
                    unit: _unit,
                    onQty: (v) => setState(() => _qty = v),
                  ),
              },
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                if (_index > 0)
                  WhimsicalButton(
                    label: 'back',
                    kind: WhimsicalButtonKind.ghost,
                    onPressed: _back,
                  ),
                if (_index > 0) const SizedBox(width: 10),
                Expanded(
                  child: _door == _Door.summary
                      ? WhimsicalButton(
                          label: sold
                              ? 'all gone for now'
                              : _stockOk
                                  ? 'add to cart'
                                  : 'not enough left',
                          expand: true,
                          onPressed: sold || !_stockOk ? null : _addToCart,
                        )
                      : WhimsicalButton(
                          label: 'next door',
                          expand: true,
                          onPressed: _canNext ? _next : null,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DoorTrack extends StatelessWidget {
  const _DoorTrack({required this.index, required this.total, required this.label});

  final int index;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.hover,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= index ? AppColors.petal : AppColors.cloud,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.ink, width: 2),
                    ),
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MeetDoor extends StatelessWidget {
  const _MeetDoor({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final image = product.imageUrls.isEmpty ? null : product.imageUrls.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: stickerFill(color: AppColors.cloud, radius: AppRadii.image),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.image - 4),
              child: image == null
                  ? const ColoredBox(color: AppColors.sky)
                  : ContainedMedia(url: image, padding: 18),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 280.ms)
            .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack),
        const SizedBox(height: 18),
        if (product.stockStatus != StockStatus.available)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: WhimsicalBadge(
                label: product.stockStatus.label,
                color: product.stockStatus == StockStatus.soldOut
                    ? AppColors.cancelled.withValues(alpha: 0.25)
                    : AppColors.meadow,
              ),
            ),
          ),
        Text(product.name, style: AppTypography.displayMedium),
        const SizedBox(height: 6),
        Text('from ${Formatters.php(product.price)}', style: AppTypography.displaySmall),
        const SizedBox(height: 12),
        Text(product.description, style: AppTypography.body),
      ],
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selectedIds,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<ProductOption> options;
  final Set<String> selectedIds;
  final ValueChanged<ProductOption> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      children: [
        Text(title, style: AppTypography.displaySmall),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTypography.bodySmall),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final selected = selectedIds.contains(option.id);
            final gone = option.stock <= 0;
            return GestureDetector(
              onTap: gone ? null : () => onTap(option),
              child: AnimatedScale(
                duration: AppMotion.squish,
                scale: selected ? 1.03 : 1,
                child: Opacity(
                  opacity: gone ? 0.45 : 1,
                  child: DecoratedBox(
                    decoration: stickerFill(
                      color: selected ? AppColors.petal : AppColors.cloud,
                      radius: 26,
                      pressed: selected,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: option.imageUrl == null
                                  ? const ColoredBox(color: AppColors.sky)
                                  : ContainedMedia(url: option.imageUrl!, padding: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.title.copyWith(fontSize: 14),
                          ),
                          Text(Formatters.php(option.price), style: AppTypography.bodySmall),
                          Text(
                            gone ? 'sold out' : '${option.stock} left',
                            style: AppTypography.bodySmall.copyWith(
                              color: gone ? AppColors.plum : AppColors.plumSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SummaryDoor extends StatelessWidget {
  const _SummaryDoor({
    required this.product,
    required this.paracord,
    required this.trinkets,
    required this.qty,
    required this.maxQty,
    required this.unit,
    required this.onQty,
  });

  final Product product;
  final ProductOption? paracord;
  final List<ProductOption> trinkets;
  final int qty;
  final int maxQty;
  final double unit;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      children: [
        Text('Your mix', style: AppTypography.displaySmall),
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: stickerFill(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTypography.title),
                const SizedBox(height: 8),
                Text('Inhaler  ${Formatters.php(product.price)}', style: AppTypography.body),
                if (paracord != null)
                  Text(
                    'Paracord  ${paracord!.name}  ${Formatters.php(paracord!.price)}',
                    style: AppTypography.body,
                  ),
                if (trinkets.isEmpty)
                  Text('Trinkets  none', style: AppTypography.bodySmall)
                else
                  for (final item in trinkets)
                    Text(
                      'Trinket  ${item.name}  ${Formatters.php(item.price)}',
                      style: AppTypography.body,
                    ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    QuantityStepper(value: qty, max: maxQty, onChanged: onQty),
                    const Spacer(),
                    Text(Formatters.php(unit * qty), style: AppTypography.displaySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
