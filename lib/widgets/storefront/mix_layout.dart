import 'dart:math' as math;
import 'dart:ui';

const kMixAccessoryMinScale = 0.75;
const kMixSnap = 12.0;
const kMixAlignAngle = 0.12;

enum MixKind { inhaler, cord, trinket }

class MixSprite {
  const MixSprite({
    required this.id,
    required this.url,
    required this.kind,
  });

  final String id;
  final String url;
  final MixKind kind;
}

class MixTransform {
  const MixTransform({this.dx = 0, this.dy = 0, this.dAngle = 0});

  static const zero = MixTransform();

  final double dx;
  final double dy;
  final double dAngle;

  bool get isIdentity => dx == 0 && dy == 0 && dAngle == 0;

  MixTransform copyWith({double? dx, double? dy, double? dAngle}) {
    return MixTransform(
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      dAngle: dAngle ?? this.dAngle,
    );
  }
}

class MixPiecePose {
  const MixPiecePose({
    required this.id,
    required this.url,
    required this.kind,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    this.angle = 0,
  });

  final String id;
  final String url;
  final MixKind kind;
  final double left;
  final double top;
  final double width;
  final double height;
  final double angle;

  Offset get center => Offset(left + width / 2, top + height / 2);
  double get longSide => math.max(width, height);

  MixPiecePose applying(MixTransform transform) {
    return MixPiecePose(
      id: id,
      url: url,
      kind: kind,
      left: left + transform.dx,
      top: top + transform.dy,
      width: width,
      height: height,
      angle: angle + transform.dAngle,
    );
  }
}

abstract final class MixArrangement {
  static const inhalerId = 'inhaler';

  static String cordId(String optionId) => 'cord-$optionId';
  static String trinketId(String optionId) => 'trinket-$optionId';

  static double aspectOf(Map<String, Size> metrics, String? url, double fallback) {
    if (url == null) return fallback;
    final size = metrics[url];
    if (size == null || size.height < 1) return fallback;
    return size.width / size.height;
  }

  static Size sizeAtLeast(double aspect, double minLongSide) {
    final safeAspect = aspect <= 0 ? 1.0 : aspect;
    final width = safeAspect >= 1 ? minLongSide : minLongSide * safeAspect;
    final height = safeAspect >= 1 ? minLongSide / safeAspect : minLongSide;
    return Size(width, height);
  }

  static List<MixPiecePose> defaults({
    required Size stage,
    required MixSprite? inhaler,
    MixSprite? cord,
    List<MixSprite> trinkets = const [],
    Map<String, Size> metrics = const {},
  }) {
    final w = stage.width;
    final h = stage.height;
    final hasTopBits = cord != null || trinkets.isNotEmpty;
    final headroom = hasTopBits ? h * 0.18 : h * 0.06;

    final inhalerAspect = aspectOf(metrics, inhaler?.url, 0.46);
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
    final clip = Offset(cx, inhalerTop + inhalerH * 0.03);
    final minAccessory = math.max(inhalerW, inhalerH) * kMixAccessoryMinScale;

    final poses = <MixPiecePose>[];
    if (inhaler != null) {
      poses.add(
        MixPiecePose(
          id: inhaler.id,
          url: inhaler.url,
          kind: MixKind.inhaler,
          left: inhalerLeft,
          top: inhalerTop,
          width: inhalerW,
          height: inhalerH,
        ),
      );
    }

    if (cord != null) {
      final sized = sizeAtLeast(aspectOf(metrics, cord.url, 2.5), minAccessory);
      poses.add(
        MixPiecePose(
          id: cord.id,
          url: cord.url,
          kind: MixKind.cord,
          left: cx - sized.width / 2,
          top: clip.dy - sized.height * 0.62,
          width: sized.width,
          height: sized.height,
          angle: -0.04,
        ),
      );
    }

    final leftSlot = Offset(cx - inhalerW * 0.88, clip.dy - 2);
    final rightSlot = Offset(cx + inhalerW * 0.88, clip.dy - 2);
    for (var i = 0; i < trinkets.length; i++) {
      final item = trinkets[i];
      final sized = sizeAtLeast(aspectOf(metrics, item.url, 0.9), minAccessory);
      final attach = switch (trinkets.length) {
        1 => rightSlot,
        2 => i == 0 ? leftSlot : rightSlot,
        _ => _along(
            [leftSlot, Offset(clip.dx, clip.dy - 10), rightSlot],
            i / (trinkets.length - 1),
          ),
      };
      poses.add(
        MixPiecePose(
          id: item.id,
          url: item.url,
          kind: MixKind.trinket,
          left: attach.dx - sized.width / 2,
          top: attach.dy - sized.height * 0.78,
          width: sized.width,
          height: sized.height,
          angle: (i - (trinkets.length - 1) / 2) * 0.14,
        ),
      );
    }
    return poses;
  }

