import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../shell/presentation/widgets/desktop_title_bar.dart';
import 'explore_desktop_card.dart';

/// Shell tab routes — use [context.go] so branch state stays in sync.
const _shellTabRoutes = {
  AppRoutes.discovery,
  AppRoutes.library,
  AppRoutes.studio,
  AppRoutes.messages,
  AppRoutes.profile,
};

String exploreSidebarActiveId(String location) {
  if (location.startsWith(AppRoutes.library)) return 'library';
  if (location.startsWith(AppRoutes.studio)) return 'create_screenplay';
  if (location.startsWith(AppRoutes.profile)) return 'profile';
  if (location.startsWith(AppRoutes.community)) return 'community';
  if (location.startsWith(AppRoutes.favorites)) return 'my_favorites';
  return 'explore';
}

class ExploreSidebarSection {
  const ExploreSidebarSection({required this.title, required this.items});

  final String title;
  final List<ExploreSidebarItem> items;
}

class ExploreSidebarItem {
  const ExploreSidebarItem({
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

const exploreSidebarSections = [
  ExploreSidebarSection(
    title: '发现',
    items: [
      ExploreSidebarItem(
        id: 'explore',
        label: '探索首页',
        icon: Icons.explore_outlined,
        route: AppRoutes.discovery,
      ),
      ExploreSidebarItem(
        id: 'library',
        label: '素材库',
        icon: Icons.grid_view_outlined,
        route: AppRoutes.library,
      ),
      ExploreSidebarItem(
        id: 'community',
        label: '社区作品',
        icon: Icons.groups_outlined,
        route: AppRoutes.community,
      ),
      ExploreSidebarItem(
        id: 'template_market',
        label: '模板市场',
        icon: Icons.dashboard_customize_outlined,
        route: AppRoutes.community,
      ),
      ExploreSidebarItem(
        id: 'trending_templates',
        label: '热门模板',
        icon: Icons.local_fire_department_outlined,
        route: AppRoutes.community,
      ),
    ],
  ),
  ExploreSidebarSection(
    title: '标签',
    items: [
      ExploreSidebarItem(
        id: 'tag_explore',
        label: '标签探索',
        icon: Icons.label_outline,
        route: AppRoutes.library,
      ),
      ExploreSidebarItem(
        id: 'pose_tags',
        label: '姿势标签',
        icon: Icons.accessibility_new_outlined,
        route: AppRoutes.library,
      ),
      ExploreSidebarItem(
        id: 'global_search',
        label: '全局搜索',
        icon: Icons.search,
        route: AppRoutes.search,
      ),
    ],
  ),
  ExploreSidebarSection(
    title: '我的内容',
    items: [
      ExploreSidebarItem(
        id: 'my_screenplays',
        label: '我的剧本',
        icon: Icons.movie_creation_outlined,
        route: AppRoutes.profileWorks,
      ),
      ExploreSidebarItem(
        id: 'my_templates',
        label: '我的模板',
        icon: Icons.copy_all_outlined,
        route: AppRoutes.profileWorks,
      ),
      ExploreSidebarItem(
        id: 'my_favorites',
        label: '我的收藏',
        icon: Icons.favorite_border,
        route: AppRoutes.favorites,
      ),
      ExploreSidebarItem(
        id: 'downloads',
        label: '下载',
        icon: Icons.download_outlined,
        route: AppRoutes.profileComingSoon,
      ),
    ],
  ),
  ExploreSidebarSection(
    title: '创建',
    items: [
      ExploreSidebarItem(
        id: 'create_screenplay',
        label: '创建剧本',
        icon: Icons.add_circle_outline,
        route: AppRoutes.studio,
      ),
      ExploreSidebarItem(
        id: 'create_template',
        label: '创建模板',
        icon: Icons.layers_outlined,
        route: AppRoutes.create,
      ),
      ExploreSidebarItem(
        id: 'upload_frame_pack',
        label: '上传 Frame Pack',
        icon: Icons.collections_outlined,
        route: AppRoutes.studio,
      ),
    ],
  ),
  ExploreSidebarSection(
    title: '个人中心',
    items: [
      ExploreSidebarItem(
        id: 'profile',
        label: '个人资料',
        icon: Icons.person_outline,
        route: AppRoutes.profile,
      ),
      ExploreSidebarItem(
        id: 'analytics',
        label: '数据分析',
        icon: Icons.insights_outlined,
        route: AppRoutes.profileComingSoon,
      ),
      ExploreSidebarItem(
        id: 'settings',
        label: '设置',
        icon: Icons.settings_outlined,
        route: AppRoutes.settings,
      ),
    ],
  ),
];

class ExploreDesktopSidebar extends StatelessWidget {
  const ExploreDesktopSidebar({
    super.key,
    this.onItemTap,
  });

  final ValueChanged<ExploreSidebarItem>? onItemTap;

  void _navigate(BuildContext context, ExploreSidebarItem item) {
    onItemTap?.call(item);
    if (item.onTap != null) {
      item.onTap!();
      return;
    }
    final route = item.route;
    if (route == null) return;
    if (_shellTabRoutes.contains(route)) {
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
    final activeId =
        exploreSidebarActiveId(GoRouterState.of(context).uri.path);

    final isMacOS = !kIsWeb && Platform.isMacOS;

    return ExploreDesktopCard(
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
                ExploreDesktopChrome.gap,
                isMacOS ? ExploreDesktopChrome.gap : ExploreDesktopChrome.gap + 4,
                ExploreDesktopChrome.gap,
                ExploreDesktopChrome.gap * 2,
              ),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: Rc0Logo(),
                ),
                for (final section in exploreSidebarSections) ...[
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

class _SidebarNavTile extends StatefulWidget {
  const _SidebarNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final ExploreSidebarItem item;
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
