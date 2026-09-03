import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/formatters.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';
import '../ui/feedback.dart';
import '../ui/photo_lightbox.dart';
import '../ui/whimsical_badge.dart';
import '../ui/whimsical_button.dart';
import 'mix_bill.dart';
import 'mix_stage.dart';
import 'cutout_sprite.dart';

enum _Door { meet, paracord, trinkets, letterings, specialTrinkets, summary }

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
  final _letterings = <ProductOption>{};
  ProductOption? _rope;
  final _specialTrinkets = <ProductOption>{};
  bool? _wantsLetterings;

  Product get product => widget.product;

  bool get _offersLettering {
    return product.letterings.any((item) => item.stock > 0) &&
        product.ropes.any((item) => item.stock > 0);
  }

  _Door get _askFromDoor {
    if (product.trinkets.isNotEmpty) return _Door.trinkets;
    if (product.paracords.isNotEmpty) return _Door.paracord;
    return _Door.meet;
  }

  List<_Door> get _doors {
    return [
      _Door.meet,
      if (product.paracords.isNotEmpty) _Door.paracord,
      if (product.trinkets.isNotEmpty) _Door.trinkets,
      if (_wantsLetterings == true && _offersLettering) _Door.letterings,
      if (product.specialTrinkets.isNotEmpty) _Door.specialTrinkets,
      _Door.summary,
    ];
  }

  _Door get _door => _doors[_index.clamp(0, _doors.length - 1)];

  int get _maxQty {
    var max = 99;
    if (product.tracksInhalerStock) max = math.min(max, product.stock);
    if (_paracord != null) max = math.min(max, _paracord!.stock);
    if (_rope != null) max = math.min(max, _rope!.stock);
    for (final item in [..._trinkets, ..._letterings, ..._specialTrinkets]) {
      max = math.min(max, item.stock);
    }
    return math.max(1, max);
  }

  bool get _stockOk {
    if (product.tracksInhalerStock && product.stock < _qty) return false;
    if (_paracord != null && _paracord!.stock < _qty) return false;
    if (_rope != null && _rope!.stock < _qty) return false;
    for (final item in [..._trinkets, ..._letterings, ..._specialTrinkets]) {
      if (item.stock < _qty) return false;
    }
    return true;
  }

  double get _unit => product.linePrice(
        paracord: _paracord,
        pickedTrinkets: _trinkets.toList(),
        pickedLetterings: _letterings.toList(),
        rope: _rope,
        pickedSpecials: _specialTrinkets.toList(),
      );

  bool get _letteringReady =>
      _letterings.any((item) => item.stock > 0) && _rope != null && _rope!.stock > 0;

  bool get _canNext => switch (_door) {
        _Door.meet => true,
        _Door.paracord => _paracord != null && _paracord!.stock > 0,
        _Door.trinkets => true,
        _Door.letterings => _letteringReady,
        _Door.specialTrinkets => true,
        _Door.summary => _stockOk,
      };

  void _syncSelection() {
    _paracord = _keptOne(_paracord, product.paracords);
    _rope = _keptOne(_rope, product.ropes);
    _refreshSet(_trinkets, product.trinkets);
    _refreshSet(_letterings, product.letterings);
    _refreshSet(_specialTrinkets, product.specialTrinkets);
    if (_qty > _maxQty) _qty = _maxQty;
  }

  ProductOption? _keptOne(ProductOption? current, List<ProductOption> catalog) {
    if (current == null) return null;
    final next = catalog.where((item) => item.id == current.id).firstOrNull;
    return (next == null || next.stock <= 0) ? null : next;
  }

  void _refreshSet(Set<ProductOption> selected, List<ProductOption> catalog) {
    final kept = <ProductOption>{};
    for (final item in selected) {
      final next = catalog.where((option) => option.id == item.id).firstOrNull;
      if (next != null && next.stock > 0) kept.add(next);
    }
    selected
      ..clear()
      ..addAll(kept);
  }

  void _toggle(Set<ProductOption> selected, ProductOption option) {
    if (option.stock <= 0) return;
    setState(() {
      final existing = selected.where((item) => item.id == option.id).firstOrNull;
      if (existing != null) {
        selected.remove(existing);
      } else {
        selected.add(option);
      }
    });
  }

  void _clearLetteringMix() {
    _letterings.clear();
    _rope = null;
  }

  @override
  void didUpdateWidget(ProductDoorFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _syncSelection();
    }
  }

  Future<void> _next() async {
    if (_index >= _doors.length - 1) return;
    if (_door == _askFromDoor && _offersLettering && _wantsLetterings != true) {
      final yes = await _askForLetterings();
      if (!mounted || yes == null) return;
      setState(() {
        _wantsLetterings = yes;
        if (!yes) _clearLetteringMix();
        _index++;
      });
      return;
    }
    setState(() => _index++);
  }

  Future<bool?> _askForLetterings() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Letterings of your initial?'),
          content: Text(
            'Want letterings of your initial on this mix? If yes, you will pick letters and a rope. The rope is required.',
            style: AppTypography.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _back() {
    if (_index == 0) return;
    setState(() {
      final leaving = _door;
      if (leaving == _Door.letterings) {
        _wantsLetterings = null;
        _clearLetteringMix();
      }
      _index--;
      if (_wantsLetterings == false && _door == _askFromDoor) {
        _wantsLetterings = null;
      }
      if (_index >= _doors.length) _index = _doors.length - 1;
    });
  }

  void _addToCart() {
    final sold = product.isSoldOut;
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
              if (_letterings.isNotEmpty)
                'letterings': _letterings.map((item) => item.name).join(', '),
              if (_rope != null) 'rope': _rope!.name,
              if (_specialTrinkets.isNotEmpty)
                'special_trinkets': _specialTrinkets.map((item) => item.name).join(', '),
            },
            paracord: _paracord,
            trinkets: _trinkets.toList(),
            letterings: _letterings.toList(),
            rope: _rope,
            specialTrinkets: _specialTrinkets.toList(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} hopped into your cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sold = product.isSoldOut;
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
              _Door.letterings => 'Add letterings',
              _Door.specialTrinkets => 'Add special trinket',
              _Door.summary => 'Check the mix',
            },
          ),
          MixStage(
            inhalerUrl: mixInhalerUrl(product),
            paracord: _paracord,
            trinkets: _trinkets.toList(),
            letterings: _letterings.toList(),
            rope: _rope,
            specialTrinkets: _specialTrinkets.toList(),
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
                        onTap: (option) => _toggle(_trinkets, option),
                      ),
                    _Door.letterings => _LetteringDoor(
                        letterings: product.letterings,
                        ropes: product.ropes,
                        selectedLetteringIds: _letterings.map((item) => item.id).toSet(),
                        selectedRopeId: _rope?.id,
                        onLettering: (option) => _toggle(_letterings, option),
                        onRope: (option) {
                          if (option.stock <= 0) return;
                          setState(() => _rope = option);
                        },
                      ),
                    _Door.specialTrinkets => _OptionGrid(
                        subtitle: 'Tap a special trinket. Tap again to take it off.',
                        options: product.specialTrinkets,
                        selectedIds: _specialTrinkets.map((item) => item.id).toSet(),
                        onTap: (option) => _toggle(_specialTrinkets, option),
                      ),
                    _Door.summary => _SummaryDoor(
                        product: product,
                        paracord: _paracord,
                        trinkets: _trinkets.toList(),
                        letterings: _letterings.toList(),
                        rope: _rope,
                        specialTrinkets: _specialTrinkets.toList(),
                        qty: _qty,
                        maxQty: _maxQty,
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
                              label: _door == _Door.letterings && !_letteringReady
                                  ? 'Pick a letter and a rope'
                                  : 'Next',
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
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.kicker,
          ),
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
        if (product.isSoldOut || product.stockStatus == StockStatus.madeToOrder) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: WhimsicalBadge(
              label: product.isSoldOut ? StockStatus.soldOut.label : product.stockStatus.label,
              color: product.isSoldOut
                  ? AppColors.cancelled.withValues(alpha: 0.25)
                  : AppColors.meadow,
            ),
          ),
          const SizedBox(height: 24),
        ] else if (product.tracksInhalerStock) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: WhimsicalBadge(label: '${product.stock} left', color: AppColors.meadow),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.displayMedium,
        ),
        const SizedBox(height: 12),
        Text('from ${Formatters.php(product.price)}', style: AppTypography.title),
        const SizedBox(height: 28),
        Text(product.description, style: AppTypography.body.copyWith(height: 1.55)),
      ],
    );
  }
}

