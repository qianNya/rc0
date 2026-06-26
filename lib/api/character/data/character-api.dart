class CharacterItem {
  CharacterItem({
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
    required this.avatarImageId,
    required this.aliases,
    required this.sort,
  });

  final num id;
  final num workId;
  final String workTitle;
  final String name;
  final String nameOrig;
  final String slug;
  final num gender;
  final String summary;
  final String appearance;
  final String personality;
  final String coverUrl;
  final num? avatarImageId;
  final List<String> aliases;
  final num sort;

  factory CharacterItem.fromJson(Map<String, dynamic> m) {
    final rawAliases = m['aliases'];
    final aliases = <String>[];
    if (rawAliases is List) {
      for (final item in rawAliases) {
        if (item is String) aliases.add(item);
      }
    }

    return CharacterItem(
      id: m['id'] ?? 0,
      workId: m['work_id'] ?? 0,
      workTitle: m['work_title'] as String? ?? '',
      name: m['name'] as String? ?? '',
      nameOrig: m['name_orig'] as String? ?? '',
      slug: m['slug'] as String? ?? '',
      gender: m['gender'] ?? 0,
      summary: m['summary'] as String? ?? '',
      appearance: m['appearance'] as String? ?? '',
      personality: m['personality'] as String? ?? '',
      coverUrl: m['cover_url'] as String? ?? '',
      avatarImageId: m['avatar_image_id'] as num?,
      aliases: aliases,
      sort: m['sort'] ?? 0,
    );
  }
}

class ListCharactersResp {
  ListCharactersResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<CharacterItem> list;
  final num total;
  final num page;
  final num pageSize;

  factory ListCharactersResp.fromJson(Map<String, dynamic> m) {
    final raw = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListCharactersResp(
      list: raw
          .whereType<Map<String, dynamic>>()
          .map(CharacterItem.fromJson)
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

class CharacterWriteBody {
  const CharacterWriteBody({
    this.workId = 0,
    required this.name,
    this.nameOrig = '',
    this.slug = '',
    this.gender = 0,
    this.summary = '',
    this.appearance = '',
    this.personality = '',
    this.coverUrl = '',
    this.avatarImageId,
    this.aliases = const [],
    this.sort = 0,
  });

  final int workId;
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
  final int sort;

  Map<String, dynamic> toJson() => {
        'work_id': workId,
        'name': name,
        'name_orig': nameOrig,
        'slug': slug,
        'gender': gender,
        if (summary.isNotEmpty) 'summary': summary,
        if (appearance.isNotEmpty) 'appearance': appearance,
        if (personality.isNotEmpty) 'personality': personality,
        'cover_url': coverUrl,
        if (avatarImageId != null) 'avatar_image_id': avatarImageId,
        'aliases': aliases,
        'sort': sort,
      };
}
