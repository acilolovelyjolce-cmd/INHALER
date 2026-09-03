import 'package:flutter/material.dart';

import '../../config/formatters.dart';
import '../../models/order_request.dart';
import '../../models/product.dart';
import '../../providers/catalog_providers.dart';
import '../../theme/tokens.dart';

class MixBillEntry {
  const MixBillEntry({required this.label, required this.price});

  final String label;
  final double price;
}

/// Named parts of a mix, each with its own peso amount.
class MixBillData {
  const MixBillData({
    required this.productName,
    required this.inhalerPrice,
    this.paracord,
    this.trinkets = const [],
    this.letterings = const [],
    this.rope,
    this.specialTrinkets = const [],
    this.quantity = 1,
    this.includeEmpty = false,
  });

  factory MixBillData.fromCartLine(CartLine line, {bool includeEmpty = false}) {
    return MixBillData(
      productName: line.productName,
      inhalerPrice: line.inhalerPrice,
      paracord: line.paracord,
      trinkets: line.trinkets,
      letterings: line.letterings,
      rope: line.rope,
      specialTrinkets: line.specialTrinkets,
      quantity: line.quantity,
      includeEmpty: includeEmpty,
    );
  }

  factory MixBillData.fromOrderItem(OrderItem item, {bool includeEmpty = false}) {
    final paracord = _optionFromMap(item.paracord);
    final trinkets = _optionsFromMaps(item.trinkets);
    final letterings = _optionsFromMaps(item.letterings);
    final rope = _optionFromMap(item.rope);
    final specialTrinkets = _optionsFromMaps(item.specialTrinkets);
    final extras = (paracord?.price ?? 0) +
        _sum(trinkets) +
        _sum(letterings) +
        (rope?.price ?? 0) +
        _sum(specialTrinkets);
    return MixBillData(
      productName: item.productName,
      inhalerPrice: (item.priceAtOrder - extras).clamp(0, item.priceAtOrder),
      paracord: paracord,
      trinkets: trinkets,
      letterings: letterings,
      rope: rope,
      specialTrinkets: specialTrinkets,
      quantity: item.quantity,
      includeEmpty: includeEmpty,
    );
  }

  final String productName;
  final double inhalerPrice;
  final ProductOption? paracord;
  final List<ProductOption> trinkets;
  final List<ProductOption> letterings;
  final ProductOption? rope;
  final List<ProductOption> specialTrinkets;
  final int quantity;
  final bool includeEmpty;

  List<MixBillEntry> get parts {
    return [
      MixBillEntry(label: 'Inhaler', price: inhalerPrice),
      if (paracord != null)
        MixBillEntry(label: paracord!.name, price: paracord!.price)
      else if (includeEmpty)
        const MixBillEntry(label: 'Paracord  none', price: 0),
      if (trinkets.isEmpty && includeEmpty)
        const MixBillEntry(label: 'Trinkets  none', price: 0),
      for (final item in trinkets)
        MixBillEntry(label: item.name, price: item.price),
      if (letterings.isEmpty && includeEmpty)
        const MixBillEntry(label: 'Letterings  none', price: 0),
      for (final item in letterings)
        MixBillEntry(label: item.name, price: item.price),
      if (rope != null)
        MixBillEntry(label: rope!.name, price: rope!.price)
      else if (includeEmpty)
        const MixBillEntry(label: 'Rope  none', price: 0),
      if (specialTrinkets.isEmpty && includeEmpty)
        const MixBillEntry(label: 'Special trinket  none', price: 0),
      for (final item in specialTrinkets)
        MixBillEntry(label: item.name, price: item.price),
    ];
  }

  double get unitTotal => parts.fold(0, (sum, part) => sum + part.price);

  double get lineTotal => unitTotal * quantity;
}

double _sum(List<ProductOption> items) =>
    items.fold<double>(0, (sum, option) => sum + option.price);

List<ProductOption> _optionsFromMaps(List<Map<String, dynamic>>? rows) {
  return [
    for (final row in rows ?? const <Map<String, dynamic>>[]) ?_optionFromMap(row),
  ];
}

ProductOption? _optionFromMap(Map<String, dynamic>? row) {
  if (row == null) return null;
  final name = row['name']?.toString().trim() ?? '';
  if (name.isEmpty) return null;
  final raw = row['price'];
  return ProductOption(
    id: row['id']?.toString() ?? name,
    name: name,
    price: raw is num ? raw.toDouble() : 0,
    imageUrl: row['image_url']?.toString(),
  );
}

class MixBill extends StatelessWidget {
  const MixBill({
    super.key,
    required this.data,
    this.showProductName = true,
    this.showEach = true,
  });

  final MixBillData data;
  final bool showProductName;
  final bool showEach;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showProductName) ...[
          Text(
            data.productName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.title.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
        ],
        for (final part in data.parts)
          _BillRow(
            label: part.label,
            amount: part.price == 0 && part.label.endsWith('none')
                ? null
                : Formatters.php(part.price),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 2, color: AppColors.ink),
        ),
        if (showEach && data.quantity > 1) ...[
          _BillRow(label: 'Each', amount: Formatters.php(data.unitTotal)),
          _BillRow(label: 'Qty', amount: '×${data.quantity}'),
        ],
        _BillRow(
          label: 'Total',
          amount: Formatters.php(data.lineTotal),
          emphasis: true,
        ),
      ],
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
    required this.label,
    required this.amount,
    this.emphasis = false,
  });

  final String label;
  final String? amount;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis ? AppTypography.title : AppTypography.body;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: amount == null ? AppTypography.bodySmall : style,
            ),
          ),
          const SizedBox(width: 12),
          if (amount != null) Text(amount!, style: emphasis ? AppTypography.displaySmall : AppTypography.price),
        ],
      ),
    );
  }
}
