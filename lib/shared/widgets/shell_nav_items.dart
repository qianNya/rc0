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

/// Mobile bottom-nav items (首页 / 图库 / 创作 / 消息 / 我的).
const List<ShellNavItem> mobileNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: '首页',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  ShellNavItem(
    branchIndex: 1,
    label: '图库',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
  ),
  ShellNavItem(
    branchIndex: 2,
    label: '创作',
    icon: Icons.movie_creation_outlined,
    selectedIcon: Icons.movie_creation,
    hideLabel: true,
    useBrandLogo: true,
    mobileOnly: true,
  ),
  ShellNavItem(
    branchIndex: 3,
    label: '消息',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
  ),
  ShellNavItem(
    branchIndex: 4,
    label: '我的',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

/// Desktop sidebar items.
const List<ShellNavItem> desktopNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: '首页',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    desktopOnly: true,
  ),
  ShellNavItem(
    branchIndex: 1,
    label: '图库',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view,
  ),
  ShellNavItem(
    stackRoute: AppRoutes.tasks,
    label: '任务',
    icon: Icons.task_alt_outlined,
    selectedIcon: Icons.task_alt,
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
