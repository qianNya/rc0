import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../features/cine_equipment/domain/equipment_category.dart';
import '../liquid_glass_surface.dart';
import 'carousel_column_visuals.dart';

/// One column in [GlassFourColumnCarouselPicker].
class CarouselColumnSpec {
  const CarouselColumnSpec({
    required this.kind,
    required this.values,
    required this.selectedIndex,
    required this.onSelected,
    this.bodyCategories,
  });

  final CarouselColumnKind kind;
  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<EquipmentCategory>? bodyCategories;
}

/// Four side-by-side visual wheel carousels — light liquid-glass style.
class GlassFourColumnCarouselPicker extends StatelessWidget {
  const GlassFourColumnCarouselPicker({
    super.key,
    required this.columns,
    this.height = 196,
    this.itemExtent = 76,
    this.embedded = false,
  });

  final List<CarouselColumnSpec> columns;
  final double height;
  final double itemExtent;

  /// When true, skips the outer glass shell (e.g. inside [GlassCard] or sheet).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final visible = columns.where((c) => c.values.isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final divider = AppColors.glassBorderLight.withValues(alpha: 0.65);

    final row = Row(
      children: [
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0)
            VerticalDivider(width: 1, thickness: 1, color: divider),
          Expanded(
            child: _VisualCarouselColumn(
              spec: visible[i],
              height: height,
              itemExtent: itemExtent,
            ),
          ),
        ],
      ],
    );

    if (embedded) return row;

    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: row,
    );
  }
}

class _VisualCarouselColumn extends StatefulWidget {
  const _VisualCarouselColumn({
    required this.spec,
    required this.height,
    required this.itemExtent,
  });

  final CarouselColumnSpec spec;
  final double height;
  final double itemExtent;

  @override
  State<_VisualCarouselColumn> createState() => _VisualCarouselColumnState();
}

class _VisualCarouselColumnState extends State<_VisualCarouselColumn> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _safeIndex(
        widget.spec.selectedIndex,
        widget.spec.values.length,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _VisualCarouselColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _safeIndex(
      widget.spec.selectedIndex,
      widget.spec.values.length,
    );
    if (next != _controller.selectedItem) {
      _controller.animateToItem(
        next,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _safeIndex(int index, int length) {
    if (length <= 0) return 0;
    return index.clamp(0, length - 1);
  }

  void _step(int delta) {
    final next = (_controller.selectedItem + delta)
        .clamp(0, widget.spec.values.length - 1);
    if (next == _controller.selectedItem) return;
    _controller.animateToItem(
      next,
      duration: AppMotion.fast,
      curve: AppMotion.standard,
    );
    widget.spec.onSelected(next);
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.spec.values;
    if (values.isEmpty) return const SizedBox.shrink();

    final selected = _safeIndex(widget.spec.selectedIndex, values.length);
    final caption = values[selected];
    final canPrev = selected > 0;
    final canNext = selected < values.length - 1;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                left: 8,
                right: 8,
                child: _FocusFrame(),
              ),
              ListWheelScrollView.useDelegate(
                controller: _controller,
                itemExtent: widget.itemExtent,
                physics: const FixedExtentScrollPhysics(),
                diameterRatio: 1.35,
                perspective: 0.003,
                magnification: 1.0,
                squeeze: 0.95,
                onSelectedItemChanged: widget.spec.onSelected,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: values.length,
                  builder: (context, index) {
                    final isSelected = index == selected;
                    EquipmentCategory? category;
                    final cats = widget.spec.bodyCategories;
                    if (cats != null && index < cats.length) {
                      category = cats[index];
                    }
                    return Center(
                      child: CarouselColumnVisuals.build(
                        kind: widget.spec.kind,
                        value: values[index],
                        selected: isSelected,
                        bodyCategory: category,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 2,
                child: _NavArrow(
                  pointingRight: false,
                  enabled: canPrev,
                  onTap: () => _step(-1),
                ),
              ),
              Positioned(
                right: 2,
                child: _NavArrow(
                  pointingRight: true,
                  enabled: canNext,
                  onTap: () => _step(1),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FocusFrame extends StatelessWidget {
  const _FocusFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CustomPaint(
          painter: _GridPatternPainter(
            lineColor: AppColors.border.withValues(alpha: 0.28),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.95,
                colors: [
                  AppColors.accent.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  _GridPatternPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    const step = 10.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor;
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.pointingRight,
    required this.enabled,
    required this.onTap,
  });

  final bool pointingRight;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Icon(
        Icons.play_arrow,
        textDirection: pointingRight ? TextDirection.ltr : TextDirection.rtl,
        size: 14,
        color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
      ),
    );
  }
}

int indexForString(List<String> options, String? value, {int fallback = 0}) {
  if (value == null || value.isEmpty) return fallback;
  final index = options.indexOf(value);
  return index >= 0 ? index : fallback;
}
