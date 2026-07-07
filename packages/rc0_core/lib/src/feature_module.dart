import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Shell navigation entry contributed by a feature module.
@immutable
class NavEntry {
  const NavEntry({
    required this.id,
    required this.label,
    required this.routePath,
    this.icon,
  });

  final String id;
  final String label;
  final String routePath;
  final IconData? icon;
}

/// Contract for pluggable feature packages (TECHNICAL_DESIGN §3.5).
abstract interface class FeatureModule {
  String get id;

  /// go_router routes owned by this module.
  List<RouteBase> get routes;

  /// Bottom/side nav entries (may be empty for non-shell features).
  List<NavEntry> get navEntries;

  /// Port implementations keyed by port type.
  Map<Type, Object> get ports;
}
