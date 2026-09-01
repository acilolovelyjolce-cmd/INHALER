import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';

class AtelierBackdrop extends StatelessWidget {
  const AtelierBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.blush,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(left: -8, top: 56, child: Opacity(opacity: 0.85, child: FluffyCat(pose: CatPose.blueberry, size: 72))),
          const Positioned(right: -4, top: 100, child: Opacity(opacity: 0.9, child: FluffyCat(pose: CatPose.flower, size: 64))),
          const Positioned(left: 12, bottom: 28, child: Opacity(opacity: 0.8, child: FluffyCat(pose: CatPose.sleepy, size: 70))),
          const Positioned(right: 8, bottom: 72, child: Opacity(opacity: 0.85, child: FluffyCat(pose: CatPose.party, size: 68))),
          child,
        ],
      ),
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
      child: Padding(padding: padding, child: child),
    );
  }
}
