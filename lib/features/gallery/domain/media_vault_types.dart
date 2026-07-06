import 'package:flutter/material.dart';

/// Primary image categories in the media vault.
enum MediaVaultCategory {
  all,
  photography,
  aiArt,
  sceneRef,
  equipment,
  storyboard;

  String get label => switch (this) {
        MediaVaultCategory.all => '全部',
        MediaVaultCategory.photography => '摄影',
        MediaVaultCategory.aiArt => 'AI生成',
        MediaVaultCategory.sceneRef => '场景参考',
        MediaVaultCategory.equipment => '设备',
        MediaVaultCategory.storyboard => '分镜',
      };

  String? get badge => switch (this) {
        MediaVaultCategory.all => null,
        MediaVaultCategory.photography => null,
        MediaVaultCategory.aiArt => 'AI',
        MediaVaultCategory.sceneRef => null,
        MediaVaultCategory.equipment => '设备',
        MediaVaultCategory.storyboard => '分镜',
      };

  Color get badgeColor => switch (this) {
        MediaVaultCategory.aiArt => const Color(0xFF7C5CFF),
        MediaVaultCategory.equipment => const Color(0xFFE8E8E8),
        MediaVaultCategory.storyboard => const Color(0xFFE91E8C),
        _ => const Color(0xFF2FE6A8),
      };
}

/// Sidebar navigation sections.
enum MediaVaultSection {
  library,
  albums,
  favorites,
  tags,
  trash;

  String get label => switch (this) {
        MediaVaultSection.library => '图库',
        MediaVaultSection.albums => '专辑',
        MediaVaultSection.favorites => '收藏',
        MediaVaultSection.tags => '标签',
        MediaVaultSection.trash => '回收站',
      };

  IconData get icon => switch (this) {
        MediaVaultSection.library => Icons.grid_view_rounded,
        MediaVaultSection.albums => Icons.photo_album_outlined,
        MediaVaultSection.favorites => Icons.star_outline_rounded,
        MediaVaultSection.tags => Icons.sell_outlined,
        MediaVaultSection.trash => Icons.delete_outline_rounded,
      };

  IconData get selectedIcon => switch (this) {
        MediaVaultSection.library => Icons.grid_view_rounded,
        MediaVaultSection.albums => Icons.photo_album,
        MediaVaultSection.favorites => Icons.star_rounded,
        MediaVaultSection.tags => Icons.sell,
        MediaVaultSection.trash => Icons.delete,
      };
}
