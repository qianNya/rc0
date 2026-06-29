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
  AppRoutes.studio,
  AppRoutes.scenes,
  AppRoutes.profile,
  AppRoutes.action,
  AppRoutes.community,
};

String desktopSidebarActiveId(String location) {
  if (location.startsWith(AppRoutes.studio) ||
      location.startsWith('/studio/edit/')) {
    return 'scene_flow';
  }
  if (location.startsWith(AppRoutes.scriptList) ||
      location.startsWith('/script/')) {
    return 'script_wiki';
  }
  if (location.startsWith(AppRoutes.character) ||
      location.startsWith(AppRoutes.characters)) {
    return 'character_wiki';
  }
  if (location.startsWith('/ip/')) return 'ip_wiki';
  if (location.startsWith(AppRoutes.scenes) ||
      location.startsWith('/my-scenes')) {
    return 'scene_library';
  }
  if (location.startsWith(AppRoutes.action)) return 'action_wiki';
  if (location.startsWith(AppRoutes.library)) return 'library';
  if (location.startsWith(AppRoutes.community)) return 'community';
  if (location.startsWith(AppRoutes.profile)) return 'profile';
  if (location.startsWith(AppRoutes.favorites)) return 'my_favorites';
  return 'wiki_hub';
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
    title: '产品主线',
    items: [
      DesktopSidebarItem(
        id: 'wiki_hub',
        label: 'Wiki 首页',
        icon: Icons.menu_book_outlined,
        route: AppRoutes.discovery,
      ),
      DesktopSidebarItem(
        id: 'action_wiki',
        label: '动作 Wiki',
        icon: Icons.accessibility_new_outlined,
        route: AppRoutes.action,
      ),
      DesktopSidebarItem(
        id: 'scene_library',
        label: '场景库',
        icon: Icons.landscape_outlined,
        route: AppRoutes.scenes,
      ),
      DesktopSidebarItem(
        id: 'scene_flow',
        label: '场景摄影流程',
        icon: Icons.movie_creation_outlined,
        route: AppRoutes.studio,
      ),
      DesktopSidebarItem(
        id: 'script_wiki',
        label: '剧本 Wiki',
        icon: Icons.auto_stories_outlined,
        route: AppRoutes.scriptList,
      ),
      DesktopSidebarItem(
        id: 'character_wiki',
        label: '角色 Wiki',
        icon: Icons.group_outlined,
        route: AppRoutes.discoveryCharacterWiki,
      ),
      DesktopSidebarItem(
        id: 'ip_wiki',
        label: 'IP 参考',
        icon: Icons.bookmarks_outlined,
        route: AppRoutes.discovery,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '摄影流程',
    items: [
      DesktopSidebarItem(
        id: 'scene_library',
        label: '场景库',
        icon: Icons.landscape_outlined,
        route: AppRoutes.scenes,
      ),
      DesktopSidebarItem(
        id: 'my_scenes',
        label: '我的场景',
        icon: Icons.folder_open_outlined,
        route: AppRoutes.myScenes,
      ),
      DesktopSidebarItem(
        id: 'preset_flow',
        label: '打光与参数',
        icon: Icons.tune_outlined,
        route: AppRoutes.preset,
      ),
    ],
  ),
  DesktopSidebarSection(
    title: '探索与社区',
    items: [
      DesktopSidebarItem(
        id: 'community',
        label: '社区作品',
        icon: Icons.groups_outlined,
        route: AppRoutes.community,
      ),
      DesktopSidebarItem(
        id: 'library',
        label: '素材图库',
        icon: Icons.grid_view_outlined,
        route: AppRoutes.library,
      ),
      DesktopSidebarItem(
        id: 'global_search',
        label: '全局搜索',
        icon: Icons.search,
        route: AppRoutes.search,
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
    title: '我的内容',
    items: [
      DesktopSidebarItem(
        id: 'my_screenplays',
        label: '我的剧本',
        icon: Icons.movie_creation_outlined,
        route: AppRoutes.profileWorks,
      ),
      DesktopSidebarItem(
        id: 'my_characters',
        label: '我的角色',
        icon: Icons.person_pin_outlined,
        route: AppRoutes.myCharacters,
      ),
      DesktopSidebarItem(
        id: 'create_screenplay',
        label: '进入创作',
        icon: Icons.add_circle_outline,
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
