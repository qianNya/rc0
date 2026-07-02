import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';

/// A frosted liquid-glass bottom sheet container with a grab handle.
///
/// Use [showGlassSheet] to present it; the content is wrapped automatically.
class GlassSheet extends StatelessWidget {
  const GlassSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(
      AppDimensions.spacingLg,
      AppDimensions.spacingSm,
      AppDimensions.spacingLg,
      AppDimensions.spacingLg,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight;
    final handleColor =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    const radius = BorderRadius.vertical(top: Radius.circular(28));

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassBlurSigma,
          sigmaY: AppDimensions.glassBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: radius,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.glassBorderDark
                    : AppColors.glassBorderLight,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Default content padding for list/menu style glass sheets (edge-to-edge
/// rows, only vertical breathing room around the grab handle).
const EdgeInsets kGlassSheetMenuPadding =
    EdgeInsets.only(bottom: AppDimensions.spacingSm);

/// Presents [child] inside a [GlassSheet] modal bottom sheet.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  EdgeInsetsGeometry? padding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    builder: (_) => padding != null
        ? GlassSheet(padding: padding, child: child)
        : GlassSheet(child: child),
  );
}

/// Height of the grab handle row inside [GlassSheet] (margin + bar).
const double kGlassSheetHandleHeight =
    AppDimensions.spacingSm + 4;

/// Tall glass sheet — fixed max height for scrollable editor panels.
Future<T?> showGlassScrollSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context, double maxHeight) builder,
  double maxHeightFraction = 0.92,
  bool useRootNavigator = false,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      final media = MediaQuery.of(context);
      final viewInsets = media.viewInsets;
      final sheetBudget = media.size.height * maxHeightFraction -
          viewInsets.bottom;
      final contentMaxHeight = (sheetBudget -
              kGlassSheetHandleHeight -
              media.padding.bottom)
          .clamp(0.0, sheetBudget);

      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: GlassSheet(
          padding: padding,
          child: builder(context, contentMaxHeight),
        ),
      );
    },
  );
}
