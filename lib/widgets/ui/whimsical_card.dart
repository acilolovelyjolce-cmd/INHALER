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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.hover,
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hover && widget.onTap != null ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color ?? AppColors.cloud,
          borderRadius: AppRadii.cardBorder,
          boxShadow: AppShadows.card,
        ),
        clipBehavior: widget.clip ? Clip.antiAlias : Clip.none,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadii.cardBorder,
            splashColor: AppColors.petal.withValues(alpha: 0.16),
            highlightColor: AppColors.petal.withValues(alpha: 0.08),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
