import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';

/// Glossy water-drop pill that slides between tab slots with liquid stretch.
class LiquidTabIndicator extends StatefulWidget {
  const LiquidTabIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
    this.itemWidths,
    this.breath = 0,
    this.verticalInset = 8,
  });

  final int selectedIndex;
  final int itemCount;
  /// When set, indicator position follows each tab's width instead of equal slots.
  final List<double>? itemWidths;
  final double breath;
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
      duration: AppMotion.normal,
    )..value = 1;
  }

  @override
  void didUpdateWidget(LiquidTabIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fromIndex = _animatedIndex;
      _toIndex = widget.selectedIndex.toDouble();
      _controller.duration = _transitionDuration;
      _controller.forward(from: 0);
    }
  }

  Duration get _transitionDuration {
    final distance = (_toIndex - _fromIndex).abs();
    final millis = (210 + distance * 80).round().clamp(210, 340);
    return Duration(milliseconds: millis);
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
        : const Color(0xFFD9B4E9).withValues(alpha: 0.36);
    final border = isDark
        ? AppColors.glassNavIndicatorBorderDark
        : const Color(0xFFF0D9F8).withValues(alpha: 0.44);
    final sheen = isDark
        ? AppColors.glassNavIndicatorSheenDark
        : Colors.white.withValues(alpha: 0.14);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final moving = _fromIndex != _toIndex;
        final transferDistance = (_toIndex - _fromIndex).abs().clamp(0.0, 2.0);
        final phase = moving ? math.sin(math.pi * t) : 0.0;
        final stretch = phase * (0.18 + transferDistance * 0.03);
        final index = _animatedIndex;
        final breathing = widget.breath.clamp(0.0, 1.0);

        return LayoutBuilder(
          builder: (context, constraints) {
            final slotWidths = _resolveSlotWidths(constraints.maxWidth);
            final capsuleHeight = constraints.maxHeight - widget.verticalInset * 2;
            final activeSlotWidth = slotWidths[
              widget.selectedIndex.clamp(0, slotWidths.length - 1)
            ];
            final baseWidth = (activeSlotWidth * 0.72).clamp(44.0, 62.0);
            final capsuleWidth = baseWidth + stretch * (14 + transferDistance * 4);
            final centerX = _centerXForIndex(index, slotWidths);
            final left = centerX - capsuleWidth / 2;
            final top = ((constraints.maxHeight - capsuleHeight) / 2)
                .clamp(widget.verticalInset, constraints.maxHeight)
                .toDouble();
            final radius = BorderRadius.circular(capsuleHeight / 2);
            final floatY = -phase * 1.1;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // iPhone-style dynamic outer ring
                Positioned(
                  left: left - (6 + stretch * 6),
                  top: top + floatY - (3 + stretch * 2),
                  width: capsuleWidth + (12 + stretch * 12),
                  height: capsuleHeight + (6 + stretch * 4),
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(capsuleHeight),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: (0.42 + breathing * 0.12).clamp(0.0, 0.64),
                          ),
                          width: 0.7,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark
                                    ? AppColors.glassNavIconSelectedDark
                                    : AppColors.glassNavIconSelectedLight)
                                .withValues(alpha: 0.14 + phase * 0.08),
                            blurRadius: 18 + breathing * 6,
                            spreadRadius: -10,
                            offset: Offset(0, 2 + phase * 2.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main liquid capsule
                Positioned(
                  left: left,
                  top: top + floatY,
                  width: capsuleWidth,
                  height: capsuleHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          sheen.withValues(alpha: 0.95),
                          fill.withValues(alpha: 0.78),
                          fill.withValues(alpha: 0.72),
                        ],
                        stops: const [0, 0.42, 1],
                      ),
                      border: Border.all(
                        color: border.withValues(alpha: 0.95),
                        width: 0.7,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? AppColors.shadowFaint : AppColors.shadowSoft,
                          blurRadius: 12 + breathing * 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: radius,
                      child: ClipRRect(
                        borderRadius: radius,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(-0.95 + phase * 0.9, -0.45),
                              end: Alignment(0.95 + phase * 0.9, 0.85),
                              colors: [
                                Colors.white.withValues(alpha: 0.26 + breathing * 0.08),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0, 0.62],
                            ),
                          ),
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

  List<double> _resolveSlotWidths(double trackWidth) {
    final widths = widget.itemWidths;
    if (widths != null &&
        widths.length == widget.itemCount &&
        widget.itemCount > 0) {
      return widths;
    }
    final itemWidth = trackWidth / widget.itemCount;
    return List<double>.filled(widget.itemCount, itemWidth);
  }

  double _centerXForIndex(double index, List<double> slotWidths) {
    if (slotWidths.isEmpty) return 0;

    final lower = index.floor().clamp(0, slotWidths.length - 1);
    final upper = (lower + 1).clamp(0, slotWidths.length - 1);
    final t = index - lower;
    final lowerCenter = _slotCenter(lower, slotWidths);
    if (lower == upper || t <= 0) return lowerCenter;
    final upperCenter = _slotCenter(upper, slotWidths);
    return lowerCenter + (upperCenter - lowerCenter) * t;
  }

  double _slotCenter(int slotIndex, List<double> slotWidths) {
    var leading = 0.0;
    for (var i = 0; i < slotIndex; i++) {
      leading += slotWidths[i];
    }
    return leading + slotWidths[slotIndex] / 2;
  }
}
