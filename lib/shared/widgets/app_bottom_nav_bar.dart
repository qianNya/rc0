import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';

import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_motion.dart';
import 'bottom_bar_glass_chrome.dart';
import 'liquid_tab_indicator.dart';
import 'shell_nav_items.dart';

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.items = const [],
    this.wrapPadding = true,
    this.onItemLongPress,
    this.onBarLongPress,
  });

  /// Selected slot in [items], or `-1` when no primary tab is active.
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<ShellNavItem> items;
  final bool wrapPadding;
  final ValueChanged<int>? onItemLongPress;
  final VoidCallback? onBarLongPress;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  ScrollNotificationObserverState? _observer;
  Timer? _settleTimer;
  double _scrollBreath = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextObserver = ScrollNotificationObserver.maybeOf(context);
    if (_observer == nextObserver) return;
    _observer?.removeListener(_onScrollNotification);
    _observer = nextObserver;
    _observer?.addListener(_onScrollNotification);
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _observer?.removeListener(_onScrollNotification);
    super.dispose();
  }

  void _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (notification.depth > 1 || metrics.axis != Axis.vertical) return;

    var impulse = 0.0;
    if (notification is ScrollUpdateNotification) {
      impulse = ((notification.scrollDelta ?? 0).abs() / 48).clamp(0.0, 1.0);
    } else if (notification is OverscrollNotification) {
      impulse = (notification.overscroll.abs() / 64).clamp(0.0, 1.0);
    } else if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      impulse = 0.25;
    }

    if (impulse <= 0) return;
    final next = (_scrollBreath * 0.72 + impulse).clamp(0.0, 1.0);
    if ((next - _scrollBreath).abs() > 0.01 && mounted) {
      setState(() {
        _scrollBreath = next;
      });
    }

    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() {
          _scrollBreath = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.items.length;
    final showIndicator = widget.selectedIndex >= 0 && widget.selectedIndex < count;
    final bar = GestureDetector(
      onLongPress: widget.onBarLongPress,
      behavior: HitTestBehavior.translucent,
      child: BottomBarGlassChrome(
        breath: _scrollBreath,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (showIndicator)
              LiquidTabIndicator(
                selectedIndex: widget.selectedIndex,
                itemCount: count,
                breath: _scrollBreath,
              ),
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  Expanded(
                    child: _NavSlot(
                      item: widget.items[i],
                      selected: widget.selectedIndex == i,
                      onTap: () => widget.onItemSelected(i),
                      onLongPress: widget.onItemLongPress == null
                          ? null
                          : () => widget.onItemLongPress!(i),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!widget.wrapPadding) return bar;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.floatingBarMarginHorizontal,
        0,
        AppDimensions.floatingBarMarginHorizontal,
        AppDimensions.floatingBarMarginBottom,
      ),
      child: SafeArea(
        top: false,
        child: bar,
      ),
    );
  }
}

class _NavSlot extends StatefulWidget {
  const _NavSlot({
    required this.item,
    required this.selected,
    required this.onTap,
    this.onLongPress,
  });

  final ShellNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  State<_NavSlot> createState() => _NavSlotState();
}

class _NavSlotState extends State<_NavSlot> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.78)
        : const Color(0xCC1F2430);
    final selectedColor = Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: widget.selected ? 1 : 0),
        duration: AppMotion.fast,
        curve: AppMotion.smooth,
        builder: (context, t, _) {
          final color = Color.lerp(unselectedColor, selectedColor, t)!;
          final pressScale = _pressed ? 0.92 : 1.0;
          final pressOffset = _pressed ? 1.4 : 0.0;

          return AnimatedScale(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            scale: pressScale,
            child: Transform.translate(
              offset: Offset(0, pressOffset),
              child: SizedBox(
                height: AppDimensions.bottomNavFloatingHeight,
                child: Center(
                  child: Icon(
                    widget.selected ? widget.item.selectedIcon : widget.item.icon,
                    size: 22,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
