import 'package:flutter/foundation.dart';

import '../config/env.dart';

String publicOrigin() {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    if (origin.isNotEmpty && origin != 'null') return origin;
  }
  return AppConfig.publicBaseUrl;
}

String shopUrlFor(String slug) => '${publicOrigin()}/shop/$slug';
