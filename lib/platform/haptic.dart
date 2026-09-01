import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void whimsyHaptic() {
  if (kIsWeb) return;
  HapticFeedback.mediumImpact();
}
