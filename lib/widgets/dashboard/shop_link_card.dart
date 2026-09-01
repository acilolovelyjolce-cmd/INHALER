import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../platform/file_download.dart';
import '../../theme/tokens.dart';
import '../ui/whimsical_button.dart';
import '../ui/whimsical_card.dart';

class ShopLinkCard extends StatefulWidget {
  const ShopLinkCard({super.key, required this.url});

  final String url;

  @override
  State<ShopLinkCard> createState() => _ShopLinkCardState();
}

class _ShopLinkCardState extends State<ShopLinkCard> {
  final _qrKey = GlobalKey();

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied — go share it')),
    );
  }

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      'Shop my charms here:\n${widget.url}',
      subject: 'Whimsical shop',
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _downloadQr() async {
    final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    await downloadBytes(data.buffer.asUint8List(), 'whimsical-shop-qr.png', 'image/png');
  }

  @override
  Widget build(BuildContext context) {
    return WhimsicalCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 520;
          final qr = RepaintBoundary(
            key: _qrKey,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.cloud,
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: widget.url,
                size: 148,
                backgroundColor: AppColors.cloud,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.circle,
                  color: AppColors.plum,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.plum,
                ),
              ),
            ),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your public shop', style: AppTypography.title),
              const SizedBox(height: 6),
              Text(
                'Send this link to customers. They open it in Safari — they do not need the app.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 6),
              SelectableText(widget.url, style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  WhimsicalButton(label: 'Copy link', icon: Icons.copy, onPressed: _copy),
                  WhimsicalButton(
                    label: 'Share',
                    kind: WhimsicalButtonKind.ghost,
                    icon: Icons.ios_share,
                    onPressed: _share,
                  ),
                  WhimsicalButton(
                    label: 'Download QR',
                    kind: WhimsicalButtonKind.yolk,
                    icon: Icons.qr_code_2,
                    onPressed: _downloadQr,
                  ),
                ],
              ),
            ],
          );

          if (wide) {
            return Row(
              children: [
                qr,
                const SizedBox(width: 24),
                Expanded(child: details),
              ],
            );
          }
          return Column(
            children: [
              qr,
              const SizedBox(height: 16),
              details,
            ],
          );
        },
      ),
    );
  }
}
