import 'dart:collection';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Makes a studio / paper background transparent by flooding in from the edges.
/// Interior colors (white sleeves, pastel charms) stay put because the fill
/// stops when it hits a different color.
Uint8List knockOutBackground(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;

  var image = decoded;
  const maxSide = 420;
  if (image.width > maxSide || image.height > maxSide) {
    final scale = maxSide / (image.width > image.height ? image.width : image.height);
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

  final corner = image.getPixel(1, 1);
  if (corner.a < 30) {
    return Uint8List.fromList(img.encodePng(image));
  }

  final seedR = _cornerAverage(image, (p) => p.r.toInt());
  final seedG = _cornerAverage(image, (p) => p.g.toInt());
  final seedB = _cornerAverage(image, (p) => p.b.toInt());
  const thresholdSq = 46 * 46;

  final visited = List<bool>.filled(width * height, false);
  final queue = Queue<int>();

  void offer(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final i = y * width + x;
    if (visited[i]) return;
    visited[i] = true;
    final pixel = image.getPixel(x, y);
    if (_distSq(pixel, seedR, seedG, seedB) > thresholdSq) return;
    image.setPixelRgba(x, y, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt(), 0);
    queue.addLast(i);
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

  return Uint8List.fromList(img.encodePng(image));
}

int _cornerAverage(img.Image image, int Function(img.Pixel pixel) read) {
  const inset = 2;
  final samples = [
    image.getPixel(inset, inset),
    image.getPixel(image.width - 1 - inset, inset),
    image.getPixel(inset, image.height - 1 - inset),
    image.getPixel(image.width - 1 - inset, image.height - 1 - inset),
  ];
  return samples.fold<int>(0, (sum, pixel) => sum + read(pixel)) ~/ samples.length;
}

int _distSq(img.Pixel pixel, int r, int g, int b) {
  final dr = pixel.r.toInt() - r;
  final dg = pixel.g.toInt() - g;
  final db = pixel.b.toInt() - b;
  return dr * dr + dg * dg + db * db;
}
