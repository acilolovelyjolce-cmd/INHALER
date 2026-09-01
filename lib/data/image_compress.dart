import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

Future<Uint8List> compressForUpload(Uint8List bytes, {int maxWidth = 720}) async {
  if (_alreadySmallJpeg(bytes)) return bytes;
  final args = _CompressArgs(bytes, maxWidth);
  if (kIsWeb) return _compress(args);
  return compute(_compress, args);
}

bool _alreadySmallJpeg(Uint8List bytes) {
  if (bytes.lengthInBytes <= 180 * 1024 && _isJpeg(bytes)) return true;
  return false;
}

bool _isJpeg(Uint8List bytes) {
  return bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
}

class _CompressArgs {
  const _CompressArgs(this.bytes, this.maxWidth);
  final Uint8List bytes;
  final int maxWidth;
}

Uint8List _compress(_CompressArgs args) {
  if (_alreadySmallJpeg(args.bytes)) return args.bytes;
  final decoded = img.decodeImage(args.bytes);
  if (decoded == null) return args.bytes;
  final resized = decoded.width > args.maxWidth
      ? img.copyResize(
          decoded,
          width: args.maxWidth,
          interpolation: img.Interpolation.linear,
        )
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: 68));
}
