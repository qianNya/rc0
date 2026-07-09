import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../core/services/shell_nav_config_store.dart';
import '../../../../shared/widgets/desktop/desktop_card.dart';
import '../../../../shared/widgets/desktop/desktop_chrome.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import 'desktop_title_bar.dart';

/// Shell tab routes — use [context.go] so branch state stays in sync.
const shellTabRoutes = {
  AppRoutes.discovery,
  AppRoutes.studio,
  AppRoutes.scenes,
  AppRoutes.profile,
  AppRoutes.action,
  AppRoutes.discoveryTemplate,
  AppRoutes.assets,
};

/// L1 primary ids aligned with [ShellNavOptionId].
abstract final class DesktopSidebarPrimaryId {
  static const templates = ShellNavOptionId.templates;
  static const scenes = ShellNavOptionId.scene;
  static const assets = ShellNavOptionId.assets;
  static const profile = ShellNavOptionId.profile;
  static const create = 'create';
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

class DesktopSidebarPrimary {
  const DesktopSidebarPrimary({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final String route;
  final List<DesktopSidebarItem> children;
}

/// Single source for PC sidebar L1 + L2 (derived from shell IA).
const desktopSidebarPrimaries = <DesktopSidebarPrimary>[
  DesktopSidebarPrimary(
    id: DesktopSidebarPrimaryId.templates,
    label: '模板',
    icon: Icons.storefront_outlined,
    route: AppRoutes.discovery,
  ),
  DesktopSidebarPrimary(
    id: DesktopSidebarPrimaryId.scenes,
    label: '场景',
    icon: Icons.landscape_outlined,
    route: AppRoutes.scenes,
    children: [
      DesktopSidebarItem(
        id: 'my_scenes',
        label: '我的场景',
        icon: Icons.folder_open_outlined,
        route: AppRoutes.myScenes,
      ),
      DesktopSidebarItem(
        id: 'lighting',
        label: '灯光',
        icon: Icons.wb_incandescent_outlined,
        route: AppRoutes.lighting,
      ),
      DesktopSidebarItem(
        id: 'equipment',
        label: '设备',
        icon: Icons.videocam_outlined,
        route: AppRoutes.library,
      ),
      DesktopSidebarItem(
        id: 'preset_flow',
        label: '摄影预设',
        icon: Icons.tune_outlined,
        route: AppRoutes.preset,
      ),
    ],
  ),
  DesktopSidebarPrimary(
    id: DesktopSidebarPrimaryId.assets,
    label: '资产',
    icon: Icons.inventory_2_outlined,
    route: AppRoutes.assets,
    children: [
      DesktopSidebarItem(
        id: 'character_wiki',
        label: '角色',
        icon: Icons.group_outlined,
        route: AppRoutes.discoveryCharacterWiki,
      ),
      DesktopSidebarItem(
        id: 'action_wiki',
        label: '动作',
        icon: Icons.accessibility_new_outlined,
        route: AppRoutes.action,
      ),
      DesktopSidebarItem(
        id: 'library',
        label: '图库',
        icon: Icons.grid_view_outlined,
        route: AppRoutes.gallery,
      ),
      DesktopSidebarItem(
        id: 'my_favorites',
        label: '收藏',
        icon: Icons.favorite_border,
        route: AppRoutes.favorites,
      ),
    ],
  ),
  DesktopSidebarPrimary(
    id: DesktopSidebarPrimaryId.profile,
    label: '我的',
    icon: Icons.person_outline,
    route: AppRoutes.profile,
    children: [
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
        id: 'settings',
        label: '设置',
        icon: Icons.settings_outlined,
        route: AppRoutes.settings,
      ),
    ],
  ),
];

/// Returns the most specific active nav id (L2 child or L1 primary).
String desktopSidebarActiveId(Uri uri) {
  final location = uri.path;
  final hubTab = int.tryParse(uri.queryParameters['hubTab'] ?? '');

  if (location.startsWith(AppRoutes.studio) ||
      location.startsWith('/studio/edit/')) {
    return DesktopSidebarPrimaryId.create;
  }

  if (location.startsWith(AppRoutes.myScenes)) return 'my_scenes';
  if (location.startsWith(AppRoutes.lighting)) return 'lighting';
  if (location.startsWith(AppRoutes.library) ||
      location.startsWith(AppRoutes.equipment) ||
      location.startsWith(AppRoutes.myEquipment)) {
    return 'equipment';
  }
  if (location.startsWith(AppRoutes.preset) ||
      location.startsWith(AppRoutes.shootPresetPicker())) {
    return 'preset_flow';
  }

  if (location.startsWith(AppRoutes.discovery) && hubTab == 2) {
    return 'character_wiki';
  }
  if (location.startsWith(AppRoutes.character) ||
      location.startsWith(AppRoutes.characters) ||
      location.startsWith(AppRoutes.myCharacters)) {
    return location.startsWith(AppRoutes.myCharacters)
        ? 'my_characters'
        : 'character_wiki';
  }
  if (location.startsWith(AppRoutes.action)) return 'action_wiki';
  if (location.startsWith(AppRoutes.gallery)) return 'library';
  if (location.startsWith(AppRoutes.favorites)) return 'my_favorites';

  if (location.startsWith(AppRoutes.profileWorks)) return 'my_screenplays';
  if (location.startsWith(AppRoutes.settings)) return 'settings';
  if (location.startsWith(AppRoutes.profile)) {
    return DesktopSidebarPrimaryId.profile;
  }

  if (location.startsWith(AppRoutes.assets) ||
      (location.startsWith(AppRoutes.discovery) && hubTab == 3)) {
    return DesktopSidebarPrimaryId.assets;
  }

  if (location.startsWith(AppRoutes.scenes)) {
    return DesktopSidebarPrimaryId.scenes;
  }

  if (location.startsWith(AppRoutes.discovery) ||
      location.startsWith(AppRoutes.community) ||
      location == AppRoutes.scriptList ||
      location.startsWith('/script/')) {
    return DesktopSidebarPrimaryId.templates;
  }

  return DesktopSidebarPrimaryId.templates;
}

/// L1 primary that should be expanded / highlighted for [uri].
/// Empty when on Studio (创作) so no consumption branch looks selected.
String desktopSidebarActivePrimaryId(Uri uri) {
  final activeId = desktopSidebarActiveId(uri);
  if (activeId == DesktopSidebarPrimaryId.create) {
    return '';
  }
  for (final primary in desktopSidebarPrimaries) {
    if (primary.id == activeId) return primary.id;
    for (final child in primary.children) {
      if (child.id == activeId) return primary.id;
    }
  }
  return DesktopSidebarPrimaryId.templates;
}

@Deprecated('Use desktopSidebarActiveId')
String exploreSidebarActiveId(String location) =>
    desktopSidebarActiveId(Uri(path: location));

@Deprecated('Use desktopSidebarPrimaries')
class DesktopSidebarSection {
  const DesktopSidebarSection({required this.title, required this.items});

