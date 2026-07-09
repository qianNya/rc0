import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'character_entry.dart';

class CharacterDetailTag {
  const CharacterDetailTag({required this.name, required this.color});

  final String name;
  final Color color;
}

class CharacterDetailStats {
  const CharacterDetailStats({
    required this.scriptCount,
    required this.referenceCount,
    required this.sceneCount,
    required this.costumeCount,
  });

  final int scriptCount;
  final int referenceCount;
  final int sceneCount;
  final int costumeCount;
}

/// Pose is phase-2; keep type for ComingSoon empty state.
class CharacterPoseItem {
  const CharacterPoseItem({
    required this.id,
    required this.title,
    required this.tips,
    this.coverPath,
  });

  final String id;
  final String title;
  final String tips;
  final String? coverPath;
}

class CharacterCostumeItem {
  const CharacterCostumeItem({
    required this.id,
    required this.name,
    this.coverUrl = '',
    this.description = '',
    this.isDefault = false,
    this.slug = '',
  });

  final int id;
  final String name;
  final String coverUrl;
  final String description;
  final bool isDefault;
  final String slug;

  /// Backward-compatible alias used by older tab widgets.
  String? get coverPath => coverUrl.isEmpty ? null : coverUrl;
  String? get linkedScriptId => null;
}

class CharacterPropItem {
  const CharacterPropItem({
    required this.id,
    required this.name,
    this.description = '',
    this.coverUrl = '',
    this.ownerType = 1,
    this.ownerId = 0,
  });

  final int id;
  final String name;
  final String description;
  final String coverUrl;
  final int ownerType;
  final int ownerId;
}

class CharacterSceneAffinityItem {
  const CharacterSceneAffinityItem({
    required this.id,
    required this.sceneId,
    this.weight = 1,
    this.note = '',
    this.sceneTitle = '',
    this.sceneCoverUrl = '',
  });

  final int id;
  final int sceneId;
  final int weight;
  final String note;
  final String sceneTitle;
  final String sceneCoverUrl;

  String get displayTitle =>
      sceneTitle.isNotEmpty ? sceneTitle : '场景 #$sceneId';
}

class CharacterWorkItem {
  const CharacterWorkItem({
    required this.id,
    required this.title,
    this.coverPath = '',
    this.author = '',
    this.likes = 0,
    this.featured = false,
    this.kind = 0,
    this.publishStatus = 0,
  });

  final String id;
  final String title;
  final String coverPath;
  final String author;
  final int likes;
  final bool featured;
  final int kind;
  final int publishStatus;
}

class CharacterDetailSnapshot {
  const CharacterDetailSnapshot({
    required this.entry,
    required this.rating,
    required this.favoriteCount,
    required this.stats,
    required this.tags,
    required this.poses,
    required this.costumes,
    required this.props,
    required this.affinities,
    required this.works,
    required this.avatarPath,
    required this.coverPath,
  });

  final CharacterEntry entry;
  final double rating;
  final int favoriteCount;
  final CharacterDetailStats stats;
  final List<CharacterDetailTag> tags;
  final List<CharacterPoseItem> poses;
  final List<CharacterCostumeItem> costumes;
  final List<CharacterPropItem> props;
  final List<CharacterSceneAffinityItem> affinities;
  final List<CharacterWorkItem> works;
  final String avatarPath;
  final String coverPath;

  String get description {
    final parts = <String>[
      if (entry.summary.isNotEmpty) entry.summary,
      if (entry.appearance.isNotEmpty) entry.appearance,
    ];
    return parts.join('\n\n');
  }
}

const _tagPalette = [
  AppColors.accent,
  AppColors.profileGradientEnd,
  AppColors.badgeHot,
  AppColors.badgeNew,
  AppColors.badgeTemplate,
];

CharacterDetailSnapshot buildCharacterDetailSnapshot({
  required CharacterEntry entry,
  required int referenceCount,
  String? localCover,
  List<CharacterCostumeItem> costumes = const [],
  List<CharacterPropItem> props = const [],
  List<CharacterSceneAffinityItem> affinities = const [],
  List<CharacterWorkItem> works = const [],
  List<CharacterDetailTag>? tags,
}) {
  final coverPath = (localCover != null && localCover.isNotEmpty)
      ? localCover
      : entry.effectiveCoverUrl;

  final resolvedTags = tags ?? _buildTagsFromEntry(entry);
  final seed = entry.id;

  return CharacterDetailSnapshot(
    entry: entry,
    rating: (4.5 + (seed % 5) * 0.1).clamp(0.0, 5.0),
    favoriteCount: 0,
    stats: CharacterDetailStats(
      scriptCount: works.length,
      referenceCount: referenceCount,
      sceneCount: affinities.length,
      costumeCount: costumes.length,
    ),
    tags: resolvedTags,
    poses: const [],
    costumes: costumes,
    props: props,
    affinities: affinities,
    works: works,
    avatarPath: coverPath,
    coverPath: coverPath,
  );
}

List<CharacterDetailTag> _buildTagsFromEntry(CharacterEntry entry) {
  final names = <String>{
    if (entry.workTitle.isNotEmpty) entry.workTitle,
    if (entry.styleLabel.isNotEmpty) entry.styleLabel,
    for (final tag in entry.tags)
      if (tag.name.isNotEmpty) tag.name,
  };
  if (names.isEmpty) {
    names.addAll(entry.aliases.take(4));
  }
  if (names.isEmpty) names.add('角色');

  return names.take(8).toList().asMap().entries.map((e) {
    return CharacterDetailTag(
      name: e.value,
      color: _tagPalette[e.key % _tagPalette.length],
    );
  }).toList(growable: false);
}
