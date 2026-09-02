import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';
import 'feedback.dart';

/// Circular shop logo, or a doodle cat when no logo has been uploaded.
class ShopMark extends StatelessWidget {
  const ShopMark({
    super.key,
    this.logoUrl,
    this.size = 52,
    this.fallback = CatPose.happy,
  });

  final String? logoUrl;
  final double size;
  final CatPose fallback;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim();
    if (url == null || url.isEmpty) {
      return FluffyCat(pose: fallback, size: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cloud,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.ink, width: AppStroke.inkThin),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: SmartProductImage(url: url, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
