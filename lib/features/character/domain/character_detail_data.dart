import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/domain/screenplay/screenplay_display.dart';
import '../../screenplay/data/screenplay_local_repository.dart';
import 'character_entry.dart';
import 'character_utils.dart';

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
    this.coverPath,
    this.linkedScriptId,
  });

  final String id;
  final String name;
  final String? coverPath;
  final String? linkedScriptId;
}

class CharacterWorkItem {
  const CharacterWorkItem({
    required this.id,
    required this.coverPath,
    required this.author,
    required this.likes,
    required this.featured,
  });

  final String id;
  final String coverPath;
  final String author;
  final int likes;
  final bool featured;
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

const _defaultPoseTitles = [
  ('海风回眸', '身体侧转 30°，目光越肩看向镜头'),
  ('漫步海岸', '自然迈步，手臂轻摆，保持松弛'),
  ('静坐远望', '坐姿稳定，视线望向海平线'),
  ('提裙转身', '裙摆扬起瞬间抓拍，快门 1/500'),
];

const _defaultCostumeNames = ['常服', '礼服', '泳装', '海边婚纱'];

CharacterDetailSnapshot buildCharacterDetailSnapshot({
  required CharacterEntry entry,
  required int referenceCount,
  String? localCover,
}) {
  final coverPath = (localCover != null && localCover.isNotEmpty)
      ? localCover
      : entry.effectiveCoverUrl;
  final scriptIds = screenplaysForCharacter(entry.id);
  final repo = ScreenplayLocalRepository.instance;

  var sceneCount = 0;
  var favoriteSum = 0;
  final works = <CharacterWorkItem>[];
  for (final id in scriptIds) {
    final screenplay = repo.documentById(id)?.toScreenplay();
    if (screenplay == null) continue;
    sceneCount += screenplay.sceneCount;
    favoriteSum += screenplay.favorites;
    works.add(
      CharacterWorkItem(
        id: screenplay.detailRouteId,
        coverPath: screenplay.effectiveCoverImagePath ?? '',
        author: screenplay.author,
        likes: screenplay.likes,
        featured: screenplay.tags.any((t) => t.contains('精选')),
      ),
    );
  }

  final costumes = _buildCostumes(entry, coverPath, scriptIds);
  final poses = _buildPoses(entry, coverPath);
  final tags = _buildTags(entry);
  final seed = entry.id;
  final favoriteCount = favoriteSum > 0
      ? favoriteSum
      : 1800 + (seed * 137) % 4200;
  final rating = (4.5 + (seed % 5) * 0.1).clamp(0.0, 5.0);

  return CharacterDetailSnapshot(
    entry: entry,
    rating: rating,
    favoriteCount: favoriteCount,
    stats: CharacterDetailStats(
      scriptCount: scriptIds.length,
      referenceCount: referenceCount,
      sceneCount: sceneCount > 0 ? sceneCount : 12 + seed % 40,
      costumeCount: costumes.length,
    ),
    tags: tags,
    poses: poses,
    costumes: costumes,
    works: works,
    avatarPath: coverPath,
    coverPath: coverPath,
  );
}

List<CharacterDetailTag> _buildTags(CharacterEntry entry) {
  final names = <String>{
    if (entry.workTitle.isNotEmpty) entry.workTitle,
    if (entry.gender == 2) '少女',
    if (entry.gender == 1) '少年',
    ...entry.aliases,
  };
  if (entry.summary.contains('海') || entry.appearance.contains('海')) {
    names.add('海边');
  }
  if (entry.personality.contains('温柔') || entry.summary.contains('温柔')) {
    names.add('温柔感');
  }
  if (names.isEmpty) names.add('人气角色');

  return names.take(6).toList().asMap().entries.map((e) {
    return CharacterDetailTag(
      name: e.value,
      color: _tagPalette[e.key % _tagPalette.length],
    );
  }).toList(growable: false);
}

List<CharacterPoseItem> _buildPoses(CharacterEntry entry, String coverPath) {
  final fromPersonality = entry.personality
      .split(RegExp(r'[。；\n]'))
      .map((s) => s.trim())
      .where((s) => s.length >= 4)
      .take(3)
      .toList();

  if (fromPersonality.isNotEmpty) {
    return fromPersonality.asMap().entries.map((e) {
      return CharacterPoseItem(
        id: 'pose-${entry.id}-${e.key}',
        title: e.value.length > 12 ? '${e.value.substring(0, 12)}…' : e.value,
        tips: e.value,
        coverPath: coverPath.isNotEmpty ? coverPath : null,
      );
    }).toList(growable: false);
  }

  return _defaultPoseTitles.asMap().entries.map((e) {
    return CharacterPoseItem(
      id: 'pose-${entry.id}-${e.key}',
      title: e.value.$1,
      tips: e.value.$2,
      coverPath: coverPath.isNotEmpty ? coverPath : null,
    );
  }).toList(growable: false);
}

List<CharacterCostumeItem> _buildCostumes(
  CharacterEntry entry,
  String coverPath,
  List<String> scriptIds,
) {
  final names = <String>{};
  for (final alias in entry.aliases) {
    if (alias.contains('婚纱') ||
        alias.contains('泳装') ||
        alias.contains('礼服') ||
        alias.contains('常服')) {
      names.add(alias);
    }
  }
  for (final name in _defaultCostumeNames) {
    names.add(name);
  }

  return names.take(4).toList().asMap().entries.map((e) {
    final scriptId = e.key < scriptIds.length ? scriptIds[e.key] : null;
    return CharacterCostumeItem(
      id: 'costume-${entry.id}-${e.key}',
      name: e.value,
      coverPath: coverPath.isNotEmpty ? coverPath : null,
      linkedScriptId: scriptId,
    );
  }).toList(growable: false);
}
