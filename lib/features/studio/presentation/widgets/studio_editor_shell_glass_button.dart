import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';

/// Floating glass capsule button matching [AppBottomNavBar] style.
class StudioEditorShellGlassButton extends StatefulWidget {
  const StudioEditorShellGlassButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.child,
    this.loading = false,
    this.visible = true,
    this.minWidth = AppDimensions.bottomNavFloatingHeight,
    this.animationDelay = Duration.zero,
    this.exitDelay = Duration.zero,
    this.tooltip,
  }) : assert(icon != null || label != null || child != null);

  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final Widget? child;
  final bool loading;
  final bool visible;
  final double minWidth;
  final Duration animationDelay;
  final Duration exitDelay;
  final String? tooltip;

  static const motionDuration = Duration(milliseconds: 320);
  static const exitSettleDuration = Duration(milliseconds: 400);

  @override
  State<StudioEditorShellGlassButton> createState() =>
      _StudioEditorShellGlassButtonState();
}

class _StudioEditorShellGlassButtonState extends State<StudioEditorShellGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;
  late final Animation<double> _motionOpacity;
  late final Animation<double> _motionScale;
  late final Animation<Offset> _motionSlide;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(
      vsync: this,
      duration: StudioEditorShellGlassButton.motionDuration,
    );
    final curve = CurvedAnimation(
      parent: _motionController,
      curve: Curves.easeOutBack,
    );
    _motionOpacity = CurvedAnimation(
      parent: _motionController,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );
    _motionScale = Tween<double>(begin: 0.55, end: 1).animate(curve);
    _motionSlide = Tween<Offset>(
      begin: const Offset(0.45, 0),
      end: Offset.zero,
    ).animate(curve);

    if (widget.visible) {
      if (widget.animationDelay == Duration.zero) {
        _motionController.value = 1;
      } else {
        _playEntrance();
      }
    }
  }

  @override
  void didUpdateWidget(covariant StudioEditorShellGlassButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _playEntrance();
      } else {
        _playExit();
      }
    }
  }

  void _playEntrance() {
    Future<void>.delayed(widget.animationDelay, () {
      if (mounted && widget.visible) {
        _motionController.forward();
      }
    });
  }

  void _playExit() {
    Future<void>.delayed(widget.exitDelay, () {
      if (mounted && !widget.visible) {
        _motionController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null && !widget.loading;
    final color = enabled
        ? AppColors.accent
        : theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    final button = SizedBox(
      height: AppDimensions.bottomNavFloatingHeight,
      width: widget.label != null ? null : widget.minWidth,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: widget.minWidth),
        child: LiquidGlassSurface(
          style: LiquidGlassStyle.navigation,
          height: AppDimensions.bottomNavFloatingHeight,
          padding: widget.label != null
              ? const EdgeInsets.symmetric(horizontal: 14)
              : EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              borderRadius:
                  BorderRadius.circular(AppDimensions.floatingBarRadius),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: widget.child ??
                      (widget.loading
                          ? SizedBox(
                              key: const ValueKey('loading'),
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: color,
                              ),
                            )
                          : widget.icon != null
                              ? Icon(
                                  widget.icon,
                                  key: ValueKey(widget.icon),
                                  size: 22,
                                  color: color,
                                )
                              : Text(
                                  widget.label!,
                                  key: ValueKey(widget.label),
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 13,
                                    color: color,
                                  ),
                                )),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final animated = FadeTransition(
      opacity: _motionOpacity,
      child: SlideTransition(
        position: _motionSlide,
        child: ScaleTransition(
          scale: _motionScale,
          child: button,
        ),
      ),
    );

    if (widget.tooltip == null) return animated;

    return Tooltip(
      message: widget.tooltip!,
      child: animated,
    );
  }
}
