import 'package:flutter/material.dart';

import '../../../app/router/routes.dart';

/// Status of a labs feature entry.
enum FeatureLabsStatus { comingSoon, preview }

/// One upcoming or preview feature in the Labs catalog.
class FeatureLabsEntry {
  const FeatureLabsEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.group,
    required this.icon,
    this.status = FeatureLabsStatus.comingSoon,
    this.route,
  });

  final String id;
  final String title;
  final String subtitle;
  final String group;
  final IconData icon;
  final FeatureLabsStatus status;

  /// When set, tapping navigates here instead of showing inline placeholder.
  final String? route;
}

/// Static catalog of features not yet fully shipped.
abstract final class FeatureLabsCatalog {
  static const groups = ['AI 创作', '社交', '工具', '关联', '导航'];

  static const entries = <FeatureLabsEntry>[
    FeatureLabsEntry(
      id: 'import_script',
      title: 'AI 导入剧本',
      subtitle: '上传剧本文本智能解析',
      group: 'AI 创作',
      icon: Icons.upload_file_outlined,
      route: AppRoutes.createAiHubPath,
      status: FeatureLabsStatus.preview,
    ),
    FeatureLabsEntry(
      id: 'gen_outline',
      title: 'AI 生成大纲',
      subtitle: '根据创意生成剧本结构',
      group: 'AI 创作',
      icon: Icons.account_tree_outlined,
    ),
    FeatureLabsEntry(
      id: 'gen_plot',
      title: 'AI 扩写剧情',
      subtitle: '丰富场次与画面描述',
      group: 'AI 创作',
      icon: Icons.auto_stories_outlined,
    ),
    FeatureLabsEntry(
      id: 'gen_storyboard',
      title: 'AI 生成分镜',
      subtitle: '自动拆解为分镜画面',
      group: 'AI 创作',
      icon: Icons.view_comfy_outlined,
    ),
    FeatureLabsEntry(
      id: 'gen_prompt',
      title: '生成提示词',
      subtitle: '为画面生成 AI 提示词',
      group: 'AI 创作',
      icon: Icons.text_fields_outlined,
    ),
    FeatureLabsEntry(
      id: 'gen_image',
      title: '生成图片',
      subtitle: '根据分镜生成参考图',
      group: 'AI 创作',
      icon: Icons.image_outlined,
    ),
    FeatureLabsEntry(
      id: 'gen_video',
      title: '生成视频',
      subtitle: '将分镜转为动态预览',
      group: 'AI 创作',
      icon: Icons.videocam_outlined,
    ),
    FeatureLabsEntry(
      id: 'character_consistency',
      title: '角色一致性',
      subtitle: '保持角色外观统一',
      group: 'AI 创作',
      icon: Icons.people_outline,
    ),
    FeatureLabsEntry(
      id: 'membership',
      title: '会员',
      subtitle: '高级创作与存储权益',
      group: '社交',
      icon: Icons.workspace_premium_outlined,
    ),
    FeatureLabsEntry(
      id: 'following',
      title: '关注列表',
      subtitle: '查看你关注的创作者',
      group: '社交',
      icon: Icons.person_add_outlined,
    ),
    FeatureLabsEntry(
      id: 'followers',
      title: '粉丝列表',
      subtitle: '查看关注你的用户',
      group: '社交',
      icon: Icons.groups_outlined,
    ),
    FeatureLabsEntry(
      id: 'version_history',
      title: '版本历史',
      subtitle: '剧本修订记录与回滚',
      group: '工具',
      icon: Icons.history_outlined,
    ),
    FeatureLabsEntry(
      id: 'downloads',
      title: '下载',
      subtitle: '离线素材与导出包',
      group: '工具',
      icon: Icons.download_outlined,
    ),
    FeatureLabsEntry(
      id: 'analytics',
      title: '数据分析',
      subtitle: '作品浏览与互动统计',
      group: '工具',
      icon: Icons.insights_outlined,
    ),
    FeatureLabsEntry(
      id: 'help_center',
      title: '帮助中心',
      subtitle: '使用指南与常见问题',
      group: '工具',
      icon: Icons.help_outline,
    ),
    FeatureLabsEntry(
      id: 'help_feedback',
      title: '帮助与反馈',
      subtitle: '问题反馈与建议',
      group: '工具',
      icon: Icons.feedback_outlined,
    ),
    FeatureLabsEntry(
      id: 'lighting_academy',
      title: '灯光学院',
      subtitle: '系统学习布光技法',
      group: '工具',
      icon: Icons.school_outlined,
    ),
    FeatureLabsEntry(
      id: 'image_character_link',
      title: '关联角色',
      subtitle: '图片与角色 Wiki 绑定',
      group: '关联',
      icon: Icons.link_outlined,
    ),
    FeatureLabsEntry(
      id: 'storyboard',
      title: '分镜',
      subtitle: '独立分镜浏览与管理',
      group: '导航',
      icon: Icons.grid_view_rounded,
    ),
  ];

  static FeatureLabsEntry? byId(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// Maps legacy [AppRoutes.comingSoon] titles to catalog ids.
  static String? idForLegacyTitle(String title) {
    return switch (title) {
      'AI 导入剧本' => 'import_script',
      'AI 生成大纲' => 'gen_outline',
      'AI 扩写剧情' => 'gen_plot',
      'AI 生成分镜' => 'gen_storyboard',
      '生成提示词' => 'gen_prompt',
      '生成图片' => 'gen_image',
      '生成视频' => 'gen_video',
      '角色一致性' => 'character_consistency',
      '会员' => 'membership',
      '关注列表' => 'following',
      '粉丝列表' => 'followers',
      '版本历史' => 'version_history',
      '下载' => 'downloads',
      '数据分析' => 'analytics',
      '帮助中心' => 'help_center',
      '帮助与反馈' => 'help_feedback',
      '灯光学院' => 'lighting_academy',
      '关联角色' => 'image_character_link',
      '分镜' => 'storyboard',
      'AI 工具' => 'import_script',
      _ => null,
    };
  }

  static Map<String, List<FeatureLabsEntry>> groupedEntries() {
    final grouped = <String, List<FeatureLabsEntry>>{};
    for (final group in groups) {
      grouped[group] = entries.where((e) => e.group == group).toList();
    }
    return grouped;
  }
}
