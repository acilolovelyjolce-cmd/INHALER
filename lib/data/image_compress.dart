import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> compressForUpload(Uint8List bytes, {int maxWidth = 1200}) async {
  final args = _CompressArgs(bytes, maxWidth);
  if (kIsWeb) return _compress(args);
  return compute(_compress, args);
}

class _CompressArgs {
  const _CompressArgs(this.bytes, this.maxWidth);
  final Uint8List bytes;
  final int maxWidth;
}

Uint8List _compress(_CompressArgs args) {
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;
  final resized = decoded.width > args.maxWidth
      ? img.copyResize(
          decoded,
          width: args.maxWidth,
          interpolation: img.Interpolation.linear,
        )
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: 82));
}
