import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_motion.dart';
import '../liquid_glass_surface.dart';

/// A pill-shaped liquid-glass button.
///
/// [filled] renders a solid accent button (primary action); otherwise a
/// translucent frosted pill (secondary / overlay action).
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.filled = false,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.floatingBarRadius);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !loading;
    final foreground = filled
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    final inner = AnimatedOpacity(
      duration: AppMotion.fast,
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm + 2,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 18, color: foreground),
            if (loading || icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    final tap = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        child: inner,
      ),
    );

    if (filled) {
      return ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: enabled ? AppColors.accent : AppColors.accent.withValues(alpha: 0.5),
            borderRadius: radius,
          ),
          child: tap,
        ),
      );
    }

    return LiquidGlassSurface(
      borderRadius: radius,
      child: tap,
    );
  }
}
