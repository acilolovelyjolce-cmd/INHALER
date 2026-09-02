import 'dart:io';

import 'package:image/image.dart' as img;

/// One-shot: bake the JoicePockets logo into PWA / iOS home-screen icons.
void main() {
  final source = File('assets/branding/joice_pockets_icon.jpg');
  final decoded = img.decodeImage(source.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not decode ${source.path}');
    exit(1);
  }
  final square = img.copyResizeCropSquare(decoded, size: 1024);

  void writePng(String path, int size) {
    final resized = img.copyResize(
      square,
      width: size,
      height: size,
      interpolation: img.Interpolation.cubic,
    );
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(img.encodePng(resized));
    stdout.writeln('wrote $path (${size}x$size)');
  }

  writePng('web/apple-touch-icon.png', 180);
  writePng('web/icons/apple-touch-icon.png', 180);
  writePng('web/icons/Icon-192.png', 192);
  writePng('web/icons/Icon-512.png', 512);
  writePng('web/icons/Icon-maskable-192.png', 192);
  writePng('web/icons/Icon-maskable-512.png', 512);
  writePng('web/favicon.png', 32);
}
