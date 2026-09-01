import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/tokens.dart';
import '../doodles/dino_mascot.dart';
import '../ui/whimsical_app_bar.dart';

class IntroOrchestrator extends StatefulWidget {
  const IntroOrchestrator({
    super.key,
    required this.wordmark,
    required this.child,
    required this.hasPlayedIntro,
    required this.onIntroComplete,
    this.headerTrailing,
  });

  final String wordmark;
  final Widget child;
  final bool hasPlayedIntro;
  final VoidCallback onIntroComplete;
  final Widget? headerTrailing;

  @override
  State<IntroOrchestrator> createState() => _IntroOrchestratorState();
}

class _IntroOrchestratorState extends State<IntroOrchestrator>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1500);

  late final AnimationController _introController;
  late final AnimationController _mascotController;
  var _completed = false;
  var _mascotStarted = false;
  var _reducedMotion = false;
  var _started = false;

  late final Animation<double> _blushFade;
  late final Animation<double> _wordmarkT;
  late final Animation<double> _settle;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(vsync: this, duration: _duration);
    _mascotController = AnimationController.unbounded(vsync: this);

    _blushFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
    );
    _wordmarkT = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.133, 0.467, curve: Curves.easeOutCubic),
    );
    _settle = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.667, 1.0, curve: Curves.easeInOutCubic),
    );
    _contentFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.667, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_contentFade);

    if (widget.hasPlayedIntro) {
      _completed = true;
      _mascotStarted = true;
      _introController.value = 1;
      _mascotController.value = 1;
    } else {
      _mascotController.value = 0;
      _introController.addListener(_maybeStartMascot);
      _introController.addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    if (!_started && !widget.hasPlayedIntro) {
      _started = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_reducedMotion) {
          _mascotStarted = true;
          _mascotController.value = 1;
          _introController.duration = AppMotion.reduced;
        }
        _introController.forward();
      });
    }
  }

  void _maybeStartMascot() {
    if (_mascotStarted || _reducedMotion) return;
    if (_introController.value >= 0.333) {
      _mascotStarted = true;
      const spring = SpringDescription(mass: 1, stiffness: 180, damping: 12);
      _mascotController.animateWith(SpringSimulation(spring, 0, 1, 0));
    }
  }

  void _skip() {
    _introController
      ..stop()
      ..value = 1;
    _mascotController
      ..stop()
      ..value = 1;
    _finish();
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onIntroComplete();
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final reduced = MediaQuery.disableAnimationsOf(context);

    if (_completed) {
      return ColoredBox(
        color: AppColors.blush,
        child: Column(
          children: [
            SizedBox(height: padding.top),
            WhimsicalAppBar(
              wordmark: widget.wordmark,
              trailing: widget.headerTrailing,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _completed ? null : _skip,
      child: AnimatedBuilder(
        animation: Listenable.merge([_introController, _mascotController]),
        builder: (context, _) {
          final blushT = reduced && !_completed ? _introController.value : _blushFade.value;
          final bg = Color.lerp(Colors.white, AppColors.blush, blushT)!;

          return ColoredBox(
            color: bg,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                final headerTop = padding.top + 4;
                const groupWidth = 280.0;
                const groupHeight = 88.0;
                final center = Offset(
                  (size.width - groupWidth) / 2,
                  (size.height - groupHeight) / 2,
                );
                final header = Offset(12, headerTop);
                final settleT = reduced ? 1.0 : _settle.value;
                final pos = Offset.lerp(center, header, settleT)!;
                final groupScale = lerpDouble(1.0, 0.62, settleT)!;
                final wordT = _wordmarkT.value;
                final wordScale = lerpDouble(0.85, 1.0, wordT)!;
                final sigma = lerpDouble(8, 0, wordT)!;
                final mascotT = _mascotController.value;
                final hopX = (1 - mascotT) * -120;
                final hopY = (1 - mascotT) * 18 * (1 - mascotT) * 8 -
                    (mascotT < 1 ? (1 - mascotT) * 10 * (0.5 - (mascotT - 0.5).abs()) : 0);

                final wordmark = ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _completed ? 0 : sigma,
                    sigmaY: _completed ? 0 : sigma,
                  ),
                  child: Text(
                    widget.wordmark,
                    style: AppTypography.displayLarge.copyWith(fontSize: 44),
                  ),
                )
                    .animate(controller: _introController, autoPlay: false)
                    .scale(
                      begin: const Offset(0.85, 0.85),
                      end: const Offset(1, 1),
                      delay: 200.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    );

                final flying = Transform.translate(
                  offset: pos,
                  child: Transform.scale(
                    alignment: Alignment.topLeft,
                    scale: groupScale,
                    child: SizedBox(
                      width: size.width - 24,
                      height: groupHeight,
                      child: Row(
                        children: [
                          Transform.translate(
                            offset: Offset(hopX, hopY),
                            child: const DinoMascot(size: 72),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Transform.scale(
                              scale: _completed ? 1 : wordScale,
                              child: wordmark,
                            ),
                          ),
                          if (settleT > 0.85 && widget.headerTrailing != null)
                            Opacity(
                              opacity: ((settleT - 0.85) / 0.15).clamp(0, 1),
                              child: widget.headerTrailing,
                            ),
                        ],
                      ),
                    ),
                  ),
                );

                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: padding.top + AppLayout.headerHeight),
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: widget.child,
                        ),
                      ),
                    ),
                    flying,
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
