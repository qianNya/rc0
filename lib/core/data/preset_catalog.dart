import 'package:flutter/material.dart';

import '../../features/screenplay/domain/shoot_params.dart';
import '../../features/screenplay/domain/shoot_preset.dart';

/// Static seed data for the shoot preset marketplace.
abstract final class PresetCatalog {
  static const devicePresets = [
    'iPhone 15 Pro',
    'Sony A7IV',
    'Canon R5',
    '富士 X-T5',
  ];

  static const aspectRatioPresets = ['16:9', '2.39:1', '4:3', '1:1', '9:16'];

  static const lightingPresets = ['自然光', '柔光', '逆光', '侧光', '伦勃朗光'];

  static const defaultShootParams = ShootParams(
    device: 'iPhone 15 Pro',
    aspectRatio: '4:3',
    lighting: '自然光',
  );

  static const builtInShootPresets = <ShootPreset>[
    ShootPreset(
      id: 'builtin-phone-daily',
      label: '手机日常',
      params: ShootParams(
        device: 'iPhone 15 Pro',
        aspectRatio: '4:3',
        lighting: '自然光',
      ),
      isBuiltIn: true,
      scope: ShootPresetScope.official,
      categoryId: 'vlog',
      likeCount: 23000,
      usageCount: 120000,
      rating: 4.8,
    ),
    ShootPreset(
      id: 'builtin-sony-cinematic',
      label: '电影宽幅',
      params: ShootParams(
        device: 'Sony A7IV',
        aspectRatio: '2.39:1',
        lighting: '侧光',
      ),
      isBuiltIn: true,
      scope: ShootPresetScope.official,
      categoryId: 'movie',
      likeCount: 56000,
      usageCount: 123000,
      rating: 4.9,
    ),
    ShootPreset(
      id: 'builtin-canon-portrait',
      label: '人像柔光',
      params: ShootParams(
        device: 'Canon R5',
        aspectRatio: '4:3',
        lighting: '柔光',
      ),
      isBuiltIn: true,
      scope: ShootPresetScope.official,
      categoryId: 'portrait',
      likeCount: 41000,
      usageCount: 98000,
      rating: 4.7,
    ),
    ShootPreset(
      id: 'builtin-fuji-street',
      label: '街头纪实',
      params: ShootParams(
        device: '富士 X-T5',
        aspectRatio: '16:9',
        lighting: '侧光',
      ),
      isBuiltIn: true,
      scope: ShootPresetScope.official,
      categoryId: 'movie',
      likeCount: 28000,
      usageCount: 67000,
      rating: 4.6,
    ),
    ShootPreset(
      id: 'builtin-phone-vertical',
      label: '竖屏短视频',
      params: ShootParams(
        device: 'iPhone 15 Pro',
        aspectRatio: '9:16',
        lighting: '柔光',
      ),
      isBuiltIn: true,
      scope: ShootPresetScope.official,
      categoryId: 'vlog',
      likeCount: 72000,
      usageCount: 210000,
      rating: 4.8,
    ),
  ];

  static const communityShootPresets = <ShootPreset>[
    ShootPreset(
      id: 'community-xhs-cream',
      label: '小红书奶油风',
      params: ShootParams(
        device: 'iPhone 15 Pro',
        aspectRatio: '4:3',
        lighting: '柔光',
      ),
      scope: ShootPresetScope.community,
      categoryId: 'portrait',
      authorName: '夏三七',
      likeCount: 53000,
      downloadCount: 21000,
      rating: 4.8,
    ),
    ShootPreset(
      id: 'community-fuji-film',
      label: '富士胶片风',
      params: ShootParams(
        device: '富士 X-T5',
        aspectRatio: '3:2',
        lighting: '自然光',
      ),
      scope: ShootPresetScope.community,
      categoryId: 'film',
      authorName: '胶片旅人',
      likeCount: 48000,
      downloadCount: 18500,
      rating: 4.7,
    ),
    ShootPreset(
      id: 'community-shinkai',
      label: '新海诚风格',
      params: ShootParams(
        device: 'Sony A7IV',
        aspectRatio: '16:9',
        lighting: '逆光',
      ),
      scope: ShootPresetScope.community,
      categoryId: 'anime',
      authorName: '云间映画',
      likeCount: 62000,
      downloadCount: 29000,
      rating: 4.9,
    ),
    ShootPreset(
      id: 'community-hk-night',
      label: '港风夜景',
      params: ShootParams(
        device: 'Canon R5',
        aspectRatio: '2.39:1',
        lighting: '侧光',
      ),
      scope: ShootPresetScope.community,
      categoryId: 'movie',
      authorName: '霓虹捕手',
      likeCount: 37000,
      downloadCount: 14200,
      rating: 4.6,
    ),
    ShootPreset(
      id: 'community-cyber-night',
      label: '赛博夜景',
      params: ShootParams(
        device: 'Sony A7IV',
        aspectRatio: '16:9',
        lighting: '逆光',
      ),
      scope: ShootPresetScope.community,
      categoryId: 'movie',
      authorName: '夜行者',
      likeCount: 29000,
      downloadCount: 11800,
      rating: 4.5,
    ),
  ];

  static const categories = <({String id, String label, IconData icon})>[
    (id: 'all', label: '全部', icon: Icons.grid_view_rounded),
    (id: 'portrait', label: '人像', icon: Icons.face_outlined),
    (id: 'movie', label: '电影', icon: Icons.movie_outlined),
    (id: 'vlog', label: 'Vlog', icon: Icons.videocam_outlined),
    (id: 'film', label: '胶片', icon: Icons.camera_roll_outlined),
    (id: 'anime', label: '二次元', icon: Icons.auto_awesome_outlined),
    (id: 'commercial', label: '商业广告', icon: Icons.campaign_outlined),
  ];
}