  static MixTransform drag({
    required MixPiecePose base,
    required MixTransform current,
    required Offset delta,
    required Size stage,
  }) {
    return clamp(
      base: base,
      current: current.copyWith(
        dx: current.dx + delta.dx,
        dy: current.dy + delta.dy,
      ),
      stage: stage,
    );
  }

  static MixTransform rotateByPointer({
    required Offset pieceCenter,
    required Offset lastPointer,
    required Offset pointer,
    required MixTransform current,
  }) {
    final last = math.atan2(lastPointer.dy - pieceCenter.dy, lastPointer.dx - pieceCenter.dx);
    final now = math.atan2(pointer.dy - pieceCenter.dy, pointer.dx - pieceCenter.dx);
    var delta = now - last;
    if (delta > math.pi) delta -= math.pi * 2;
    if (delta < -math.pi) delta += math.pi * 2;
    return current.copyWith(dAngle: current.dAngle + delta);
  }

  static MixTransform snap({
    required MixPiecePose displayed,
    required MixPiecePose base,
    required MixTransform current,
    MixPiecePose? inhaler,
    required Size stage,
  }) {
    var dx = current.dx;
    var dy = current.dy;
    var dAngle = current.dAngle;
    final targetsX = <double>[base.center.dx, stage.width / 2];
    final targetsY = <double>[base.center.dy, stage.height / 2];
    if (inhaler != null && displayed.id != inhaler.id) {
      targetsX.add(inhaler.center.dx);
      targetsY.add(inhaler.center.dy);
    }

    dx += _nearestSnap(displayed.center.dx, targetsX);
    dy += _nearestSnap(displayed.center.dy, targetsY);

    if (dAngle.abs() < kMixAlignAngle) dAngle = 0;

    return clamp(
      base: base,
      current: MixTransform(dx: dx, dy: dy, dAngle: dAngle),
      stage: stage,
    );
  }

  static MixTransform clamp({
    required MixPiecePose base,
    required MixTransform current,
    required Size stage,
  }) {
    final placed = base.applying(current);
    const margin = 8.0;
    final left = placed.left.clamp(margin - placed.width, stage.width - margin);
    final top = placed.top.clamp(margin - placed.height, stage.height - margin);
    return current.copyWith(
      dx: left - base.left,
      dy: top - base.top,
    );
  }

  static Map<String, MixTransform> prune(
    Map<String, MixTransform> current,
    Iterable<String> liveIds,
  ) {
    final live = liveIds.toSet();
    return {
      for (final entry in current.entries)
        if (live.contains(entry.key)) entry.key: entry.value,
    };
  }

  static List<String> bringToFront(List<String> order, String id) {
    final next = [for (final item in order) if (item != id) item];
    if (order.contains(id)) next.add(id);
    return next;
  }

  static double _nearestSnap(double value, List<double> targets) {
    double? best;
    for (final target in targets) {
      final delta = target - value;
      if (delta.abs() <= kMixSnap && (best == null || delta.abs() < best.abs())) {
        best = delta;
      }
    }
    return best ?? 0;
  }

  static Offset _along(List<Offset> points, double t) {
    if (points.isEmpty) return Offset.zero;
    if (points.length == 1 || t <= 0) return points.first;
    if (t >= 1) return points.last;
    final scaled = t * (points.length - 1);
    final i = scaled.floor().clamp(0, points.length - 2);
    final local = scaled - i;
    return Offset.lerp(points[i], points[i + 1], local)!;
  }
}
