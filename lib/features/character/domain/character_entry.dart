class CharacterEntry {
  const CharacterEntry({
    required this.id,
    required this.workId,
    required this.workTitle,
    required this.name,
    required this.nameOrig,
    required this.slug,
    required this.gender,
    required this.summary,
    required this.appearance,
    required this.personality,
    required this.coverUrl,
    required this.aliases,
    required this.sort,
  });

  final int id;
  final int workId;
  final String workTitle;
  final String name;
  final String nameOrig;
  final String slug;
  final int gender;
  final String summary;
  final String appearance;
  final String personality;
  final String coverUrl;
  final List<String> aliases;
  final int sort;

  String get genderLabel {
    switch (gender) {
      case 1:
        return '男';
      case 2:
        return '女';
      case 3:
        return '其他';
      default:
        return '未知';
    }
  }

  String get displaySubtitle {
    if (workTitle.isNotEmpty) return workTitle;
    if (workId == 0) return '独立 OC';
    return '';
  }

  List<String> get displayTags {
    final tags = <String>{};
    if (workTitle.isNotEmpty) tags.add(workTitle);
    tags.addAll(aliases);
    return tags.toList(growable: false);
  }

  String get effectiveCoverUrl => coverUrl;
}
