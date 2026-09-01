import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum WhimsicalButtonKind { petal, meadow, ghost, yolk }

class WhimsicalButton extends StatelessWidget {
  const WhimsicalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = WhimsicalButtonKind.petal,
    this.icon,
    this.expand = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final WhimsicalButtonKind kind;
  final IconData? icon;
  final bool expand;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final bg = switch (kind) {
      WhimsicalButtonKind.petal => AppColors.petal,
      WhimsicalButtonKind.meadow => AppColors.meadow,
      WhimsicalButtonKind.yolk => AppColors.yolk,
      WhimsicalButtonKind.ghost => Colors.transparent,
    };
    final border = kind == WhimsicalButtonKind.ghost
        ? BorderSide(color: AppColors.plum.withValues(alpha: 0.16))
        : BorderSide.none;

    final child = FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        disabledBackgroundColor: bg.withValues(alpha: 0.5),
        foregroundColor: AppColors.plum,
        disabledForegroundColor: AppColors.plumSoft,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const StadiumBorder(),
        side: border,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        textStyle: AppTypography.button,
      ),
      child: busy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.plum),
            )
          : Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );

    if (expand) return SizedBox(width: double.infinity, child: child);
    return child;
  }
}
