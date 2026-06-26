import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_card.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import 'desktop_title_bar.dart';

/// Shell tab routes — use [context.go] so branch state stays in sync.
const shellTabRoutes = {
  AppRoutes.discovery,
  AppRoutes.library,
  AppRoutes.studio,
  AppRoutes.messages,
  AppRoutes.profile,
};

String desktopSidebarActiveId(String location) {
  if (location.startsWith(AppRoutes.library)) return 'library';
  if (location.startsWith(AppRoutes.studio)) return 'create_screenplay';
  if (location.startsWith(AppRoutes.profile)) return 'profile';
  if (location.startsWith(AppRoutes.community)) return 'community';
  if (location.startsWith(AppRoutes.favorites)) return 'my_favorites';
  return 'explore';
}

@Deprecated('Use desktopSidebarActiveId')
String exploreSidebarActiveId(String location) =>
    desktopSidebarActiveId(location);

class DesktopSidebarSection {
  const DesktopSidebarSection({required this.title, required this.items});

  final String title;
  final List<DesktopSidebarItem> items;
}

class DesktopSidebarItem {
  const DesktopSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.onTap,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
}

const desktopSidebarSections = [
  DesktopSidebarSection(
    title: '发现',
    items: [
      DesktopSidebarItem(
        id: 'explore',
        label: '探索首页',
        icon: Icons.explore_outlined,
        route: AppRoutes.discovery,
      ),
      DesktopSidebarItem(
        id: 'library',
        label: '素材库',
        icon: Icons.grid_view_outlined,
        route: AppRoutes.library,
      ),
      DesktopSidebarItem(
        id: 'community',
        label: '社区作品',
        icon: Icons.groups_outlined,
        route: AppRoutes.community,
      ),
      DesktopSidebarItem(
        id: 'template_market',
        label: '模板市场',
        icon: Icons.dashboard_customize_outlined,
        route: AppRoutes.community,
      ),
      DesktopSidebarItem(
        id: 'trending_templates',
        label: '热门模板',
        icon: Icons.local_fire_department_outlined,
        route: AppRoutes.community,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '标签',
    items: [
      DesktopSidebarItem(
        id: 'tag_explore',
        label: '标签探索',
        icon: Icons.label_outline,
        route: AppRoutes.library,
      ),
      DesktopSidebarItem(
        id: 'pose_tags',
        label: '姿势标签',
        icon: Icons.accessibility_new_outlined,
        route: AppRoutes.library,
      ),
      DesktopSidebarItem(
        id: 'global_search',
        label: '全局搜索',
        icon: Icons.search,
        route: AppRoutes.search,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '我的内容',
    items: [
      DesktopSidebarItem(
        id: 'my_screenplays',
        label: '我的剧本',
        icon: Icons.movie_creation_outlined,
        route: AppRoutes.profileWorks,
      ),
      DesktopSidebarItem(
        id: 'my_templates',
        label: '我的模板',
        icon: Icons.copy_all_outlined,
        route: AppRoutes.profileWorks,
      ),
      DesktopSidebarItem(
        id: 'my_favorites',
        label: '我的收藏',
        icon: Icons.favorite_border,
        route: AppRoutes.favorites,
      ),
      DesktopSidebarItem(
        id: 'downloads',
        label: '下载',
        icon: Icons.download_outlined,
        route: AppRoutes.profileComingSoon,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '创建',
    items: [
      DesktopSidebarItem(
        id: 'create_screenplay',
        label: '创建剧本',
        icon: Icons.add_circle_outline,
        route: AppRoutes.studio,
      ),
      DesktopSidebarItem(
        id: 'create_template',
        label: '创建模板',
        icon: Icons.layers_outlined,
        route: AppRoutes.create,
      ),
      DesktopSidebarItem(
        id: 'upload_frame_pack',
        label: '上传 Frame Pack',
        icon: Icons.collections_outlined,
        route: AppRoutes.studio,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '个人中心',
    items: [
      DesktopSidebarItem(
        id: 'profile',
        label: '个人资料',
        icon: Icons.person_outline,
        route: AppRoutes.profile,
      ),
      DesktopSidebarItem(
        id: 'analytics',
        label: '数据分析',
        icon: Icons.insights_outlined,
        route: AppRoutes.profileComingSoon,
      ),
      DesktopSidebarItem(
        id: 'settings',
        label: '设置',
        icon: Icons.settings_outlined,
        route: AppRoutes.settings,
      ),
    ],
  ),
];

@Deprecated('Use desktopSidebarSections')
const exploreSidebarSections = desktopSidebarSections;

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({
    super.key,
    this.onItemTap,
  });

  final ValueChanged<DesktopSidebarItem>? onItemTap;

  void _navigate(BuildContext context, DesktopSidebarItem item) {
    onItemTap?.call(item);
    if (item.onTap != null) {
      item.onTap!();
      return;
    }
    final route = item.route;
    if (route == null) return;
    if (shellTabRoutes.contains(route)) {
      context.go(route);
      return;
    }
    if (route == AppRoutes.profileComingSoon) {
      context.push(AppRoutes.comingSoon(item.label));
      return;
    }
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final activeId = desktopSidebarActiveId(GoRouterState.of(context).uri.path);
    final isMacOS = !kIsWeb && Platform.isMacOS;

    return DesktopCard(
      width: 260,
      clipChild: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMacOS)
            SizedBox(
              height: kDesktopTitleBarHeight,
              child: const DesktopWindowControls(),
            ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                DesktopChrome.gap,
                isMacOS ? DesktopChrome.gap : DesktopChrome.gap + 4,
                DesktopChrome.gap,
                DesktopChrome.gap * 2,
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: Rc0Logo(),
                ),
                for (final section in desktopSidebarSections) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Text(
                      section.title,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  for (final item in section.items)
                    _SidebarNavTile(
                      item: item,
                      selected: item.id == activeId,
                      onTap: () => _navigate(context, item),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Deprecated('Use DesktopSidebar')
typedef ExploreDesktopSidebar = DesktopSidebar;

@Deprecated('Use DesktopSidebarItem')
typedef ExploreSidebarItem = DesktopSidebarItem;

class _SidebarNavTile extends StatefulWidget {
  const _SidebarNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DesktopSidebarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppColors.sidebarActive
        : _hovered
            ? AppColors.surfaceSecondary
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    widget.item.icon,
                    size: 20,
                    color: widget.selected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            widget.selected ? FontWeight.w600 : FontWeight.w500,
                        color: widget.selected
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
