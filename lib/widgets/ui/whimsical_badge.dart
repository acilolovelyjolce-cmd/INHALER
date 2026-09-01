import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class WhimsicalBadge extends StatelessWidget {
  const WhimsicalBadge({
    super.key,
    required this.label,
    this.color = AppColors.yolk,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label.copyWith(color: AppColors.ink),
        ),
      ),
    );
  }
}

class WhimsicalSegmented<T> extends StatelessWidget {
  const WhimsicalSegmented({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: stickerFill(color: AppColors.cloud, radius: 24, stroke: AppStroke.inkThin),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            for (final value in values)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: () => onChanged(value),
                  child: AnimatedContainer(
                    duration: AppMotion.hover,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: ShapeDecoration(
                      color: value == selected ? AppColors.petal : Colors.transparent,
                      shape: StadiumBorder(
                        side: value == selected
                            ? const BorderSide(color: AppColors.ink, width: 2)
                            : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      labelOf(value),
                      style: AppTypography.label.copyWith(
                        color: AppColors.plum,
                        fontWeight: value == selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
