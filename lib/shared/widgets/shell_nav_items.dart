import 'package:flutter/material.dart';

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

/// Legacy primary mobile slots — prefer [ShellNavConfigStore.navItems].
const List<ShellNavItem> mobilePrimaryNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: '模板',
    icon: Icons.storefront_outlined,
    selectedIcon: Icons.storefront,
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

/// Legacy desktop items — prefer [desktopSidebarPrimaries].
const List<ShellNavItem> desktopNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: '模板',
    icon: Icons.storefront_outlined,
    selectedIcon: Icons.storefront,
    desktopOnly: true,
  ),
  ShellNavItem(
    branchIndex: 2,
    label: '场景',
    icon: Icons.landscape_outlined,
    selectedIcon: Icons.landscape,
  ),
  ShellNavItem(
    branchIndex: 5,
    label: '资产',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  ShellNavItem(
    branchIndex: 3,
    label: '我的',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];
