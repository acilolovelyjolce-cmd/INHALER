import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import '../../data/api_client.dart';
import '../../data/cutout.dart';
import '../ui/feedback.dart';

class CutoutCache {
  CutoutCache._();
  static final CutoutCache instance = CutoutCache._();

  final _ready = <String, Uint8List>{};
  final _inflight = <String, Future<Uint8List>>{};

  Future<Uint8List> load(String url) {
    final key = 'v4:$url';
    final hit = _ready[key];
    if (hit != null) return Future.value(hit);
    return _inflight.putIfAbsent(key, () async {
      try {
        final raw = await _loadRaw(url);
        final cut = kIsWeb ? knockOutBackground(raw) : await compute(knockOutBackground, raw);
        _ready[key] = cut;
        return cut;
      } finally {
        _inflight.remove(key);
      }
    });
  }

  Future<Uint8List> _loadRaw(String url) async {
    if (url.startsWith('asset:')) {
      final path = url.replaceFirst('asset:', '');
      if (path.endsWith('.svg')) {
        final svg = _stripCardFill(await rootBundle.loadString(path));
        return _rasterizeSvg(SvgStringLoader(svg));
      }
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }

    final resolved = ApiClient.resolveMedia(url);
    final response = await http.get(Uri.parse(resolved));
    if (response.statusCode >= 400) {
      throw StateError('Could not load image');
    }
    if (resolved.toLowerCase().contains('.svg') ||
        (response.headers['content-type'] ?? '').contains('svg')) {
      return _rasterizeSvg(SvgStringLoader(_stripCardFill(response.body)));
    }
    return response.bodyBytes;
  }

  String _stripCardFill(String svg) {
    return svg
        .replaceFirst(
          RegExp(r'<rect\s+width="[^"]+"\s+height="[^"]+"[^>]*fill="#[^"]+"[^/]*/>\s*'),
          '',
        )
        .replaceFirst(
          RegExp(r'<ellipse[^>]*opacity="0\.0[0-9]+"[^/]*/>\s*'),
          '',
        );
  }

  Future<Uint8List> _rasterizeSvg(BytesLoader loader) async {
    final pictureInfo = await vg.loadPicture(loader, null);
    final size = pictureInfo.size;
    final width = 400;
    final height = (width * size.height / size.width).round().clamp(1, 640);
    final image = await pictureInfo.picture.toImage(width, height);
    pictureInfo.picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) throw StateError('Could not rasterize svg');
    return bytes.buffer.asUint8List();
  }
}

class CutoutSprite extends StatefulWidget {
  const CutoutSprite({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
  });

  final String url;
  final BoxFit fit;

  @override
  State<CutoutSprite> createState() => _CutoutSpriteState();
}

class _CutoutSpriteState extends State<CutoutSprite> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = CutoutCache.instance.load(widget.url);
  }

  @override
  void didUpdateWidget(CutoutSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _future = CutoutCache.instance.load(widget.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        final child = snapshot.hasData
            ? Image.memory(
                snapshot.data!,
                fit: widget.fit,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              )
            : snapshot.hasError
                ? SmartProductImage(url: widget.url, fit: widget.fit)
                : const ColoredBox(color: Colors.transparent);
        return SizedBox.expand(child: child);
      },
    );
  }
}
