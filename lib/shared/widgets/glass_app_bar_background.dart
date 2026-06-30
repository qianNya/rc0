import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../app/theme/app_dimensions.dart';
import 'top_bar_glass_chrome.dart';

/// Floating frosted glass backdrop for [AppBar.flexibleSpace].
class GlassAppBarBackground extends StatefulWidget {
  const GlassAppBarBackground({super.key});

  @override
  State<GlassAppBarBackground> createState() => _GlassAppBarBackgroundState();
}

class _GlassAppBarBackgroundState extends State<GlassAppBarBackground> {
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
      impulse = ((notification.scrollDelta ?? 0).abs() / 64).clamp(0.0, 1.0);
    } else if (notification is OverscrollNotification) {
      impulse = (notification.overscroll.abs() / 72).clamp(0.0, 1.0);
    } else if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      impulse = 0.2;
    }
    if (impulse <= 0) return;

    final next = (_scrollBreath * 0.7 + impulse).clamp(0.0, 1.0);
    if ((next - _scrollBreath).abs() > 0.01 && mounted) {
      setState(() => _scrollBreath = next);
    }

    _settleTimer?.cancel();
    _settleTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _scrollBreath = 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarTop = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.floatingBarMarginHorizontal,
        statusBarTop + 4,
        AppDimensions.floatingBarMarginHorizontal,
        0,
      ),
      child: TopBarGlassChrome(
        breath: _scrollBreath,
        child: const SizedBox.expand(),
      ),
    );
  }
}
