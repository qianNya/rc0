import 'package:flutter/material.dart';

class ShellNavItem {
  const ShellNavItem({
    required this.branchIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.desktopOnly = false,
    this.mobileOnly = false,
  });

  final int branchIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool desktopOnly;
  final bool mobileOnly;
}

/// Mobile bottom-nav items (探索 / 社区 / 创作 / 收藏 / 我的).
const List<ShellNavItem> mobileNavItems = [
  ShellNavItem(
    branchIndex: 0,
    label: '探索',
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
  ),
  ShellNavItem(
    branchIndex: 1,
    label: '社区',
    icon: Icons.forum_outlined,
    selectedIcon: Icons.forum,
  ),
  ShellNavItem(
    branchIndex: 2,
    label: '创作',
    icon: Icons.add,
    selectedIcon: Icons.add,
    mobileOnly: true,
  ),
  ShellNavItem(
    branchIndex: 5,
    label: '收藏',
    icon: Icons.favorite_border,
    selectedIcon: Icons.favorite,
  ),
  ShellNavItem(
    branchIndex: 3,
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
    label: '社区',
    icon: Icons.forum_outlined,
    selectedIcon: Icons.forum,
  ),
  ShellNavItem(
    branchIndex: 4,
    label: '任务',
    icon: Icons.task_alt_outlined,
    selectedIcon: Icons.task_alt,
    desktopOnly: true,
  ),
  ShellNavItem(
    branchIndex: 5,
    label: '收藏',
    icon: Icons.bookmark_outline,
    selectedIcon: Icons.bookmark,
    desktopOnly: true,
  ),
];
