class CharacterStyle {
  const CharacterStyle({
    this.presetKey = '',
    this.label = '',
    this.promptFragment = '',
    this.negativeFragment = '',
  });

  final String presetKey;
  final String label;
  final String promptFragment;
  final String negativeFragment;

  bool get isEmpty =>
      presetKey.isEmpty && label.isEmpty && promptFragment.isEmpty;

  Map<String, dynamic> toJson() => {
        if (presetKey.isNotEmpty) 'preset_key': presetKey,
        if (label.isNotEmpty) 'label': label,
        if (promptFragment.isNotEmpty) 'prompt_fragment': promptFragment,
        if (negativeFragment.isNotEmpty) 'negative_fragment': negativeFragment,
      };

  factory CharacterStyle.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const CharacterStyle();
    return CharacterStyle(
      presetKey: json['preset_key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      promptFragment: json['prompt_fragment'] as String? ?? '',
      negativeFragment: json['negative_fragment'] as String? ?? '',
    );
  }

  static CharacterStyle fromPresetLabel(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const CharacterStyle();
    final key = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^\w\u4e00-\u9fff-]'), '');
    return CharacterStyle(
      presetKey: key.isEmpty ? trimmed : key,
      label: trimmed,
      promptFragment: trimmed,
    );
  }
}

class CharacterTagRef {
  const CharacterTagRef({
    required this.id,
    required this.name,
    this.slug = '',
    this.namespace = 'character',
  });

  final int id;
  final String name;
  final String slug;
  final String namespace;
}

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
    this.avatarImageId,
    this.visibility = 1,
    this.style = const CharacterStyle(),
    this.tags = const [],
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
  final int? avatarImageId;
  final List<String> aliases;
  final int visibility;
  final CharacterStyle style;
  final List<CharacterTagRef> tags;
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
    final names = <String>{};
    if (workTitle.isNotEmpty) names.add(workTitle);
    for (final tag in tags) {
      if (tag.name.isNotEmpty) names.add(tag.name);
    }
    names.addAll(aliases);
    return names.toList(growable: false);
  }

  String get effectiveCoverUrl => coverUrl;

  String get styleLabel =>
      style.label.isNotEmpty ? style.label : style.presetKey;
}
