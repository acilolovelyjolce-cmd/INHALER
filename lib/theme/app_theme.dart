import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      splashFactory: InkRipple.splashFactory,
    );

    final inkBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: const BorderSide(color: AppColors.ink, width: AppStroke.ink),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.blush,
      colorScheme: const ColorScheme.light(
        primary: AppColors.petal,
        onPrimary: AppColors.plum,
        secondary: AppColors.sky,
        onSecondary: AppColors.plum,
        tertiary: AppColors.yolk,
        onTertiary: AppColors.plum,
        surface: AppColors.cloud,
        onSurface: AppColors.plum,
        error: AppColors.cancelled,
        onError: AppColors.cloud,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        titleLarge: AppTypography.title,
        titleMedium: AppTypography.title,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.plum,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      canvasColor: AppColors.blush,
      dividerColor: AppColors.ink.withValues(alpha: 0.12),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.yolk,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.ink),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.ink, width: AppStroke.ink),
        ),
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cloud,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.cloud,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
        clipBehavior: Clip.antiAlias,
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cloud,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorder,
          side: const BorderSide(color: AppColors.ink, width: AppStroke.ink),
        ),
        titleTextStyle: AppTypography.displaySmall,
        contentTextStyle: AppTypography.body,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cloud,
        hintStyle: AppTypography.body.copyWith(color: AppColors.plumSoft),
        labelStyle: AppTypography.label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: inkBorder,
        enabledBorder: inkBorder,
        focusedBorder: inkBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.petalDeep, width: 3.5),
        ),
        errorBorder: inkBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.cancelled, width: AppStroke.ink),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.petal;
          return AppColors.cloud;
        }),
        checkColor: WidgetStateProperty.all(AppColors.ink),
        side: const BorderSide(color: AppColors.ink, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.cloud),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.meadow;
          return AppColors.plum.withValues(alpha: 0.18);
        }),
        trackOutlineColor: WidgetStateProperty.all(AppColors.ink),
        trackOutlineWidth: WidgetStateProperty.all(2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sky,
        selectedColor: AppColors.petal,
        labelStyle: AppTypography.label.copyWith(color: AppColors.plum),
        shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 2)),
        side: const BorderSide(color: AppColors.ink, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cloud,
        indicatorColor: AppColors.petal,
        elevation: 0,
        height: 78,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(AppTypography.label.copyWith(color: AppColors.plum)),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: AppColors.plum, size: 26),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.petal,
        selectedIconTheme: IconThemeData(color: AppColors.plum),
        unselectedIconTheme: IconThemeData(color: AppColors.plumSoft),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.petal,
      ),
      iconTheme: const IconThemeData(color: AppColors.plum),
    );
  }
}
