import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

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

/// Mobile bottom-nav items (探索 / 社区 / 发布 / 我的).
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
    label: '发布',
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle,
    mobileOnly: true,
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

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentBranch,
    required this.onSelect,
    required this.onProfileTap,
    required this.onUploadTap,
  });

  final int currentBranch;
  final ValueChanged<int> onSelect;
  final VoidCallback onProfileTap;
  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...desktopNavItems.map((item) {
            final active = currentBranch == item.branchIndex;
            return _SidebarTile(
              label: item.label,
              icon: active ? item.selectedIcon : item.icon,
              selected: active,
              onTap: () => onSelect(item.branchIndex),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: onUploadTap,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('上传参考图'),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.placeholder,
              child: Icon(Icons.person, size: 18),
            ),
            title: const Text('我的', style: AppTextStyles.label),
            selected: currentBranch == 3,
            selectedTileColor: AppColors.sidebarActive,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            onTap: onProfileTap,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: selected ? AppColors.accent : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        selected: selected,
        selectedTileColor: AppColors.sidebarActive,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        onTap: onTap,
      ),
    );
  }
}
