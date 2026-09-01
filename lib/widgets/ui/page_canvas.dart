import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class PageCanvas extends StatelessWidget {
  const PageCanvas({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContent,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
