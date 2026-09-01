import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class AtelierBackdrop extends StatelessWidget {
  const AtelierBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.blush,
      child: child,
    );
  }
}

class CreamPanel extends StatelessWidget {
  const CreamPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 28),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: stickerFill(color: AppColors.cloud, radius: AppRadii.panel),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.panel - 2),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
