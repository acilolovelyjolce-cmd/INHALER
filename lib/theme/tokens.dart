import 'package:flutter/material.dart';

abstract final class AppColors {
  static const blush = Color(0xFFFFE3EE);
  static const petal = Color(0xFFFF9FC7);
  static const meadow = Color(0xFFBFEEDA);
  static const yolk = Color(0xFFFFE39A);
  static const plum = Color(0xFF4A2F45);
  static const cloud = Color(0xFFFFFBF9);

  /// Deeper petal used only for pressed/hover fills — still on-token.
  static const petalDeep = Color(0xFFF57AAF);

  /// Soft plum for secondary copy. Contrast on blush remains AA.
  static const plumSoft = Color(0xFF6A4B63);

  static const cancelled = Color(0xFFC45C7A);
}

abstract final class AppRadii {
  static const card = 28.0;
  static const sheet = 28.0;
  static const chip = 16.0;
  static const image = 22.0;

  static const cardBorder = BorderRadius.all(Radius.circular(card));
  static const sheetBorder = BorderRadius.vertical(top: Radius.circular(sheet));
  static const imageBorder = BorderRadius.all(Radius.circular(image));
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
  static const card = [
    BoxShadow(
      color: Color(0x144A2F45),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static const sheet = [
    BoxShadow(
      color: Color(0x1F4A2F45),
      blurRadius: 40,
      offset: Offset(0, -8),
    ),
  ];
}

abstract final class AppTypography {
  static const displayFamily = 'Fredoka';
  static const bodyFamily = 'Inter';

  static const displayLarge = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 40,
    height: 1.1,
    letterSpacing: -0.6,
    color: AppColors.plum,
  );

  static const displayMedium = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 28,
    height: 1.15,
    letterSpacing: -0.4,
    color: AppColors.plum,
  );

  static const displaySmall = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w600,
    fontSize: 22,
    height: 1.2,
    letterSpacing: -0.2,
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
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.45,
    color: AppColors.plum,
  );

  static const bodySmall = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
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
    height: 1.2,
    color: AppColors.plum,
  );

  static const label = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 1.2,
    color: AppColors.plumSoft,
  );
}

abstract final class AppMotion {
  static const intro = Duration(milliseconds: 1500);
  static const reduced = Duration(milliseconds: 150);
  static const sheet = Duration(milliseconds: 420);
  static const hover = Duration(milliseconds: 180);
}

abstract final class AppLayout {
  static const headerHeight = 88.0;
  static const maxContent = 1120.0;
  static const storefrontMax = 960.0;
}
