import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/whimsical_badge.dart';
import '../ui/whimsical_button.dart';
import 'mix_stage.dart';
import 'cutout_sprite.dart';

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
    return ColoredBox(
      color: AppColors.blush,
      child: Column(
        children: [
          _DoorTrack(
            index: _index,
            total: _doors.length,
            label: switch (_door) {
              _Door.meet => 'Meet the inhaler',
              _Door.paracord => 'Pick a paracord',
              _Door.trinkets => 'Add trinkets',
              _Door.summary => 'Check the mix',
            },
          ),
          MixStage(
            inhalerUrl: mixInhalerUrl(product),
            paracord: _paracord,
            trinkets: _trinkets.toList(),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder: (currentChild, _) => SizedBox.expand(
                child: ColoredBox(
                  color: AppColors.blush,
                  child: currentChild ?? const SizedBox.shrink(),
                ),
              ),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: KeyedSubtree(
                key: ValueKey(_door),
                child: ColoredBox(
                  color: AppColors.blush,
                  child: switch (_door) {
                    _Door.meet => _MeetDoor(product: product),
                    _Door.paracord => _OptionGrid(
                        subtitle: product.paracords.every((item) => item.stock <= 0)
                            ? 'These cords are all gone for now.'
                            : 'One color for the cord.',
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
          ),
          ColoredBox(
            color: AppColors.blush,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    if (_index > 0)
                      WhimsicalButton(
                        label: 'Back',
                        kind: WhimsicalButtonKind.ghost,
                        onPressed: _back,
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _door == _Door.summary
                          ? WhimsicalButton(
                              label: sold
                                  ? 'All gone for now'
                                  : _stockOk
                                      ? 'Add to cart'
                                      : 'Not enough left',
                              expand: true,
                              onPressed: sold || !_stockOk ? null : _addToCart,
                            )
                          : WhimsicalButton(
                              label: 'Next',
                              expand: true,
                              onPressed: _canNext ? _next : null,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.kicker),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: AppMotion.hover,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= index ? AppColors.petal : AppColors.cloud,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.ink, width: AppStroke.inkThin),
                    ),
                  ),
                ),
                if (i < total - 1) const SizedBox(width: 8),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      children: [
        if (product.stockStatus != StockStatus.available) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: WhimsicalBadge(
              label: product.stockStatus.label,
              color: product.stockStatus == StockStatus.soldOut
                  ? AppColors.cancelled.withValues(alpha: 0.25)
                  : AppColors.meadow,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(product.name, style: AppTypography.displayMedium),
        const SizedBox(height: 12),
        Text('from ${Formatters.php(product.price)}', style: AppTypography.title),
        const SizedBox(height: 28),
        Text(product.description, style: AppTypography.body.copyWith(height: 1.55)),
      ],
    );
  }
}

class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.subtitle,
    required this.options,
    required this.selectedIds,
    required this.onTap,
  });

  final String subtitle;
  final List<ProductOption> options;
  final Set<String> selectedIds;
  final ValueChanged<ProductOption> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      itemCount: options.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(subtitle, style: AppTypography.body.copyWith(height: 1.45));
        }
        final option = options[index - 1];
        final selected = selectedIds.contains(option.id);
        final gone = option.stock <= 0;
        return GestureDetector(
          onTap: gone ? null : () => onTap(option),
          child: AnimatedScale(
            duration: AppMotion.squish,
            scale: selected ? 1.01 : 1,
            child: Opacity(
              opacity: gone ? 0.5 : 1,
              child: DecoratedBox(
                decoration: stickerFill(
                  color: selected ? AppColors.petal : AppColors.cloud,
                  radius: 24,
                  pressed: selected,
                  stroke: AppStroke.inkThin,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: ColoredBox(
                            color: const Color(0xFFFFF8FC),
                            child: optionPreviewUrl(option) == null
                                ? const SizedBox.expand()
                                : Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CutoutSprite(url: optionPreviewUrl(option)!),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.name, style: AppTypography.title),
                            const SizedBox(height: 6),
                            Text(Formatters.php(option.price), style: AppTypography.body),
                            const SizedBox(height: 4),
                            Text(
                              gone ? 'sold out' : '${option.stock} left',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
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
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
      children: [
        Text('YOUR MIX', style: AppTypography.kicker),
        const SizedBox(height: 20),
        DecoratedBox(
          decoration: stickerFill(color: AppColors.cloud, radius: 28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTypography.title.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Inhaler  ${Formatters.php(product.price)}',
                  style: AppTypography.body,
                ),
                if (paracord != null)
                  Text(
                    'Paracord  ${paracord!.name}  ${Formatters.php(paracord!.price)}',
                    style: AppTypography.body,
                  ),
                Text(
                  trinkets.isEmpty
                      ? 'Trinkets  none'
                      : 'Trinkets  ${trinkets.map((item) => item.name).join(', ')}',
                  style: AppTypography.body,
                ),
                const SizedBox(height: 20),
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
