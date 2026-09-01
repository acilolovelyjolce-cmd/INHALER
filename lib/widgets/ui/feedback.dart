import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/api_client.dart';
import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';

class AnimatedCheck extends StatefulWidget {
  const AnimatedCheck({super.key, this.size = 64, this.play = true});

  final double size;
  final bool play;

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.play) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _CheckPainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.meadow
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.32);

    final metrics = path.computeMetrics().first;
    canvas.drawPath(metrics.extractPath(0, metrics.length * progress), paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class DinoLoading extends StatelessWidget {
  const DinoLoading({super.key, this.message = 'snoozing a sec…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FluffyCat(pose: CatPose.sleepy, size: 88)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: -6, end: 6, duration: 900.ms, curve: Curves.easeInOut)
              .scale(begin: const Offset(0.96, 1), end: const Offset(1.04, 1), duration: 900.ms),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class WhimsicalError extends StatelessWidget {
  const WhimsicalError({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  String get _copy {
    if (message.contains('already been listened')) {
      return 'The shop had a hiccup loading. Try again in a moment.';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FluffyCat(pose: CatPose.yell, size: 96),
              const SizedBox(height: 16),
              Text('ack!! a little tumble', style: AppTypography.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_copy, style: AppTypography.bodySmall, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WhimsicalEmpty extends StatelessWidget {
  const WhimsicalEmpty({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Column(
        children: [
          const FluffyCat(pose: CatPose.heart, size: 96),
          const SizedBox(height: 16),
          Text(title, style: AppTypography.displaySmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(body, style: AppTypography.bodySmall, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 12,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: AppColors.sky,
        shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.price,
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class ProductImageView extends StatelessWidget {
  const ProductImageView({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('asset:')) {
      final path = url.replaceFirst('asset:', '');
      if (path.endsWith('.svg')) {
        return Image.asset(
          path,
          fit: fit,
          errorBuilder: (context, error, stack) => const ColoredBox(color: AppColors.blush),
        );
      }
      return Image.asset(path, fit: fit);
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stack) => const ColoredBox(color: AppColors.blush),
    );
  }
}

/// Renders SVG product art via flutter_svg when the asset is svg.
class SmartProductImage extends StatelessWidget {
  const SmartProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('asset:') && url.endsWith('.svg')) {
      return SvgPicture.asset(
        url.replaceFirst('asset:', ''),
        fit: fit,
      );
    }
    return ProductImageView(url: ApiClient.resolveMedia(url), fit: fit);
  }
}
