import '../domain/screenplay/screenplay.dart';

/// 应用静态配置与剧本列表工具
abstract final class AppCatalog {
  static const suggestedUploadTags = ['站姿', '坐姿', '街头', '海边', '柔光', '日常'];

  static const communityTabs = ['热门', '最新', '关注'];

  static const feedTabs = ['推荐', '关注', '最新', '人像', '光影', '情绪'];

  static const marketTabs = ['推荐', '人像姿势', '构图', '光影', '场景模板'];

  static const profileTabs = ['作品', '模板', 'LUT', '收藏'];

  static const wizardSteps = ['基本信息', '结构', '剧本', '参数', '音频', '发布'];

  static const marketQuickActions = ['全部模板', '热榜', '最新', '免费区'];

  static const aspectRatioPresets = ['16:9', '2.39:1', '4:3', '1:1', '9:16'];

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
