import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';

class WhimsicalAppBar extends StatelessWidget {
  const WhimsicalAppBar({
    super.key,
    required this.wordmark,
    this.trailing,
    this.scale = 1,
  });

  final String wordmark;
  final Widget? trailing;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 8),
      child: Row(
        children: [
          DinoMascot(size: 48 * scale),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              wordmark,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.displaySmall.copyWith(fontSize: 22 * scale),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
