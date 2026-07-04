import 'package:flutter/material.dart';

import '../../../app/router/routes.dart';
import '../domain/asset_category_ref.dart';

/// Built-in production asset domains surfaced in Wiki「资产」.
class WikiAssetDomain {
  const WikiAssetDomain({
    required this.slug,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.iconColor,
    required this.backgroundColor,
    this.usePush = true,
    this.acceptsUserItems = false,
  });

  final String slug;
  final String label;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color iconColor;
  final Color backgroundColor;
  final bool usePush;
  final bool acceptsUserItems;

  AssetCategoryRef get categoryRef => AssetCategoryRef(
        id: AssetCategoryRef.builtinId(slug),
        label: label,
        isBuiltin: true,
        route: route,
        subtitle: subtitle,
      );
}

abstract final class AssetCatalog {
  static final builtinDomains = <WikiAssetDomain>[
    WikiAssetDomain(
      slug: 'camera',
      label: '摄影设备',
      subtitle: '机身、镜头与摄影机组合',
      icon: Icons.videocam_outlined,
      route: AppRoutes.equipment,
      iconColor: Color(0xFF5E5CE6),
      backgroundColor: Color(0xFFEEEDFF),
      acceptsUserItems: true,
    ),
    WikiAssetDomain(
      slug: 'lighting',
      label: '灯具',
      subtitle: '灯光方案与布光参考',
      icon: Icons.wb_incandescent_outlined,
      route: AppRoutes.lighting,
      iconColor: Color(0xFFFFB020),
      backgroundColor: Color(0xFFFFF4E0),
      usePush: false,
      acceptsUserItems: true,
    ),
    WikiAssetDomain(
      slug: 'scene',
      label: '场景库',
      subtitle: '可复用空间与氛围资产',
      icon: Icons.landscape_outlined,
      route: AppRoutes.scenes,
      iconColor: Color(0xFF3B9EFF),
      backgroundColor: Color(0xFFE3F0FF),
      usePush: false,
    ),
    WikiAssetDomain(
      slug: 'action',
      label: '动作 Wiki',
      subtitle: '景别、运镜与姿态参考',
      icon: Icons.accessibility_new_outlined,
      route: AppRoutes.action,
      iconColor: Color(0xFF34C759),
      backgroundColor: Color(0xFFE6F7EE),
      usePush: false,
    ),
    WikiAssetDomain(
      slug: 'preset',
      label: '摄影预设',
      subtitle: '设备与画幅模板',
      icon: Icons.tune_outlined,
      route: AppRoutes.shootPresetPicker(mode: 'manage'),
      iconColor: Color(0xFFFF9500),
      backgroundColor: Color(0xFFFFF4E0),
    ),
    WikiAssetDomain(
      slug: 'library',
      label: '素材图库',
      subtitle: '参考图与灵感收藏',
      icon: Icons.photo_library_outlined,
      route: AppRoutes.library,
      iconColor: Color(0xFF3B9EFF),
      backgroundColor: Color(0xFFE3F0FF),
    ),
  ];

  static WikiAssetDomain? domainForSlug(String slug) {
    for (final domain in builtinDomains) {
      if (domain.slug == slug) return domain;
    }
    return null;
  }

  static WikiAssetDomain? domainForCategoryId(String categoryId) {
    final slug = AssetCategoryRef.builtinSlug(categoryId);
    if (slug == null) return null;
    return domainForSlug(slug);
  }

  static List<AssetCategoryRef> allBuiltinCategoryRefs() =>
      builtinDomains.map((d) => d.categoryRef).toList(growable: false);
}
