import 'package:flutter/material.dart';

import '../../data/cutout.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../../theme/tokens.dart';
import 'cutout_sprite.dart';
import 'mix_layout.dart';

/// Mix of the inhaler with the chosen cord and charms. Buyers can drag,
/// rotate, and snap pieces into place.
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

  static Key pieceKey(String id) => ValueKey('mix-piece-$id');
  static Key rotateKey(String id) => ValueKey('mix-rotate-$id');
  static Key scaleKey(String id) => ValueKey('mix-scale-$id');
  static Key resetKey(String id) => ValueKey('mix-reset-$id');

  @override
  MixStageState createState() => MixStageState();
}

class MixStageState extends State<MixStage> {
  final _stageKey = GlobalKey();
  final _transforms = <String, MixTransform>{};
  final _metrics = <String, Size>{};
  var _order = <String>[];
  String? _selected;
  String? _dragging;
  int? _pointer;
  Offset? _rotateLast;
  Size _stage = Size.zero;

  String? _hit(Offset local, List<MixPiecePose> bases) {
    for (final id in _order.reversed) {
      final base = _baseById(id, bases);
      if (base == null) continue;
      final pose = base.applying(_transforms[id] ?? MixTransform.zero);
      final box = Rect.fromLTWH(pose.left, pose.top, pose.width, pose.height);
      if (box.contains(local)) return id;
    }
    return null;
  }

  @visibleForTesting
  Map<String, MixTransform> get debugTransforms => Map.unmodifiable(_transforms);

  @visibleForTesting
  String? get debugSelected => _selected;

  @visibleForTesting
  List<String> get debugOrder => List.unmodifiable(_order);

  MixSprite? get _inhaler {
    final url = widget.inhalerUrl;
    if (url == null) return null;
    return MixSprite(id: MixArrangement.inhalerId, url: url, kind: MixKind.inhaler);
  }

  MixSprite? get _cord {
    final option = widget.paracord;
    final url = option == null ? null : optionPreviewUrl(option);
    if (option == null || url == null) return null;
    return MixSprite(id: MixArrangement.cordId(option.id), url: url, kind: MixKind.cord);
  }

  List<MixSprite> get _trinketSprites {
    return [
      for (final item in widget.trinkets)
        if (optionPreviewUrl(item) != null)
          MixSprite(
            id: MixArrangement.trinketId(item.id),
            url: optionPreviewUrl(item)!,
            kind: MixKind.trinket,
          ),
    ];
  }

  List<String> get _liveIds => [
        if (_inhaler != null) _inhaler!.id,
        if (_cord != null) _cord!.id,
        for (final item in _trinketSprites) item.id,
      ];

  @override
  void initState() {
    super.initState();
    _order = _liveIds;
    _loadMetrics();
  }

  @override
  void didUpdateWidget(MixStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final live = _liveIds;
    final kept = MixArrangement.prune(_transforms, live);
    final nextOrder = [
      for (final id in _order) if (live.contains(id)) id,
      for (final id in live) if (!_order.contains(id)) id,
    ];
    _transforms
      ..clear()
      ..addAll(kept);
    _order = nextOrder;
    if (_selected != null && !live.contains(_selected)) _selected = null;
    if (oldWidget.inhalerUrl != widget.inhalerUrl ||
        oldWidget.paracord?.id != widget.paracord?.id ||
        !_sameTrinkets(oldWidget.trinkets, widget.trinkets)) {
      _loadMetrics();
    }
  }

