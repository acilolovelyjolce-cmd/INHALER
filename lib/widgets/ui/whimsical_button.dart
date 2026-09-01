import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum WhimsicalButtonKind { petal, meadow, ghost, yolk }

class WhimsicalButton extends StatefulWidget {
  const WhimsicalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = WhimsicalButtonKind.petal,
    this.icon,
    this.expand = false,
    this.busy = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final WhimsicalButtonKind kind;
  final IconData? icon;
  final bool expand;
  final bool busy;
  final bool compact;

  @override
  State<WhimsicalButton> createState() => _WhimsicalButtonState();
}

class _WhimsicalButtonState extends State<WhimsicalButton> {
  var _down = false;

  Color get _bg => switch (widget.kind) {
        WhimsicalButtonKind.petal => AppColors.petal,
        WhimsicalButtonKind.meadow => AppColors.meadow,
        WhimsicalButtonKind.yolk => AppColors.yolk,
        WhimsicalButtonKind.ghost => AppColors.cloud,
      };

  Widget get _label => Text(
        widget.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        textAlign: TextAlign.center,
        style: AppTypography.button.copyWith(
          color: AppColors.ink,
          fontSize: widget.compact ? 14 : 16,
          fontWeight: widget.kind == WhimsicalButtonKind.ghost
              ? FontWeight.w500
              : FontWeight.w700,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.busy;
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: enabled
          ? () {
              setState(() => _down = false);
              widget.onPressed!();
            }
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: AnimatedContainer(
          duration: AppMotion.squish,
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, _down && widget.kind != WhimsicalButtonKind.ghost ? 3 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact
                ? 12
                : widget.kind == WhimsicalButtonKind.ghost
                    ? 16
                    : 18,
            vertical: widget.compact
                ? 10
                : widget.kind == WhimsicalButtonKind.ghost
                    ? 12
                    : 14,
          ),
          decoration: stickerFill(
            color: _bg,
            radius: AppRadii.button,
            pressed: _down,
            stroke: widget.kind == WhimsicalButtonKind.ghost ? AppStroke.inkThin : AppStroke.ink,
            elevated: widget.kind != WhimsicalButtonKind.ghost,
          ),
          alignment: Alignment.center,
          child: widget.busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.ink),
                )
              : Row(
                  mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: widget.compact ? 16 : 18, color: AppColors.ink),
                      SizedBox(width: widget.compact ? 6 : 8),
                    ],
                    if (widget.expand)
                      Expanded(child: _label)
                    else
                      _label,
                  ],
                ),
        ),
      ),
    );

    if (widget.expand) return SizedBox(width: double.infinity, child: child);
    return child;
  }
}
