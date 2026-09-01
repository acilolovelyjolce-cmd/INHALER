import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

Future<T?> showWhimsicalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double heightFactor = 0.92,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cloud,
    barrierColor: AppColors.plum.withValues(alpha: 0.28),
    shape: RoundedRectangleBorder(
      borderRadius: AppRadii.sheetBorder,
      side: const BorderSide(color: AppColors.ink, width: AppStroke.ink),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: builder(context),
        ),
      );
    },
  );
}

class SheetScaffold extends StatelessWidget {
  const SheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 48,
          height: 8,
          decoration: ShapeDecoration(
            color: AppColors.petal,
            shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 12, 8),
          child: Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.displaySmall)),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(child: child),
        if (actions != null)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: actions,
            ),
          ),
      ],
    );
  }
}