  bool _sameTrinkets(List<ProductOption> a, List<ProductOption> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  Future<void> _loadMetrics() async {
    final urls = [
      if (_inhaler != null) _inhaler!.url,
      if (_cord != null) _cord!.url,
      for (final item in _trinketSprites) item.url,
    ];
    if (urls.isEmpty) return;
    final entries = await Future.wait([
      for (final url in urls)
        CutoutCache.instance.load(url).then((bytes) {
          final pixels = pngPixelSize(bytes);
          return MapEntry(url, Size(pixels.$1.toDouble(), pixels.$2.toDouble()));
        }),
    ]);
    if (!mounted) return;
    setState(() {
      _metrics
        ..clear()
        ..addAll(Map.fromEntries(entries));
    });
  }

  MixPiecePose? _baseById(String id, List<MixPiecePose> bases) {
    for (final pose in bases) {
      if (pose.id == id) return pose;
    }
    return null;
  }

  void _select(String id) {
    setState(() {
      _selected = id;
      _order = MixArrangement.bringToFront(_order, id);
    });
  }

  void _drag(String id, Offset delta, List<MixPiecePose> bases) {
    final base = _baseById(id, bases);
    if (base == null) return;
    setState(() {
      _selected = id;
      _order = MixArrangement.bringToFront(_order, id);
      _transforms[id] = MixArrangement.drag(
        base: base,
        current: _transforms[id] ?? MixTransform.zero,
        delta: delta,
        stage: _stage,
      );
    });
  }

  Offset _toStage(Offset global) {
    final box = _stageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    return box.globalToLocal(global);
  }

  void _scale(String id, Offset globalPointer, List<MixPiecePose> bases) {
    final base = _baseById(id, bases);
    if (base == null) return;
    final displayed = base.applying(_transforms[id] ?? MixTransform.zero);
    final pointer = _toStage(globalPointer);
    final last = _rotateLast ?? pointer;
    setState(() {
      _transforms[id] = MixArrangement.scaleByPointer(
        pieceCenter: displayed.center,
        lastPointer: last,
        pointer: pointer,
        current: _transforms[id] ?? MixTransform.zero,
      );
      _rotateLast = pointer;
    });
  }

  void _rotate(String id, Offset globalPointer, List<MixPiecePose> bases) {
    final base = _baseById(id, bases);
    if (base == null) return;
    final displayed = base.applying(_transforms[id] ?? MixTransform.zero);
    final pointer = _toStage(globalPointer);
    final last = _rotateLast ?? pointer;
    setState(() {
      _transforms[id] = MixArrangement.rotateByPointer(
        pieceCenter: displayed.center,
        lastPointer: last,
        pointer: pointer,
        current: _transforms[id] ?? MixTransform.zero,
      );
      _rotateLast = pointer;
    });
  }

  void _finish(String id, List<MixPiecePose> bases) {
    final base = _baseById(id, bases);
    if (base == null) return;
    final current = _transforms[id] ?? MixTransform.zero;
    final displayed = base.applying(current);
    MixPiecePose? inhaler;
    for (final pose in bases) {
      if (pose.kind == MixKind.inhaler) inhaler = pose.applying(_transforms[pose.id] ?? MixTransform.zero);
    }
    setState(() {
      _rotateLast = null;
      _transforms[id] = MixArrangement.snap(
        displayed: displayed,
        base: base,
        current: current,
        inhaler: inhaler,
        stage: _stage,
      );
    });
  }

  void _reset(String id) {
    setState(() {
      _transforms.remove(id);
      _rotateLast = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
      child: SizedBox(
        height: 184,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            _stage = Size(constraints.maxWidth, constraints.maxHeight);
            final bases = MixArrangement.defaults(
              stage: _stage,
              inhaler: _inhaler,
              cord: _cord,
              trinkets: _trinketSprites,
              metrics: _metrics,
            );
            final byId = {for (final pose in bases) pose.id: pose};
            final drawn = [
              for (final id in _order)
                if (byId[id] != null) byId[id]!,
            ];
            MixPiecePose? selectedPose;
            if (_selected != null) {
              final base = byId[_selected];
              if (base != null) {
                selectedPose = base.applying(_transforms[base.id] ?? MixTransform.zero);
              }
            }
            return Stack(
              key: _stageKey,
              clipBehavior: Clip.none,
              children: [
                for (final base in drawn)
                  _MixPiece(
                    key: MixStage.pieceKey(base.id),
                    pose: base.applying(_transforms[base.id] ?? MixTransform.zero),
                    selected: _selected == base.id,
                  ),
                Positioned.fill(
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (event) {
                      final id = _hit(_toStage(event.position), bases);
                      if (id == null) {
                        if (_selected != null) setState(() => _selected = null);
                        return;
                      }
                      _pointer = event.pointer;
                      _dragging = id;
                      _select(id);
                    },
                    onPointerMove: (event) {
                      if (event.pointer != _pointer || _dragging == null) return;
                      _drag(_dragging!, event.delta, bases);
                    },
                    onPointerUp: (event) {
                      if (event.pointer != _pointer) return;
                      if (_dragging != null) _finish(_dragging!, bases);
                      _pointer = null;
                      _dragging = null;
                    },
                    onPointerCancel: (event) {
                      if (event.pointer != _pointer) return;
                      _pointer = null;
                      _dragging = null;
                    },
                  ),
                ),
                if (selectedPose != null) ...[
                  Positioned(
                    left: selectedPose.left + selectedPose.width - 24,
                    top: selectedPose.top - 4,
                    child: Listener(
                      key: MixStage.rotateKey(selectedPose.id),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        _pointer = event.pointer;
                        _dragging = selectedPose!.id;
                        _rotateLast = _toStage(event.position);
                      },
                      onPointerMove: (event) {
                        if (event.pointer != _pointer) return;
                        _rotate(selectedPose!.id, event.position, bases);
                      },
                      onPointerUp: (event) {
                        if (event.pointer != _pointer) return;
                        _finish(selectedPose!.id, bases);
                        _pointer = null;
                        _dragging = null;
                      },
                      child: const _RoundTool(icon: Icons.rotate_right),
                    ),
                  ),
                  Positioned(
                    left: selectedPose.left + selectedPose.width - 24,
                    top: selectedPose.top + selectedPose.height - 24,
                    child: Listener(
                      key: MixStage.scaleKey(selectedPose.id),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) {
                        _pointer = event.pointer;
                        _dragging = selectedPose!.id;
                        _rotateLast = _toStage(event.position);
                      },
                      onPointerMove: (event) {
                        if (event.pointer != _pointer) return;
                        _scale(selectedPose!.id, event.position, bases);
                      },
                      onPointerUp: (event) {
                        if (event.pointer != _pointer) return;
                        _finish(selectedPose!.id, bases);
                        _pointer = null;
                        _dragging = null;
                      },
                      child: const _RoundTool(icon: Icons.open_in_full),
                    ),
                  ),
                  Positioned(
                    left: selectedPose.left - 4,
                    top: selectedPose.top - 4,
                    child: GestureDetector(
                      key: MixStage.resetKey(selectedPose.id),
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _reset(selectedPose!.id),
                      child: const _RoundTool(icon: Icons.replay),
                    ),
                  ),
                ],
                if (drawn.length > 1)
                  const Positioned(
                    left: 8,
                    right: 8,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Text(
                        'drag · twist to turn · pull the corner to size · rewind',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.kicker,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MixPiece extends StatelessWidget {
  const _MixPiece({
    super.key,
    required this.pose,
    required this.selected,
  });

  final MixPiecePose pose;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pose.left,
      top: pose.top,
      width: pose.width,
      height: pose.height,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: pose.angle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: selected
                  ? Border.all(color: AppColors.ink, width: AppStroke.inkThin)
                  : null,
            ),
            child: CutoutSprite(url: pose.url),
          ),
        ),
      ),
    );
  }
}

class _RoundTool extends StatelessWidget {
  const _RoundTool({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.yolk,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: AppStroke.inkThin),
      ),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 16, color: AppColors.ink),
      ),
    );
  }
}
