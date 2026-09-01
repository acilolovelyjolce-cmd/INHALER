import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import 'cutout_sprite.dart';

/// Compact mix of the inhaler with the chosen cord and charms in front.
class MixStage extends StatefulWidget {
  const MixStage({
    super.key,
    required this.inhalerUrl,
    this.paracord,
    this.trinkets = const [],
  });

  final String? inhalerUrl;
  final ProductOption? paracord;
  final List<ProductOption> trinkets;

  @override
  State<MixStage> createState() => _MixStageState();
}

class _MixStageState extends State<MixStage> with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final bob = math.sin(_float.value * math.pi) * 3;
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          child: SizedBox(
            height: 108,
            width: double.infinity,
            child: Transform.translate(offset: Offset(0, bob), child: child),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final inhalerW = math.min(64.0, w * 0.2);
          final inhalerH = h * 0.88;
          final cordUrl = widget.paracord == null ? null : optionPreviewUrl(widget.paracord!);
          final hasCord = cordUrl != null;
          final cx = w / 2;
          final cy = h / 2 + (hasCord ? -4 : 2);
          final picked = [
            for (final item in widget.trinkets)
              if (optionPreviewUrl(item) != null) (item.id, optionPreviewUrl(item)!),
          ];
          final cordW = inhalerW * 1.7;
          final cordH = inhalerH * 0.34;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.inhalerUrl != null)
                _piece(
                  left: cx - inhalerW / 2,
                  top: cy - inhalerH / 2,
                  width: inhalerW,
                  height: inhalerH,
                  id: 'inhaler-${widget.inhalerUrl}',
                  url: widget.inhalerUrl!,
                ),
              if (hasCord)
                _piece(
                  left: cx - cordW / 2,
                  top: cy + inhalerH * 0.16,
                  width: cordW,
                  height: cordH,
                  id: 'cord-${widget.paracord!.id}',
                  url: cordUrl,
                  angle: -0.06,
                ),
              for (var i = 0; i < picked.length; i++)
                _trinket(
                  index: i,
                  count: picked.length,
                  cx: cx + inhalerW * 0.18,
                  cy: cy - inhalerH * 0.22,
                  span: math.min(w * 0.16, 52),
                  url: picked[i].$2,
                  id: picked[i].$1,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _trinket({
    required int index,
    required int count,
    required double cx,
    required double cy,
    required double span,
    required String url,
    required String id,
  }) {
    final t = count == 1 ? 0.0 : (index / (count - 1)) * 2 - 1;
    final angle = t * 0.9;
    final dx = math.sin(angle) * span;
    final dy = -4 + (1 - math.cos(angle)) * 14;
    return _piece(
      left: cx + dx - 22,
      top: cy + dy - 22,
      width: 44,
      height: 44,
      id: 't-$id',
      url: url,
      angle: angle * 0.28,
    );
  }

  Widget _piece({
    required double left,
    required double top,
    required double width,
    required double height,
    required String id,
    required String url,
    double angle = 0,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      width: width,
      height: height,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(id),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.72, end: 1),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: value, child: child),
          );
        },
        child: CutoutSprite(url: url),
      ),
    );
  }
}
