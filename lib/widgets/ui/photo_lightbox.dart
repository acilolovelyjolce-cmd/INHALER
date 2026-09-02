import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../storefront/cutout_sprite.dart';

Future<void> showPhotoLightbox(
  BuildContext context, {
  required String url,
  String? title,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close photo',
    barrierColor: AppColors.plum.withValues(alpha: 0.55),
    pageBuilder: (context, animation, secondary) {
      return PhotoLightbox(url: url, title: title);
    },
  );
}

class PhotoLightbox extends StatelessWidget {
  const PhotoLightbox({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final caption = title?.trim();
    return Material(
      key: const ValueKey('photo-lightbox'),
      color: AppColors.blush,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 56, 12, 72),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 5,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: ColoredBox(
                          color: AppColors.cloud,
                          child: CutoutSprite(url: url),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cloud,
                  foregroundColor: AppColors.plum,
                  side: const BorderSide(color: AppColors.ink, width: AppStroke.inkThin),
                ),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            if (caption != null && caption.isNotEmpty)
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
