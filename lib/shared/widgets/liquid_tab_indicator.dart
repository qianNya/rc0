import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';

/// Glossy water-drop pill that slides between tab slots with liquid stretch.
class LiquidTabIndicator extends StatefulWidget {
  const LiquidTabIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    this.horizontalInset = AppDimensions.bottomNavIndicatorInsetH,
    this.verticalInset = AppDimensions.bottomNavIndicatorInsetV,
  });

  final int selectedIndex;
  final int itemCount;
  final double horizontalInset;
  final double verticalInset;

  @override
  State<LiquidTabIndicator> createState() => _LiquidTabIndicatorState();
}

class _LiquidTabIndicatorState extends State<LiquidTabIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double _fromIndex;
  late double _toIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.selectedIndex.toDouble();
    _toIndex = _fromIndex;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    )..value = 1;
  }

  @override
  void didUpdateWidget(LiquidTabIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fromIndex = _animatedIndex;
      _toIndex = widget.selectedIndex.toDouble();
      _controller.forward(from: 0);
    }
  }

  double get _animatedIndex {
    final t = AppMotion.liquidTab.transform(_controller.value);
    return _fromIndex + (_toIndex - _fromIndex) * t;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount <= 0) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? AppColors.glassNavIndicatorDark
        : AppColors.glassNavIndicatorLight;
    final border = isDark
        ? AppColors.glassNavIndicatorBorderDark
        : AppColors.glassNavIndicatorBorderLight;
    final sheen = isDark
        ? AppColors.glassNavIndicatorSheenDark
        : AppColors.glassNavIndicatorSheenLight;
    final radius = BorderRadius.circular(AppDimensions.radiusXl);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final moving = _fromIndex != _toIndex;
        final stretch = moving ? 0.24 * math.sin(math.pi * t) : 0.0;
        final squash = stretch * 0.38;
        final index = _animatedIndex;

        return LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.itemCount;
            final pillWidth = itemWidth - widget.horizontalInset * 2;
            final pillHeight =
                constraints.maxHeight - widget.verticalInset * 2;
            final left = itemWidth * index + widget.horizontalInset;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: left,
                  top: widget.verticalInset,
                  width: pillWidth,
                  height: pillHeight,
                  child: Transform.scale(
                    scaleX: 1 + stretch,
                    scaleY: 1 - squash,
                    alignment: Alignment.center,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: fill,
                        border: Border.all(color: border, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.shadowFaint
                                : AppColors.shadowSoft,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    sheen,
                                    sheen.withValues(alpha: 0),
                                  ],
                                  stops: const [0, 0.55],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 1),
                                height: 1,
                                width: pillWidth * 0.55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(
                                        alpha: isDark ? 0.12 : 0.65,
                                      ),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
