import 'package:flutter/material.dart';

import '../../models/catalog_sort.dart';
import '../../theme/tokens.dart';

class CatalogSortPicker extends StatelessWidget {
  const CatalogSortPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CatalogSort value;
  final ValueChanged<CatalogSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Customer shop order', style: AppTypography.title),
        const SizedBox(height: 6),
        Text(value.help, style: AppTypography.bodySmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final sort in CatalogSort.values)
              ChoiceChip(
                label: Text(sort.label),
                selected: value == sort,
                onSelected: (_) => onChanged(sort),
              ),
          ],
        ),
      ],
    );
  }
}
