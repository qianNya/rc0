import 'package:flutter/animation.dart';

/// Motion design tokens — durations and curves for consistent, Apple-like
/// transitions across liquid glass surfaces and interactive widgets.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  /// Default easing for most implicit animations (entrances, fades).
  static const Curve standard = Curves.easeOutCubic;

  /// Emphasized easing for press / scale feedback.
  static const Curve emphasized = Curves.easeOutBack;

  /// Symmetric easing for toggles and crossfades.
  static const Curve smooth = Curves.easeInOut;

  /// Water-drop tab indicator — slight overshoot when the pill settles.
  static const Curve liquidTab = Cubic(0.33, 1.2, 0.48, 1.0);
}
