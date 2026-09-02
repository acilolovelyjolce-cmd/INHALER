import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../data/cutout.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import 'cutout_sprite.dart';

/// Mix of the inhaler with the chosen cord and charms, sized from each sprite.
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
  late Future<Map<String, Size>> _metrics;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _metrics = _loadMetrics();
  }

  @override
  void didUpdateWidget(MixStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inhalerUrl != widget.inhalerUrl ||
        oldWidget.paracord?.id != widget.paracord?.id ||
        !_sameTrinkets(oldWidget.trinkets, widget.trinkets)) {
      _metrics = _loadMetrics();
    }
  }

  bool _sameTrinkets(List<ProductOption> a, List<ProductOption> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  List<String> get _urls {
    final cord = widget.paracord == null ? null : optionPreviewUrl(widget.paracord!);
    return [
      ?widget.inhalerUrl,
      ?cord,
      for (final item in widget.trinkets) ?optionPreviewUrl(item),
    ];
  }

  Future<Map<String, Size>> _loadMetrics() async {
    if (_urls.isEmpty) return {};
    final entries = await Future.wait([
      for (final url in _urls)
        CutoutCache.instance.load(url).then((bytes) => MapEntry(url, _sizeOf(bytes))),
    ]);
    return Map.fromEntries(entries);
  }

  Size _sizeOf(Uint8List bytes) {
    final pixels = pngPixelSize(bytes);
    return Size(pixels.$1.toDouble(), pixels.$2.toDouble());
  }

  double _aspect(Map<String, Size> metrics, String? url, double fallback) {
    if (url == null) return fallback;
    final size = metrics[url];
    if (size == null || size.height < 1) return fallback;
    return size.width / size.height;
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
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
          child: SizedBox(
            height: 184,
            width: double.infinity,
            child: Transform.translate(offset: Offset(0, bob), child: child),
          ),
        );
      },
      child: FutureBuilder<Map<String, Size>>(
        future: _metrics,
        builder: (context, snapshot) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return _compose(constraints, snapshot.data ?? const {});
            },
          );
        },
      ),
    );
  }

  Widget _compose(BoxConstraints constraints, Map<String, Size> metrics) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    final cordUrl = widget.paracord == null ? null : optionPreviewUrl(widget.paracord!);
    final picked = [
      for (final item in widget.trinkets)
        if (optionPreviewUrl(item) != null) (item.id, optionPreviewUrl(item)!),
    ];

    final inhalerAspect = _aspect(metrics, widget.inhalerUrl, 0.46);
    final cordAspect = _aspect(metrics, cordUrl, 2.5);
    final hasTopBits = cordUrl != null || picked.isNotEmpty;

    final headroom = hasTopBits ? h * 0.18 : h * 0.06;
    var inhalerH = (h - headroom) * 0.92;
    var inhalerW = inhalerH * inhalerAspect;
    final maxInhalerW = w * 0.30;
    if (inhalerW > maxInhalerW) {
      inhalerW = maxInhalerW;
      inhalerH = inhalerW / inhalerAspect;
    }

    final cx = w / 2;
    final inhalerLeft = cx - inhalerW / 2;
    final inhalerTop = headroom + ((h - headroom) - inhalerH) / 2;
    final inhalerLong = math.max(inhalerW, inhalerH);
    final minAccessory = inhalerLong * 0.75;
    final clip = Offset(cx, inhalerTop + inhalerH * 0.03);

    var cordW = 0.0;
    var cordH = 0.0;
    var cordLeft = 0.0;
    var cordTop = 0.0;
    if (cordUrl != null) {
      final sized = _sizeAtLeast(cordAspect, minAccessory);
      cordW = sized.width;
      cordH = sized.height;
      cordLeft = cx - cordW / 2;
      cordTop = clip.dy - cordH * 0.62;
    }

    final leftSlot = Offset(cx - inhalerW * 0.88, clip.dy - 2);
    final rightSlot = Offset(cx + inhalerW * 0.88, clip.dy - 2);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.inhalerUrl != null)
          _piece(
            left: inhalerLeft,
            top: inhalerTop,
            width: inhalerW,
            height: inhalerH,
            id: 'inhaler-${widget.inhalerUrl}',
            url: widget.inhalerUrl!,
          ),
        if (cordUrl != null)
          _piece(
            left: cordLeft,
            top: cordTop,
            width: cordW,
            height: cordH,
            id: 'cord-${widget.paracord!.id}',
            url: cordUrl,
            angle: -0.04,
          ),
        for (var i = 0; i < picked.length; i++)
          _placedTrinket(
            index: i,
            count: picked.length,
            url: picked[i].$2,
            id: picked[i].$1,
            aspect: _aspect(metrics, picked[i].$2, 0.9),
            inhalerW: inhalerW,
            inhalerH: inhalerH,
            clip: clip,
            leftSlot: leftSlot,
            rightSlot: rightSlot,
          ),
      ],
    );
  }

  Widget _placedTrinket({
    required int index,
    required int count,
    required String url,
    required String id,
    required double aspect,
    required double inhalerW,
    required double inhalerH,
    required Offset clip,
    required Offset leftSlot,
    required Offset rightSlot,
  }) {
    final minAccessory = math.max(inhalerW, inhalerH) * 0.75;
    final sized = _sizeAtLeast(aspect, minAccessory);
    final tw = sized.width;
    final th = sized.height;

    final attach = switch (count) {
      1 => rightSlot,
      2 => index == 0 ? leftSlot : rightSlot,
      _ => _along(
          [leftSlot, Offset(clip.dx, clip.dy - 10), rightSlot],
          count == 1 ? 1 : index / (count - 1),
        ),
    };

    return _piece(
      left: attach.dx - tw / 2,
      top: attach.dy - th * 0.78,
      width: tw,
      height: th,
      id: 't-$id',
      url: url,
      angle: (index - (count - 1) / 2) * 0.14,
    );
  }

  Size _sizeAtLeast(double aspect, double minLongSide) {
    final safeAspect = aspect <= 0 ? 1.0 : aspect;
    final width = safeAspect >= 1 ? minLongSide : minLongSide * safeAspect;
    final height = safeAspect >= 1 ? minLongSide / safeAspect : minLongSide;
    return Size(width, height);
  }

  Offset _along(List<Offset> points, double t) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1 || t <= 0) return points.first;
    if (t >= 1) return points.last;
    final scaled = t * (points.length - 1);
    final i = scaled.floor().clamp(0, points.length - 2);
    final local = scaled - i;
    return Offset.lerp(points[i], points[i + 1], local)!;
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
        tween: Tween(begin: 0.78, end: 1),
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
