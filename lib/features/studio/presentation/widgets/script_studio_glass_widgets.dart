import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import 'script_studio_theme.dart';

/// Circular frosted glass icon button for the studio header and cards.
class StudioGlassIconButton extends StatelessWidget {
  const StudioGlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 22,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);

    final button = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ScriptStudioColors.glassFill,
            border: Border.all(
              color: ScriptStudioColors.glassBorder,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: iconSize,
              color: ScriptStudioColors.iconForeground,
            ),
          ),
        ),
      ),
    );

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: button,
    );
  }
}

/// Liquid glass card for the light Script Studio surface.
class StudioGlassCard extends StatelessWidget {
  const StudioGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.spacingMd),
    this.margin,
    this.glowColor,
    this.borderRadius,
    this.minHeight,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppDimensions.floatingBarRadius);
    final glow = glowColor ?? ScriptStudioColors.accentGlow;

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.accent.withValues(alpha: 0.08),
          highlightColor: Colors.black.withValues(alpha: 0.02),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: -10,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDimensions.glassBlurSigma,
            sigmaY: AppDimensions.glassBlurSigma,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ScriptStudioColors.glassFill,
                    borderRadius: radius,
                    border: Border.all(
                      color: ScriptStudioColors.glassBorder,
                      width: 0.9,
                    ),
                  ),
                ),
              ),
              if (minHeight != null)
                SizedBox(
                  width: double.infinity,
                  height: minHeight,
                  child: Center(child: content),
                )
              else
                content,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small chevron affordance inside a glass circle (decorative).
class StudioChevronBadge extends StatelessWidget {
  const StudioChevronBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ScriptStudioColors.glassFill,
            border: Border.all(
              color: ScriptStudioColors.glassBorder,
              width: 0.8,
            ),
          ),
          child: const SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.chevron_right,
              size: 18,
              color: ScriptStudioColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Theme-colored square icon container for primary actions.
class StudioGlowIconBox extends StatelessWidget {
  const StudioGlowIconBox({
    super.key,
    required this.icon,
    this.size = 52,
    this.gradientColors = const [
      AppColors.accent,
      AppColors.accentDark,
    ],
    this.glowColor = ScriptStudioColors.accentGlow,
  });

  final IconData icon;
  final double size;
  final List<Color> gradientColors;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppDimensions.radiusLg);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: -6,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors.first.withValues(alpha: 0.85),
                  gradientColors.last.withValues(alpha: 0.78),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped gradient CTA with outer glow.
class StudioGlowPillButton extends StatelessWidget {
  const StudioGlowPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ScriptStudioColors.accentGlow.withValues(alpha: 0.55),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular quick-action with light glass styling.
class StudioQuickActionOrb extends StatelessWidget {
  const StudioQuickActionOrb({
    super.key,
    required this.label,
    required this.icon,
    required this.glowColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const orbSize = 60.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: orbSize,
            height: orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  spreadRadius: -6,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppDimensions.glassNavBlurSigma,
                  sigmaY: AppDimensions.glassNavBlurSigma,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ScriptStudioColors.glassFill,
                    border: Border.all(
                      color: ScriptStudioColors.glassBorder,
                      width: 0.8,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentLight.withValues(alpha: 0.75),
                        ScriptStudioColors.glassFill,
                      ],
                    ),
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 26),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: ScriptStudioColors.cardSubtitle.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
