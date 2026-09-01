import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class WhimsicalCard extends StatefulWidget {
  const WhimsicalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool clip;

  @override
  State<WhimsicalCard> createState() => _WhimsicalCardState();
}

class _WhimsicalCardState extends State<WhimsicalCard> {
  var _hover = false;
  var _down = false;

  @override
  Widget build(BuildContext context) {
    final pressed = _down || (_hover && widget.onTap != null);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) {
                setState(() => _down = false);
                widget.onTap!();
              },
        onTapCancel: widget.onTap == null ? null : () => setState(() => _down = false),
        child: AnimatedContainer(
          duration: AppMotion.squish,
          curve: Curves.easeOutBack,
          transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
          decoration: stickerFill(
            color: widget.color ?? AppColors.cloud,
            pressed: _down,
          ),
          clipBehavior: widget.clip ? Clip.antiAlias : Clip.none,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
