import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowSoft,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: AppColors.shadowFaint,
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  static const List<BoxShadow> floatingBar = [
    BoxShadow(
      color: AppColors.shadowAmbient,
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: AppColors.shadowFaint,
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Softer elevation for translucent floating navigation bars.
  static const List<BoxShadow> floatingBarNav = [
    BoxShadow(
      color: AppColors.shadowNavCast,
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: AppColors.shadowNavFaint,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
