import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/tokens.dart';
import 'cutout_sprite.dart';

class MixStage extends StatelessWidget {
  const MixStage({
    super.key,
    required this.inhalerUrl,
    this.paracord,
    this.trinkets = const [],
  });

  final String? inhalerUrl;
  final ProductOption? paracord;
  final List<ProductOption> trinkets;

  static const _trinketSeats = <Alignment>[
    Alignment(0.78, -0.08),
    Alignment(-0.72, 0.18),
    Alignment(0.62, 0.58),
    Alignment(-0.55, -0.42),
    Alignment(0.82, 0.28),
    Alignment(-0.78, 0.58),
  ];

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.32).clamp(200.0, 280.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR LOOK', style: AppTypography.kicker),
          const SizedBox(height: 12),
          SizedBox(
            height: height,
            width: double.infinity,
            child: DecoratedBox(
              decoration: stickerFill(color: AppColors.cloud, radius: AppRadii.image),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.image - 4),
                child: ColoredBox(
                  color: const Color(0xFFFFF6FB),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      if (paracord?.imageUrl != null)
                        Align(
                          alignment: const Alignment(0, 0.62),
                          child: FractionallySizedBox(
                            widthFactor: 0.78,
                            heightFactor: 0.42,
                            child: Transform.rotate(
                              angle: -0.16,
                              child: _PopIn(
                                id: 'cord-${paracord!.id}',
                                child: CutoutSprite(url: paracord!.imageUrl!),
                              ),
                            ),
                          ),
                        ),
                      Align(
                        alignment: const Alignment(0, -0.12),
                        child: FractionallySizedBox(
                          widthFactor: 0.58,
                          heightFactor: 0.78,
                          child: inhalerUrl == null
                              ? const ColoredBox(color: Colors.transparent)
                              : _PopIn(
                                  id: 'inhaler-$inhalerUrl',
                                  child: CutoutSprite(url: inhalerUrl!),
                                ),
                        ),
                      ),
                      for (var i = 0; i < trinkets.length; i++)
                        if (trinkets[i].imageUrl != null)
                          Align(
                            alignment: _trinketSeats[i % _trinketSeats.length],
                            child: SizedBox(
                              width: 78,
                              height: 78,
                              child: _PopIn(
                                id: 't-${trinkets[i].id}',
                                child: CutoutSprite(url: trinkets[i].imageUrl!),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopIn extends StatelessWidget {
  const _PopIn({required this.id, required this.child});

  final String id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(id),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.82, end: 1),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }
}
