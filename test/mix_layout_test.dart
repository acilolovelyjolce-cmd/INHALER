import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:whimsical_hub/widgets/storefront/mix_layout.dart';

void main() {
  const stage = Size(390, 184);

  MixSprite inhaler() => const MixSprite(
        id: MixArrangement.inhalerId,
        url: 'asset:inhaler',
        kind: MixKind.inhaler,
      );

  MixSprite cord() => MixSprite(
        id: MixArrangement.cordId('mint'),
        url: 'asset:cord',
        kind: MixKind.cord,
      );

  MixSprite charm(String id) => MixSprite(
        id: MixArrangement.trinketId(id),
        url: 'asset:$id',
        kind: MixKind.trinket,
      );

  test('inhaler sits in the middle of the stage', () {
    final poses = MixArrangement.defaults(stage: stage, inhaler: inhaler());
    expect(poses, hasLength(1));
    expect(poses.first.center.dx, closeTo(stage.width / 2, 0.5));
    expect(poses.first.width, lessThan(stage.width * 0.4));
  });

  test('paracord and trinkets are at least 75 percent as large as the inhaler', () {
    final poses = MixArrangement.defaults(
      stage: stage,
      inhaler: inhaler(),
      cord: cord(),
      trinkets: [charm('rex')],
    );
    final body = poses.firstWhere((pose) => pose.kind == MixKind.inhaler);
    final loop = poses.firstWhere((pose) => pose.kind == MixKind.cord);
    final trinket = poses.firstWhere((pose) => pose.kind == MixKind.trinket);
    expect(loop.longSide, greaterThanOrEqualTo(body.longSide * kMixAccessoryMinScale - 0.01));
    expect(trinket.longSide, greaterThanOrEqualTo(body.longSide * kMixAccessoryMinScale - 0.01));
  });

  test('two trinkets sit on opposite sides of the clip', () {
    final poses = MixArrangement.defaults(
      stage: stage,
      inhaler: inhaler(),
      trinkets: [charm('rex'), charm('stego')],
    );
    final left = poses.firstWhere((pose) => pose.id.endsWith('rex'));
    final right = poses.firstWhere((pose) => pose.id.endsWith('stego'));
    expect(left.center.dx, lessThan(stage.width / 2));
    expect(right.center.dx, greaterThan(stage.width / 2));
  });

  test('drag adds the pointer delta', () {
    final base = MixArrangement.defaults(stage: stage, inhaler: inhaler()).single;
    final moved = MixArrangement.drag(
      base: base,
      current: MixTransform.zero,
      delta: const Offset(24, -10),
      stage: stage,
    );
    expect(moved.dx, closeTo(24, 0.01));
    expect(moved.dy, closeTo(-10, 0.01));
  });

  test('clamp keeps a sliver of the piece on the stage', () {
    final base = MixArrangement.defaults(stage: stage, inhaler: inhaler()).single;
    final flung = MixArrangement.drag(
      base: base,
      current: MixTransform.zero,
      delta: const Offset(4000, 4000),
      stage: stage,
    );
    final placed = base.applying(flung);
    expect(placed.left, lessThan(stage.width));
    expect(placed.top, lessThan(stage.height));
    expect(placed.left + placed.width, greaterThan(0));
    expect(placed.top + placed.height, greaterThan(0));
  });

  test('snap aligns a nearly-centered piece to the stage axes', () {
    final base = MixArrangement.defaults(stage: stage, inhaler: inhaler()).single;
    final nudged = MixArrangement.drag(
      base: base,
      current: MixTransform.zero,
      delta: const Offset(8, 8),
      stage: stage,
    );
    final snapped = MixArrangement.snap(
      displayed: base.applying(nudged),
      base: base,
      current: nudged,
      stage: stage,
    );
    expect(snapped.dx, closeTo(0, 0.01));
    expect(snapped.dy, closeTo(0, 0.01));
  });

  test('snap straightens a tiny rotation', () {
    final base = MixArrangement.defaults(stage: stage, inhaler: inhaler()).single;
    final tilted = const MixTransform(dAngle: 0.05);
    final snapped = MixArrangement.snap(
      displayed: base.applying(tilted),
      base: base,
      current: tilted,
      stage: stage,
    );
    expect(snapped.dAngle, 0);
  });

  test('snap lines a charm up with the inhaler when close', () {
    final poses = MixArrangement.defaults(
      stage: stage,
      inhaler: inhaler(),
      trinkets: [charm('rex')],
    );
    final body = poses.firstWhere((pose) => pose.kind == MixKind.inhaler);
    final charmPose = poses.firstWhere((pose) => pose.kind == MixKind.trinket);
    final toward = Offset(
      body.center.dx - charmPose.center.dx + 4,
      body.center.dy - charmPose.center.dy + 3,
    );
    final dragged = MixArrangement.drag(
      base: charmPose,
      current: MixTransform.zero,
      delta: toward,
      stage: stage,
    );
    final snapped = MixArrangement.snap(
      displayed: charmPose.applying(dragged),
      base: charmPose,
      current: dragged,
      inhaler: body,
      stage: stage,
    );
    final aligned = charmPose.applying(snapped);
    expect(aligned.center.dx, closeTo(body.center.dx, 0.5));
    expect(aligned.center.dy, closeTo(body.center.dy, 0.5));
  });

  test('rotate follows the pointer around the piece center', () {
    const center = Offset(100, 100);
    final rotated = MixArrangement.rotateByPointer(
      pieceCenter: center,
      lastPointer: const Offset(100, 40),
      pointer: const Offset(160, 100),
      current: MixTransform.zero,
    );
    expect(rotated.dAngle, closeTo(math.pi / 2, 0.001));
  });

  test('rotate does not jump when the pointer crosses the wrap', () {
    const center = Offset(0, 0);
    final rotated = MixArrangement.rotateByPointer(
      pieceCenter: center,
      lastPointer: const Offset(-10, 1),
      pointer: const Offset(-10, -1),
      current: MixTransform.zero,
    );
    expect(rotated.dAngle.abs(), lessThan(0.5));
  });

  test('pulling the corner away from the piece makes it larger', () {
    const center = Offset(100, 100);
    final grown = MixArrangement.scaleByPointer(
      pieceCenter: center,
      lastPointer: const Offset(130, 100),
      pointer: const Offset(160, 100),
      current: MixTransform.zero,
    );
    expect(grown.scale, closeTo(2.0, 0.001));
  });

  test('scale stays within the min and max', () {
    const center = Offset(0, 0);
    final tiny = MixArrangement.scaleByPointer(
      pieceCenter: center,
      lastPointer: const Offset(100, 0),
      pointer: const Offset(1, 0),
      current: MixTransform.zero,
    );
    expect(tiny.scale, kMixMinScale);
    final huge = MixArrangement.scaleByPointer(
      pieceCenter: center,
      lastPointer: const Offset(10, 0),
      pointer: const Offset(80, 0),
      current: MixTransform.zero,
    );
    expect(huge.scale, kMixMaxScale);
  });

  test('applying a scale keeps the piece center', () {
    final base = MixArrangement.defaults(stage: stage, inhaler: inhaler()).single;
    final scaled = base.applying(const MixTransform(scale: 1.5));
    expect(scaled.center.dx, closeTo(base.center.dx, 0.01));
    expect(scaled.center.dy, closeTo(base.center.dy, 0.01));
    expect(scaled.width, closeTo(base.width * 1.5, 0.01));
  });

  test('prune drops poses for parts that left the mix', () {
    final next = MixArrangement.prune(
      {
        MixArrangement.inhalerId: const MixTransform(dx: 8),
        MixArrangement.cordId('mint'): const MixTransform(dy: 4),
        MixArrangement.trinketId('rex'): const MixTransform(dAngle: 0.2),
      },
      [MixArrangement.inhalerId, MixArrangement.trinketId('rex')],
    );
    expect(next.containsKey(MixArrangement.cordId('mint')), isFalse);
    expect(next[MixArrangement.inhalerId]!.dx, 8);
    expect(next[MixArrangement.trinketId('rex')]!.dAngle, 0.2);
  });

  test('bringToFront stacks the chosen piece last', () {
    expect(
      MixArrangement.bringToFront(['inhaler', 'cord-mint', 'trinket-rex'], 'cord-mint'),
      ['inhaler', 'trinket-rex', 'cord-mint'],
    );
  });

  test('sizeAtLeast keeps the requested long side', () {
    final wide = MixArrangement.sizeAtLeast(2, 80);
    expect(wide.width, 80);
    expect(wide.height, 40);
    final tall = MixArrangement.sizeAtLeast(0.5, 80);
    expect(tall.height, 80);
    expect(tall.width, 40);
  });
}
