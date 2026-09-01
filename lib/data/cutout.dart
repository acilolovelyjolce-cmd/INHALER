import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Floods in from the edges so paper, studio, and rounded-card fills drop out.
/// Isolated objects on a transparent canvas are cropped, not eaten.
Uint8List knockOutBackground(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var image = decoded;
  const maxSide = 480;
  if (image.width > maxSide || image.height > maxSide) {
    final scale = maxSide / math.max(image.width, image.height);
    image = img.copyResize(
      image,
      width: (image.width * scale).round().clamp(1, maxSide),
      height: (image.height * scale).round().clamp(1, maxSide),
      interpolation: img.Interpolation.linear,
    );
  }
  image = image.convert(numChannels: 4);

  final width = image.width;
  final height = image.height;
  if (width < 4 || height < 4) return bytes;

  final seed = _edgeFillSeed(image);
  if (seed != null) {
    final before = image.clone();
    _floodKnockout(image, seed);
    final lost = _opaqueLostFraction(before, image);
    if (lost < 0.08 || lost > 0.97) {
      image = before;
    }
  }

  final cropped = _cropToOpaque(image);
  return Uint8List.fromList(img.encodePng(cropped));
}

void _floodKnockout(img.Image image, (int, int, int) seed) {
  final width = image.width;
  final height = image.height;
  const hardSq = 52 * 52;
  const softSq = 78 * 78;

  final visited = List<bool>.filled(width * height, false);
  final queue = Queue<int>();

  void offer(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final i = y * width + x;
    if (visited[i]) return;
    visited[i] = true;
    final pixel = image.getPixel(x, y);
    final dist = _distSq(pixel, seed.$1, seed.$2, seed.$3);
    if (pixel.a < 24) {
      queue.addLast(i);
      return;
    }
    if (dist > softSq) return;
    final alpha = dist <= hardSq ? 0 : ((dist - hardSq) * 255 / (softSq - hardSq)).round().clamp(0, 255);
    image.setPixelRgba(x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), alpha);
    if (alpha < 200) queue.addLast(i);
  }

  for (var x = 0; x < width; x++) {
    offer(x, 0);
    offer(x, height - 1);
  }
  for (var y = 0; y < height; y++) {
    offer(0, y);
    offer(width - 1, y);
  }

  while (queue.isNotEmpty) {
    final i = queue.removeFirst();
    final x = i % width;
    final y = i ~/ width;
    offer(x - 1, y);
    offer(x + 1, y);
    offer(x, y - 1);
    offer(x, y + 1);
  }
}

double _opaqueLostFraction(img.Image before, img.Image after) {
  var opaque = 0;
  var lost = 0;
  for (var y = 0; y < before.height; y++) {
    for (var x = 0; x < before.width; x++) {
      if (before.getPixel(x, y).a < 28) continue;
      opaque++;
      if (after.getPixel(x, y).a < 28) lost++;
    }
  }
  if (opaque == 0) return 0;
  return lost / opaque;
}

(int, int, int)? _edgeFillSeed(img.Image image) {
  final samples = <img.Pixel>[];
  final width = image.width;
  final height = image.height;

  void walk(int x0, int y0, int dx, int dy, int steps) {
    var x = x0;
    var y = y0;
    for (var i = 0; i < steps; i++) {
      final pixel = image.getPixel(x, y);
      if (pixel.a >= 40) {
        samples.add(pixel);
        return;
      }
      x += dx;
      y += dy;
    }
  }

  for (var x = 0; x < width; x += math.max(1, width ~/ 12)) {
    walk(x, 0, 0, 1, height);
    walk(x, height - 1, 0, -1, height);
  }
  for (var y = 0; y < height; y += math.max(1, height ~/ 12)) {
    walk(0, y, 1, 0, width);
    walk(width - 1, y, -1, 0, width);
  }

  if (samples.isEmpty) return null;

  final r = samples.fold<int>(0, (sum, p) => sum + p.r.toInt()) ~/ samples.length;
  final g = samples.fold<int>(0, (sum, p) => sum + p.g.toInt()) ~/ samples.length;
  final b = samples.fold<int>(0, (sum, p) => sum + p.b.toInt()) ~/ samples.length;
  return (r, g, b);
}

img.Image _cropToOpaque(img.Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = 0;
  var maxY = 0;
  var found = false;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a < 28) continue;
      found = true;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  if (!found) return image;
  const pad = 4;
  minX = math.max(0, minX - pad);
  minY = math.max(0, minY - pad);
  maxX = math.min(image.width - 1, maxX + pad);
  maxY = math.min(image.height - 1, maxY + pad);
  return img.copyCrop(
    image,
    x: minX,
    y: minY,
    width: math.max(1, maxX - minX + 1),
    height: math.max(1, maxY - minY + 1),
  );
}

int _distSq(img.Pixel pixel, int r, int g, int b) {
  final dr = pixel.r.toInt() - r;
  final dg = pixel.g.toInt() - g;
  final db = pixel.b.toInt() - b;
  return dr * dr + dg * dg + db * db;
}

/// Reads width/height from a PNG IHDR so mix layout can keep true proportions.
(int, int) pngPixelSize(Uint8List bytes) {
  if (bytes.length < 24 || bytes[0] != 0x89) return (1, 1);
  final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
  final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];
  return (width.clamp(1, 4096), height.clamp(1, 4096));
}
