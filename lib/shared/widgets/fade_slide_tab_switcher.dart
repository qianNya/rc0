import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_motion.dart';

Offset _slideBegin(bool forward, double fraction) =>
    Offset(forward ? fraction : -fraction, 0);

/// Keeps all [children] alive (via [IndexedStack]) and plays a fade + slide
/// entrance when [index] changes.
class FadeSlideIndexedStack extends StatefulWidget {
  const FadeSlideIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppMotion.normal,
    this.slideFraction = 0.035,
  });

  final int index;
  final List<Widget> children;
  final Duration duration;
  final double slideFraction;

  @override
  State<FadeSlideIndexedStack> createState() => _FadeSlideIndexedStackState();
}

class _FadeSlideIndexedStackState extends State<FadeSlideIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.index;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = 1;
  }

  @override
  void didUpdateWidget(covariant FadeSlideIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.index != widget.index) {
      _previousIndex = oldWidget.index;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forward = widget.index >= _previousIndex;
    final curve = CurvedAnimation(parent: _controller, curve: AppMotion.standard);
    final slide = Tween<Offset>(
      begin: _slideBegin(forward, widget.slideFraction),
      end: Offset.zero,
    ).animate(curve);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: slide,
        child: IndexedStack(
          index: widget.index,
          children: widget.children,
        ),
      ),
    );
  }
}

/// Animates shell branch switches when [navigationShell.currentIndex] changes.
class ShellBranchTransition extends StatefulWidget {
  const ShellBranchTransition({
    super.key,
    required this.navigationShell,
    this.duration = AppMotion.normal,
    this.slideFraction = 0.04,
  });

  final StatefulNavigationShell navigationShell;
  final Duration duration;
  final double slideFraction;

  @override
  State<ShellBranchTransition> createState() => _ShellBranchTransitionState();
}

class _ShellBranchTransitionState extends State<ShellBranchTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _index;
  bool _forward = true;
  VoidCallback? _routerListener;
  RouterDelegate<Object>? _routerDelegate;

  @override
  void initState() {
    super.initState();
    _index = widget.navigationShell.currentIndex;
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..value = 1;
    _routerListener = _onRouterChanged;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final delegate = GoRouter.of(context).routerDelegate;
    if (identical(_routerDelegate, delegate)) return;
    _routerDelegate?.removeListener(_routerListener!);
    _routerDelegate = delegate;
    delegate.addListener(_routerListener!);
  }

  void _onRouterChanged() {
    final next = widget.navigationShell.currentIndex;
    if (next == _index || !mounted) return;
    setState(() {
      _forward = next > _index;
      _index = next;
    });
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_routerListener!);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _controller, curve: AppMotion.standard);
    final slide = Tween<Offset>(
      begin: _slideBegin(_forward, widget.slideFraction),
      end: Offset.zero,
    ).animate(curve);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: slide,
        child: widget.navigationShell,
      ),
    );
  }
}
