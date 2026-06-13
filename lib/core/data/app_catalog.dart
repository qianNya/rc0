import '../domain/screenplay/screenplay.dart';

/// 应用静态配置与剧本列表工具（不含假数据）
abstract final class AppCatalog {
  static const suggestedUploadTags = ['站姿', '坐姿', '街头', '海边', '柔光', '日常'];

  static const communityTabs = ['热门', '最新', '关注'];

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
