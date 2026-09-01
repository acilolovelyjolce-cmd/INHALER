import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Warm paper, like a sticker book page.
  static const cream = Color(0xFFFFF4E8);

  /// Soft pink wash behind cream stickers.
  static const blush = Color(0xFFFFE4F0);

  static const petal = Color(0xFFFF9FBE);
  static const petalDeep = Color(0xFFF57AAF);
  static const meadow = Color(0xFFB6F0C8);
  static const yolk = Color(0xFFFFE066);
  static const sky = Color(0xFFB8E4FF);
  static const ink = Color(0xFF1A1A1A);
  static const plum = Color(0xFF3A2433);
  static const cloud = Color(0xFFFFFCF8);
  static const plumSoft = Color(0xFF6B4A5E);
  static const cancelled = Color(0xFFE15B7A);
}

abstract final class AppStroke {
  static const ink = 3.0;
  static const inkThin = 2.0;
}

abstract final class AppRadii {
  static const card = 32.0;
  static const sheet = 36.0;
  static const chip = 22.0;
  static const image = 28.0;
  static const panel = 40.0;
  static const button = 28.0;

  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const sheetBorder = BorderRadius.vertical(top: Radius.circular(sheet));
  static const imageBorder = BorderRadius.all(Radius.circular(image));
  static const panelBorder = BorderRadius.all(Radius.circular(panel));
}

abstract final class AppSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class AppShadows {
  /// Hard offset, like a paper sticker.
  static const card = [
    BoxShadow(color: AppColors.ink, offset: Offset(4, 4), blurRadius: 0),
  ];

  static const cardPressed = [
    BoxShadow(color: AppColors.ink, offset: Offset(1, 1), blurRadius: 0),
  ];

  static const sheet = [
    BoxShadow(color: AppColors.ink, offset: Offset(0, -4), blurRadius: 0),
  ];
}

abstract final class AppTypography {
  static const displayFamily = 'Fredoka';
  static const bodyFamily = 'Fredoka';

  static const displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 1.05,
    letterSpacing: -0.4,
    color: AppColors.plum,
  );

  static const displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 28,
    height: 1.12,
    letterSpacing: -0.2,
    color: AppColors.plum,
  );

  static const displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.2,
    color: AppColors.plum,
  );

  static const title = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.25,
    color: AppColors.plum,
  );

  static const body = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 1.4,
    color: AppColors.plum,
  );

  static const bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    height: 1.4,
    color: AppColors.plumSoft,
  );

  static const price = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.2,
    color: AppColors.plum,
  );

  static const button = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.15,
    color: AppColors.plum,
  );

  static const label = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    height: 1.2,
    color: AppColors.plumSoft,
  );
}

abstract final class AppMotion {
  static const intro = Duration(milliseconds: 1500);
  static const reduced = Duration(milliseconds: 150);
  static const sheet = Duration(milliseconds: 420);
  static const hover = Duration(milliseconds: 160);
  static const squish = Duration(milliseconds: 120);
}

abstract final class AppLayout {
  static const headerHeight = 72.0;
  static const maxContent = 1120.0;
  static const storefrontMax = 1040.0;
  static const loginMax = 980.0;
}

BoxDecoration stickerFill({
  Color color = AppColors.cloud,
  double radius = AppRadii.card,
  bool pressed = false,
  double stroke = AppStroke.ink,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.ink, width: stroke),
    boxShadow: pressed ? AppShadows.cardPressed : AppShadows.card,
  );
}
