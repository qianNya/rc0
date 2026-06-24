import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_brand_icon.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/shell_nav_items.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    required this.currentBranch,
    required this.onNavItemTap,
    required this.onProfileTap,
    required this.onStudioTap,
  });

  final int currentBranch;
  final ValueChanged<ShellNavItem> onNavItemTap;
  final VoidCallback onProfileTap;
  final VoidCallback onStudioTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        width: 200,
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Rc0Logo(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Pose Reference & Script',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),
            ...desktopNavItems.map((item) {
              final active =
                  item.branchIndex != null && currentBranch == item.branchIndex;
              return _SidebarTile(
                label: item.label,
                icon: active ? item.selectedIcon : item.icon,
                selected: active,
                onTap: () => onNavItemTap(item),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Tooltip(
                message: '创作',
                child: ElevatedButton(
                  onPressed: onStudioTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const AppBrandIcon(size: 22),
                ),
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
              selected: currentBranch == 4,
              selectedTileColor: AppColors.sidebarActive,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              onTap: onProfileTap,
            ),
            const SizedBox(height: 16),
          ],
        ),
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