  final String title;
  final List<DesktopSidebarItem> items;
}

@Deprecated('Use desktopSidebarPrimaries')
final desktopSidebarSections = [
  for (final primary in desktopSidebarPrimaries)
    DesktopSidebarSection(
      title: primary.label,
      items: [
        DesktopSidebarItem(
          id: primary.id,
          label: primary.label,
          icon: primary.icon,
          route: primary.route,
        ),
        ...primary.children,
      ],
    ),
];

@Deprecated('Use desktopSidebarPrimaries')
final exploreSidebarSections = desktopSidebarSections;

class DesktopSidebar extends StatefulWidget {
  const DesktopSidebar({
    super.key,
    this.onItemTap,
  });

  final ValueChanged<DesktopSidebarItem>? onItemTap;

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  String? _userExpandedPrimaryId;

  void _navigate(BuildContext context, DesktopSidebarItem item) {
    widget.onItemTap?.call(item);
    if (item.onTap != null) {
      item.onTap!();
      return;
    }
    final route = item.route;
    if (route == null) return;
    final routePath = Uri.parse(route).path;
    if (shellTabRoutes.contains(routePath)) {
      context.go(route);
      return;
    }
    context.push(route);
  }

  void _onPrimaryTap(BuildContext context, DesktopSidebarPrimary primary) {
    final activePrimary =
        desktopSidebarActivePrimaryId(GoRouterState.of(context).uri);
    final currentExpanded =
        _userExpandedPrimaryId ??
        (activePrimary.isEmpty ? null : activePrimary);
    final isExpanded = currentExpanded == primary.id;

    if (primary.children.isNotEmpty && !isExpanded) {
      setState(() => _userExpandedPrimaryId = primary.id);
    }

    _navigate(
      context,
      DesktopSidebarItem(
        id: primary.id,
        label: primary.label,
        icon: primary.icon,
        route: primary.route,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final activeId = desktopSidebarActiveId(uri);
    final activePrimaryId = desktopSidebarActivePrimaryId(uri);
    final expandedPrimaryId =
        _userExpandedPrimaryId ??
        (activePrimaryId.isEmpty ? null : activePrimaryId);
    final createSelected = activeId == DesktopSidebarPrimaryId.create;

    return DesktopCard(
      width: 260,
      clipChild: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                DesktopChrome.gap,
                DesktopChrome.gap + 4,
                DesktopChrome.gap,
                DesktopChrome.gap,
              ),
              children: [
                const DesktopSidebarWindowHeader(),
                for (final primary in desktopSidebarPrimaries) ...[
                  _SidebarNavTile(
                    item: DesktopSidebarItem(
                      id: primary.id,
                      label: primary.label,
                      icon: primary.icon,
                      route: primary.route,
                    ),
                    selected: activePrimaryId == primary.id,
                    emphasized: true,
                    onTap: () => _onPrimaryTap(context, primary),
                  ),
                  AnimatedSize(
                    duration: AppMotion.normal,
                    curve: AppMotion.standard,
                    alignment: Alignment.topCenter,
                    child: expandedPrimaryId == primary.id &&
                            primary.children.isNotEmpty
                        ? Column(
                            children: [
                              for (final child in primary.children)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: _SidebarNavTile(
                                    item: child,
                                    selected: child.id == activeId,
                                    onTap: () => _navigate(context, child),
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              DesktopChrome.gap,
              DesktopChrome.gap,
              DesktopChrome.gap,
              DesktopChrome.gap * 2,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.floatingBarRadius),
                boxShadow: createSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.28),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: GlassButton(
                label: '创作',
                icon: Icons.movie_creation_outlined,
                filled: true,
                expand: true,
                onPressed: () => context.go(AppRoutes.studio),
              ),
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
    this.emphasized = false,
  });

  final DesktopSidebarItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool emphasized;

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
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: widget.emphasized ? 11 : 9,
              ),
              child: Row(
                children: [
                  Icon(
                    widget.item.icon,
                    size: widget.emphasized ? 20 : 18,
                    color: widget.selected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: widget.emphasized ? 14 : 13,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : (widget.emphasized
                                ? FontWeight.w600
                                : FontWeight.w500),
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
