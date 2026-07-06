import 'package:flutter/material.dart';

import '../../app/router/routes.dart';

class ShellNavItem {
  const ShellNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.branchIndex,
    this.stackRoute,
    this.desktopOnly = false,
    this.mobileOnly = false,
    this.hideLabel = false,
    this.useBrandLogo = false,
  }) : assert(
          branchIndex != null || stackRoute != null,
          'ShellNavItem needs branchIndex or stackRoute',
        );

  final int? branchIndex;
  final String? stackRoute;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool desktopOnly;
  final bool mobileOnly;
  final bool hideLabel;
  final bool useBrandLogo;
}

/// Primary mobile bottom-nav slots (Wiki / 场景 / 我的).
const List<ShellNavItem> mobilePrimaryNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: 'Wiki',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
  ),
  ShellNavItem(
    branchIndex: 2,
    label: '场景',
    icon: Icons.landscape_outlined,
    selectedIcon: Icons.landscape,
  ),
  ShellNavItem(
    branchIndex: 3,
    label: '我的',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

/// Detached create entry — rendered as a trailing glass capsule on mobile.
const ShellNavItem mobileCreateNavItem = ShellNavItem(
  branchIndex: 1,
  label: '创作',
  icon: Icons.movie_creation_outlined,
  selectedIcon: Icons.movie_creation,
  hideLabel: true,
  useBrandLogo: true,
  mobileOnly: true,
);

/// Legacy combined list (primary slots + detached create) for branch lookup.
final List<ShellNavItem> mobileNavItems = [
  mobilePrimaryNavItems[0],
  mobilePrimaryNavItems[1],
  mobileCreateNavItem,
  mobilePrimaryNavItems[2],
];

/// Desktop sidebar items.
const List<ShellNavItem> desktopNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: 'Wiki',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book,
    desktopOnly: true,
  ),
  ShellNavItem(
    branchIndex: 1,
    label: '图库',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
  ),
  ShellNavItem(
    stackRoute: AppRoutes.inbox,
    label: '收件箱',
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
    desktopOnly: true,
  ),
  ShellNavItem(
    stackRoute: AppRoutes.favorites,
    label: '收藏',
    icon: Icons.bookmark_outline,
    selectedIcon: Icons.bookmark,
    desktopOnly: true,
  ),
];
