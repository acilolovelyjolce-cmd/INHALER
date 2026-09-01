import 'package:flutter/material.dart';

abstract final class Breakpoints {
  static const compact = 600.0;
  static const medium = 1024.0;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

enum AppSizeClass { compact, medium, expanded }

AppSizeClass sizeClassFor(double width) {
  if (width < Breakpoints.compact) return AppSizeClass.compact;
  if (width < Breakpoints.medium) return AppSizeClass.medium;
  return AppSizeClass.expanded;
}
