import 'package:flutter/material.dart';

import '../../models/catalog_sort.dart';
import '../../theme/tokens.dart';

class CatalogSortPicker extends StatelessWidget {
  const CatalogSortPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final CatalogSort value;
  final ValueChanged<CatalogSort> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final sort in CatalogSort.values) ...[
            ChoiceChip(
              label: Text(sort.label),
              selected: value == sort,
              onSelected: (_) => onChanged(sort),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );

    if (compact) {
      return chips;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer shop order', style: AppTypography.title),
        const SizedBox(height: 6),
        Text(value.help, style: AppTypography.bodySmall),
        const SizedBox(height: 10),
        chips,
      ],
    );
  }
}
