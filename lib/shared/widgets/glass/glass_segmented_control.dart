import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_motion.dart';
import '../liquid_glass_surface.dart';

/// An Apple-style segmented control rendered on a liquid-glass track with an
/// animated selected pill.
class GlassSegmentedControl extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.margin,
  });

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppDimensions.floatingBarRadius);

    return LiquidGlassSurface(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppDimensions.floatingBarMarginHorizontal,
          ),
      borderRadius: radius,
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = segments.length;
          final pillWidth = count > 0 ? constraints.maxWidth / count : 0.0;
          return Stack(
            children: [
              AnimatedAlign(
                duration: AppMotion.normal,
                curve: AppMotion.smooth,
                alignment: count > 1
                    ? Alignment(-1 + 2 * (selectedIndex / (count - 1)), 0)
                    : Alignment.center,
                child: Container(
                  width: pillWidth,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXl),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: SizedBox(
                          height: 34,
                          child: Center(
                            child: Text(
                              segments[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: i == selectedIndex
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
