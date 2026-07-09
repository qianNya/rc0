class CharacterTagItem {
  CharacterTagItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.namespace,
  });

  final num id;
  final String name;
  final String slug;
  final String namespace;

  factory CharacterTagItem.fromJson(Map<String, dynamic> m) {
    return CharacterTagItem(
      id: m['id'] ?? 0,
      name: m['name'] as String? ?? '',
      slug: m['slug'] as String? ?? '',
      namespace: m['namespace'] as String? ?? '',
    );
  }
}

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
    required this.styleJson,
    required this.visibility,
    required this.tags,
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
  final Map<String, dynamic> styleJson;
  final num visibility;
  final List<CharacterTagItem> tags;
  final num sort;

  factory CharacterItem.fromJson(Map<String, dynamic> m) {
    final rawAliases = m['aliases'];
    final aliases = <String>[];
    if (rawAliases is List) {
      for (final item in rawAliases) {
        if (item is String) aliases.add(item);
      }
    }

    final rawStyle = m['style_json'];
    final styleJson = rawStyle is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawStyle)
        : (rawStyle is Map
            ? Map<String, dynamic>.from(rawStyle)
            : <String, dynamic>{});

    final rawTags = m['tags'];
    final tags = <CharacterTagItem>[];
    if (rawTags is List) {
      for (final item in rawTags) {
        if (item is Map<String, dynamic>) {
          tags.add(CharacterTagItem.fromJson(item));
        } else if (item is Map) {
          tags.add(CharacterTagItem.fromJson(Map<String, dynamic>.from(item)));
        }
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
      styleJson: styleJson,
      visibility: m['visibility'] ?? 1,
      tags: tags,
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
    this.styleJson = const {},
    this.visibility = 1,
    this.tagIds,
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
  final Map<String, dynamic> styleJson;
  final int visibility;
  final List<int>? tagIds;
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
        'style_json': styleJson,
        'visibility': visibility,
        if (tagIds != null) 'tags': tagIds,
        'sort': sort,
      };
}

class CostumeItem {
  CostumeItem({
    required this.id,
    required this.characterId,
    required this.name,
    required this.slug,
    required this.description,
    required this.coverUrl,
    required this.coverImageId,
    required this.isDefault,
    required this.sort,
    required this.tags,
  });

  final num id;
  final num characterId;
  final String name;
  final String slug;
  final String description;
  final String coverUrl;
  final num? coverImageId;
  final bool isDefault;
  final num sort;
  final dynamic tags;

  factory CostumeItem.fromJson(Map<String, dynamic> m) {
    return CostumeItem(
      id: m['id'] ?? 0,
      characterId: m['character_id'] ?? 0,
      name: m['name'] as String? ?? '',
      slug: m['slug'] as String? ?? '',
      description: m['description'] as String? ?? '',
      coverUrl: m['cover_url'] as String? ?? '',
      coverImageId: m['cover_image_id'] as num?,
      isDefault: m['is_default'] == true,
      sort: m['sort'] ?? 0,
      tags: m['tags'],
    );
  }
}

class CostumeWriteBody {
  const CostumeWriteBody({
    required this.name,
    this.slug = '',
    this.description = '',
    this.coverUrl = '',
    this.coverImageId,
    this.isDefault = false,
    this.sort = 0,
    this.tags = const [],
  });

  final String name;
  final String slug;
  final String description;
  final String coverUrl;
  final int? coverImageId;
  final bool isDefault;
  final int sort;
  final dynamic tags;

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        if (description.isNotEmpty) 'description': description,
        'cover_url': coverUrl,
        if (coverImageId != null) 'cover_image_id': coverImageId,
        'is_default': isDefault,
        'sort': sort,
        'tags': tags,
      };
}

class PropItem {
  PropItem({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.coverImageId,
    required this.sort,
  });

  final num id;
  final num ownerType;
  final num ownerId;
  final String name;
  final String description;
  final String coverUrl;
  final num? coverImageId;
  final num sort;

