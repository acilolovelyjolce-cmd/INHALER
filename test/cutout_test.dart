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
    expect(result.getPixel(20, 20).a.toInt(), greaterThan(200));
  });
}
