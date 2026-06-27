import 'package:flutter/material.dart';

import 'preset_catalog.dart';
import '../domain/screenplay/screenplay.dart';

/// 发现页轮播 Banner 静态条目（暂无后端 API）。
class DiscoveryBannerItem {
  const DiscoveryBannerItem({
    required this.eyebrow,
    required this.title,
    this.imagePath,
  });

  final String eyebrow;
  final String title;
  final String? imagePath;
}

/// 发现页功能区快捷入口。
class DiscoveryQuickActionItem {
  const DiscoveryQuickActionItem({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

/// 应用静态配置与剧本列表工具
abstract final class AppCatalog {
  static const suggestedUploadTags = ['站姿', '坐姿', '街头', '海边', '柔光', '日常'];

  static const communityTabs = ['热门', '最新', '关注'];

  static const communityCategoryChips = [
    '全部',
    '人像摄影',
    '构图模板',
    '光影人像',
    '场景',
  ];

  static const communitySortTabs = ['热门', '最新', '最多使用', '精选'];

  static const feedTabs = ['发现', '关注', '推荐'];

  static const galleryTabs = ['图片', 'IP', '作品', '标签'];

  static const characterCategoryChips = [
    '全部',
    '热门',
    '原神',
    '崩坏星穹铁道',
    '鸣潮',
    '绝区零',
    '明日方舟',
    '原创',
    'JK',
    '女仆',
    '御姐',
    '校园',
    '古风',
  ];

  static const characterDetailTabs = ['剧本', '姿势', '作品', '服装', '资料'];

  static const myCharacterTabs = ['官方角色', '我的角色', '下载角色'];

  static const characterAiStyles = [
    '写实',
    '二次元',
    '国风',
    '赛博朋克',
    '摄影参考',
    'Cosplay',
  ];

  static const characterAiCounts = [1, 4, 8];

  static const sceneCategoryChips = [
    '全部',
    '热门',
    '自然风光',
    '城市建筑',
    '室内场景',
    '特色场景',
    '海边',
    '森林',
    '古镇',
    '校园',
    '天台',
    '咖啡馆',
    '地铁站',
    '酒店',
    '教堂',
    '商业街',
    '摄影棚',
  ];

  static const sceneDetailTabs = [
    '灵感图',
    '拍摄建议',
    '相关场景',
    '使用作品',
    '关联剧本',
  ];

  static const mySceneTabs = ['收藏', '使用过', '创建'];

  static const sceneAiStyles = [
    '写实',
    '电影感',
    '日系',
    '赛博朋克',
    '古风',
    '情绪片',
  ];

  static const sceneSortTabs = ['最新', '热门', '收藏最多', '使用最多'];

  static const sceneThemeTags = [
    'JK',
    '汉服',
    'Cosplay',
    '婚纱',
    '电影感',
    '情绪片',
    '少女写真',
    '情侣',
    '日常',
    '御姐',
    '赛博',
  ];

  static const sceneFilterStyles = [
    '全部风格',
    '写实',
    '电影感',
    '日系',
    '赛博朋克',
    '古风',
  ];

  /// IP `work_type` presets aligned with POST /works.
  static const ipWorkTypePresets = <({String label, int value})>[
    (label: '动漫', value: 2),
    (label: '游戏', value: 3),
    (label: '漫画', value: 4),
    (label: '轻小说', value: 5),
    (label: '其他', value: 1),
  ];

  static String ipWorkTypeLabel(int workType) {
    for (final preset in ipWorkTypePresets) {
      if (preset.value == workType) return preset.label;
    }
    return '类型 $workType';
  }

  static const discoveryBanners = [
    DiscoveryBannerItem(
      eyebrow: '本周精选',
      title: '海边少女摄影合集',
    ),
    DiscoveryBannerItem(
      eyebrow: '热门模板',
      title: '光影与构图的碰撞',
    ),
    DiscoveryBannerItem(
      eyebrow: '编辑推荐',
      title: '赛博朋克·夜之城',
    ),
  ];

  static const studioQuickStartActions = [
    DiscoveryQuickActionItem(
      label: '角色库',
      icon: Icons.person_outline,
      backgroundColor: Color(0xFFF0EBFF),
      iconColor: Color(0xFF6B4FE0),
    ),
    DiscoveryQuickActionItem(
      label: '场景库',
      icon: Icons.view_in_ar_outlined,
      backgroundColor: Color(0xFFE3F0FF),
      iconColor: Color(0xFF3B9EFF),
    ),
    DiscoveryQuickActionItem(
      label: '摄影预设',
      icon: Icons.camera_outlined,
      backgroundColor: Color(0xFFFFF4E0),
      iconColor: Color(0xFFFFB020),
    ),
    DiscoveryQuickActionItem(
      label: '我的素材',
      icon: Icons.perm_media_outlined,
      backgroundColor: Color(0xFFE6F7EE),
      iconColor: Color(0xFF34C759),
    ),
  ];

  static const discoveryQuickActions = [
    DiscoveryQuickActionItem(
      label: '图片',
      icon: Icons.photo_library_outlined,
      backgroundColor: Color(0xFFE3F0FF),
      iconColor: Color(0xFF3B9EFF),
    ),
    DiscoveryQuickActionItem(
      label: '剧本',
      icon: Icons.movie_creation_outlined,
      backgroundColor: Color(0xFFE8F4FF),
      iconColor: Color(0xFF4A90D9),
    ),
    DiscoveryQuickActionItem(
      label: '分镜',
      icon: Icons.grid_view_rounded,
      backgroundColor: Color(0xFFE6F7EE),
      iconColor: Color(0xFF34C759),
    ),
    DiscoveryQuickActionItem(
      label: '预设',
      icon: Icons.tune_outlined,
      backgroundColor: Color(0xFFFFF4E0),
      iconColor: Color(0xFFFFB020),
    ),
    DiscoveryQuickActionItem(
      label: '用户',
      icon: Icons.person_outline,
      backgroundColor: Color(0xFFF0EBFF),
      iconColor: Color(0xFF6B4FE0),
    ),
  ];

  static const marketTabs = ['推荐', '人像姿势', '构图', '光影', '场景模板'];

  static const profileTabs = ['作品', '模板', 'LUT', '收藏'];

  static const marketQuickActions = ['全部模板', '热榜', '最新', '免费区'];

  static const devicePresets = PresetCatalog.devicePresets;

  static const aspectRatioPresets = PresetCatalog.aspectRatioPresets;

  static const lightingPresets = PresetCatalog.lightingPresets;

  static const defaultShootParams = PresetCatalog.defaultShootParams;

  static const builtInShootPresets = PresetCatalog.builtInShootPresets;

  static const shotTypePresets = ['全景', '中景', '近景', '特写', '大特写'];
  static const cameraAnglePresets = ['平视', '俯拍', '仰拍', '鸟瞰', '虫视'];
  static const movementPresets = ['固定', '推', '拉', '摇', '移', '跟', '升降'];
  static const lensMmPresets = ['24mm', '35mm', '50mm', '85mm', '135mm'];
  static const compositionPresets = ['三分法', '居中', '对称', '引导线', '框架'];
  static const durationSecPresets = [1, 2, 3, 5, 8, 10];
  static const weatherPresets = ['晴天', '阴天', '雨天', '雪天', '大雾', '黄昏'];

  static const communityShootPresets = PresetCatalog.communityShootPresets;

  static const presetCategories = PresetCatalog.categories;

  static const placeholderAuthor = '光影捕手';
  static const placeholderLevel = 5;

  static const profileMenuItems = ['我的收藏', '我的上传', '浏览历史', '设置'];
}

List<String> buildTagFilters(List<Screenplay> scripts) {
  final tags = <String>{};
  for (final script in scripts) {
    tags.addAll(script.allTags);
  }
  final sorted = tags.toList()..sort();
  return ['全部', ...sorted];
}

List<Screenplay> filterScreenplaysByTag(
  List<Screenplay> scripts,
  String? tag,
) {
  if (tag == null || tag == '全部') return scripts;
  return scripts
      .where((script) => script.allTags.contains(tag))
      .toList(growable: false);
}
