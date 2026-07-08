import '../../../core/data/app_catalog.dart';
import '../../../core/domain/screenplay/screenplay.dart';

List<Screenplay> filterTemplateScreenplays(
  List<Screenplay> source,
  int categoryIndex,
) {
  if (categoryIndex < 0 ||
      categoryIndex >= AppCatalog.communityCategoryChips.length) {
    return List<Screenplay>.from(source);
  }

  final chip = AppCatalog.communityCategoryChips[categoryIndex];
  if (chip == '全部') return List<Screenplay>.from(source);

  return source.where((screenplay) {
    final tags = screenplay.allTags;
    if (tags.isEmpty) return chip == '场景';
    return tags.any(
      (tag) =>
          tag.contains(chip) ||
          chip.contains(tag) ||
          _categoryKeywords(chip).any((kw) => tag.contains(kw)),
    );
  }).toList(growable: false);
}

List<Screenplay> sortTemplateScreenplays(
  List<Screenplay> source,
  int sortIndex,
) {
  final list = List<Screenplay>.from(source);
  switch (sortIndex) {
    case 1:
      list.sort((a, b) => _sortDate(b).compareTo(_sortDate(a)));
      break;
    case 2:
      list.sort((a, b) => b.views.compareTo(a.views));
      break;
    case 3:
      list.sort((a, b) => b.favorites.compareTo(a.favorites));
      break;
    case 0:
    default:
      list.sort((a, b) => b.likes.compareTo(a.likes));
      break;
  }
  return list;
}

DateTime _sortDate(Screenplay screenplay) {
  return screenplay.publishedAt ??
      screenplay.createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

List<String> _categoryKeywords(String chip) {
  switch (chip) {
    case '人像摄影':
      return ['人像', '摄影', '姿势'];
    case '构图模板':
      return ['构图'];
    case '光影人像':
      return ['光影', '人像'];
    case '场景':
      return ['场景', '街头', '室内', '海边'];
    default:
      return [chip];
  }
}
