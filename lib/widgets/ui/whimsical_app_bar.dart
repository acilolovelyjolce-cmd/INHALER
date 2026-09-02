import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';
import 'shop_mark.dart';

class WhimsicalAppBar extends StatelessWidget {
  const WhimsicalAppBar({
    super.key,
    required this.wordmark,
    this.logoUrl,
    this.trailing,
    this.scale = 1,
  });

  final String wordmark;
  final String? logoUrl;
  final Widget? trailing;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      child: Row(
        children: [
          ShopMark(logoUrl: logoUrl, size: 48 * scale, fallback: CatPose.happy),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              wordmark,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(fontSize: 18 * scale, height: 1.15),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
