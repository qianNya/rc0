import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/responsive/breakpoints.dart';
import '../liquid_glass_surface.dart';

/// Centered frosted dialog shell — title, scrollable body, optional footer.
class GlassDialog extends StatelessWidget {
  const GlassDialog({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.onClose,
    this.maxWidth = 560,
    this.maxHeightFraction = 0.88,
  });

  final Widget title;
  final Widget child;
  final Widget? footer;
  final VoidCallback? onClose;
  final double maxWidth;
  final double maxHeightFraction;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = Breakpoints.isDesktop(context);
    final horizontalInset =
        isDesktop ? AppDimensions.spacingLg : AppDimensions.spacingMd;
    final panelWidth = (size.width - horizontalInset * 2).clamp(0.0, maxWidth);
    final panelMaxHeight = size.height * maxHeightFraction;
    final radius = BorderRadius.circular(AppDimensions.radiusXl);

    return LiquidGlassSurface(
      borderRadius: radius,
      width: panelWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: panelMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
                AppDimensions.spacingSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: AppTextStyles.title.copyWith(fontSize: 18),
                      child: title,
                    ),
                  ),
                  _GlassDialogCloseButton(onPressed: onClose),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  0,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingMd,
                ),
                child: child,
              ),
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

class _GlassDialogCloseButton extends StatelessWidget {
  const _GlassDialogCloseButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.close, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

/// Presents [child] in a centered liquid-glass dialog with blurred backdrop.
Future<T?> showGlassDialog<T>(
  BuildContext context, {
  required Widget child,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    useRootNavigator: useRootNavigator,
    transitionDuration: AppMotion.normal,
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, _) {
      final curve =
          CurvedAnimation(parent: animation, curve: AppMotion.standard);
      final scale = Tween<double>(begin: 0.94, end: 1).animate(curve);

      return Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: curve,
            child: GestureDetector(
              onTap: barrierDismissible
                  ? () => Navigator.of(context, rootNavigator: useRootNavigator)
                      .maybePop()
                  : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppDimensions.glassBlurSigma * 0.5,
                  sigmaY: AppDimensions.glassBlurSigma * 0.5,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: curve,
                  child: ScaleTransition(scale: scale, child: child),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
