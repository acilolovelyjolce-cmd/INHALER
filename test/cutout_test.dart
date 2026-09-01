import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:whimsical_hub/data/cutout.dart';

void main() {
  test('knocks out a solid background from the edges', () {
    final image = img.Image(width: 40, height: 40, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
    img.fillCircle(
      image,
      x: 20,
      y: 20,
      radius: 8,
      color: img.ColorRgba8(255, 100, 160, 255),
    );
    final out = knockOutBackground(Uint8List.fromList(img.encodePng(image)));
    final result = img.decodeImage(out)!;
    expect(result.getPixel(0, 0).a, 0);
    expect(result.getPixel(result.width ~/ 2, result.height ~/ 2).a.toInt(), greaterThan(200));
  });

  test('knocks out a rounded card even when corners are already transparent', () {
    final image = img.Image(width: 48, height: 48, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
    img.fillRect(
      image,
      x1: 6,
      y1: 6,
      x2: 41,
      y2: 41,
      color: img.ColorRgba8(232, 251, 243, 255),
    );
    img.fillCircle(
      image,
      x: 24,
      y: 24,
      radius: 7,
      color: img.ColorRgba8(255, 120, 170, 255),
    );
    final out = knockOutBackground(Uint8List.fromList(img.encodePng(image)));
    final result = img.decodeImage(out)!;
    expect(result.getPixel(0, 0).a, 0);
    expect(result.getPixel(result.width ~/ 2, result.height ~/ 2).a.toInt(), greaterThan(200));
    expect(result.width, lessThan(48));
    expect(result.height, lessThan(48));
  });

  test('does not eat an isolated object on a transparent canvas', () {
    final image = img.Image(width: 48, height: 48, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
    img.fillCircle(
      image,
      x: 24,
      y: 24,
      radius: 7,
      color: img.ColorRgba8(255, 120, 170, 255),
    );
    final out = knockOutBackground(Uint8List.fromList(img.encodePng(image)));
    final result = img.decodeImage(out)!;
    expect(result.getPixel(result.width ~/ 2, result.height ~/ 2).a.toInt(), greaterThan(200));
    expect(result.width, lessThan(48));
    expect(result.height, lessThan(48));
  });

  test('reads png pixel size from the ihdr', () {
    final image = img.Image(width: 32, height: 18, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(20, 80, 40, 255));
    final bytes = Uint8List.fromList(img.encodePng(image));
    expect(pngPixelSize(bytes), (32, 18));
  });
}