class _LetteringDoor extends StatelessWidget {
  const _LetteringDoor({
    required this.letterings,
    required this.ropes,
    required this.selectedLetteringIds,
    required this.selectedRopeId,
    required this.onLettering,
    required this.onRope,
  });

  final List<ProductOption> letterings;
  final List<ProductOption> ropes;
  final Set<String> selectedLetteringIds;
  final String? selectedRopeId;
  final ValueChanged<ProductOption> onLettering;
  final ValueChanged<ProductOption> onRope;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      children: [
        Text('LETTERINGS', style: AppTypography.kicker),
        const SizedBox(height: 8),
        Text(
          'Tap the letters of your initial. Tap again to take one off.',
          style: AppTypography.body.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        for (final option in letterings) ...[
          _OptionTile(
            option: option,
            selected: selectedLetteringIds.contains(option.id),
            onTap: onLettering,
          ),
          const SizedBox(height: 18),
        ],
        const SizedBox(height: 8),
        Text('ROPES', style: AppTypography.kicker),
        const SizedBox(height: 8),
        Text(
          'Pick one rope. This is required with letterings.',
          style: AppTypography.body.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        for (final option in ropes) ...[
          _OptionTile(
            option: option,
            selected: selectedRopeId == option.id,
            onTap: onRope,
          ),
          const SizedBox(height: 18),
        ],
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
        return _OptionTile(
          option: option,
          selected: selectedIds.contains(option.id),
          onTap: onTap,
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ProductOption option;
  final bool selected;
  final ValueChanged<ProductOption> onTap;

  @override
  Widget build(BuildContext context) {
    final gone = option.stock <= 0;
    return AnimatedScale(
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
                _OptionPhoto(option: option),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: gone ? null : () => onTap(option),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title,
                        ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionPhoto extends StatelessWidget {
  const _OptionPhoto({required this.option});

  final ProductOption option;

  @override
  Widget build(BuildContext context) {
    final url = optionPreviewUrl(option);
    return GestureDetector(
      key: ValueKey('option-photo-${option.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: url == null
          ? null
          : () => showPhotoLightbox(
                context,
                url: url,
                title: option.name,
              ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 64,
              height: 64,
              child: ColoredBox(
                color: const Color(0xFFFFF8FC),
                child: url == null
                    ? const SizedBox.expand()
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: CutoutSprite(url: url),
                      ),
              ),
            ),
          ),
          if (url != null)
            const Positioned(
              right: 2,
              bottom: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.yolk,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.ink, width: 1.5),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.open_in_full, size: 10, color: AppColors.ink),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryDoor extends StatelessWidget {
  const _SummaryDoor({
    required this.product,
    required this.paracord,
    required this.trinkets,
    required this.letterings,
    required this.rope,
    required this.specialTrinkets,
    required this.qty,
    required this.maxQty,
    required this.onQty,
  });

  final Product product;
  final ProductOption? paracord;
  final List<ProductOption> trinkets;
  final List<ProductOption> letterings;
  final ProductOption? rope;
  final List<ProductOption> specialTrinkets;
  final int qty;
  final int maxQty;
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
                MixBill(
                  data: MixBillData(
                    productName: product.name,
                    inhalerPrice: product.price,
                    paracord: paracord,
                    trinkets: trinkets,
                    letterings: letterings,
                    rope: rope,
                    specialTrinkets: specialTrinkets,
                    quantity: qty,
                    includeEmpty: true,
                  ),
                ),
                const SizedBox(height: 16),
                QuantityStepper(value: qty, max: maxQty, onChanged: onQty),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