  factory PropItem.fromJson(Map<String, dynamic> m) {
    return PropItem(
      id: m['id'] ?? 0,
      ownerType: m['owner_type'] ?? 0,
      ownerId: m['owner_id'] ?? 0,
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      coverUrl: m['cover_url'] as String? ?? '',
      coverImageId: m['cover_image_id'] as num?,
      sort: m['sort'] ?? 0,
    );
  }
}

class PropWriteBody {
  const PropWriteBody({
    required this.name,
    this.description = '',
    this.coverUrl = '',
    this.coverImageId,
    this.sort = 0,
  });

  final String name;
  final String description;
  final String coverUrl;
  final int? coverImageId;
  final int sort;

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description.isNotEmpty) 'description': description,
        'cover_url': coverUrl,
        if (coverImageId != null) 'cover_image_id': coverImageId,
        'sort': sort,
      };
}

class SceneAffinityItem {
  SceneAffinityItem({
    required this.id,
    required this.characterId,
    required this.sceneId,
    required this.weight,
    required this.note,
  });

  final num id;
  final num characterId;
  final num sceneId;
  final num weight;
  final String note;

  factory SceneAffinityItem.fromJson(Map<String, dynamic> m) {
    return SceneAffinityItem(
      id: m['id'] ?? 0,
      characterId: m['character_id'] ?? 0,
      sceneId: m['scene_id'] ?? 0,
      weight: m['weight'] ?? 1,
      note: m['note'] as String? ?? '',
    );
  }
}

class SceneAffinityWriteItem {
  const SceneAffinityWriteItem({
    required this.sceneId,
    this.weight = 1,
    this.note = '',
  });

  final int sceneId;
  final int weight;
  final String note;

  Map<String, dynamic> toJson() => {
        'scene_id': sceneId,
        'weight': weight,
        'note': note,
      };
}

class CastItem {
  CastItem({
    required this.id,
    required this.screenplayId,
    required this.characterId,
    required this.defaultCostumeId,
    required this.billingName,
    required this.sort,
  });

  final num id;
  final num screenplayId;
  final num characterId;
  final num? defaultCostumeId;
  final String billingName;
  final num sort;

  factory CastItem.fromJson(Map<String, dynamic> m) {
    return CastItem(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      characterId: m['character_id'] ?? 0,
      defaultCostumeId: m['default_costume_id'] as num?,
      billingName: m['billing_name'] as String? ?? '',
      sort: m['sort'] ?? 0,
    );
  }
}

class CastWriteItem {
  const CastWriteItem({
    required this.characterId,
    this.defaultCostumeId,
    this.billingName = '',
    this.sort = 0,
  });

  final int characterId;
  final int? defaultCostumeId;
  final String billingName;
  final int sort;

  Map<String, dynamic> toJson() => {
        'character_id': characterId,
        if (defaultCostumeId != null) 'default_costume_id': defaultCostumeId,
        'billing_name': billingName,
        'sort': sort,
      };
}

class CharacterScreenplayItem {
  CharacterScreenplayItem({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.kind,
    required this.publishStatus,
  });

  final num id;
  final String title;
  final String coverUrl;
  final num kind;
  final num publishStatus;

  factory CharacterScreenplayItem.fromJson(Map<String, dynamic> m) {
    return CharacterScreenplayItem(
      id: m['id'] ?? 0,
      title: m['title'] as String? ?? '',
      coverUrl: m['cover_url'] as String? ?? '',
      kind: m['kind'] ?? 0,
      publishStatus: m['publish_status'] ?? 0,
    );
  }
}

class ListCharacterScreenplaysResp {
  ListCharacterScreenplaysResp({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  final List<CharacterScreenplayItem> list;
  final num total;
  final num page;
  final num pageSize;

  factory ListCharacterScreenplaysResp.fromJson(Map<String, dynamic> m) {
    final raw = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    return ListCharacterScreenplaysResp(
      list: raw
          .whereType<Map<String, dynamic>>()
          .map(CharacterScreenplayItem.fromJson)
          .toList(),
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
}

List<T> parseCharacterListPayload<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data['items'] ?? data['list'] ?? [];
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}
