import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/character/data/character_repository.dart';
import '../../../features/cine_equipment/data/equipment_repository.dart';
import '../../../features/gallery/data/image_gallery_repository.dart';
import '../../../features/gallery/data/image_tags_repository.dart';
import '../../../features/ip/data/ip_repository.dart';
import '../../../features/production_assets/data/asset_repository.dart';
import '../../../features/scene/data/scene_repository.dart';
import '../../../features/screenplay/data/screenplay_local_repository.dart';
import '../../../features/screenplay/data/screenplay_tags_repository.dart';
import '../../../features/screenplay/data/shoot_preset_repository.dart';

import '../../features/social/data/social_repository.dart';
import 'auth_providers.dart';

/// Repository providers bridge legacy singletons during Riverpod migration.
final screenplayLocalRepositoryProvider = Provider<ScreenplayLocalRepository>(
  (ref) {
    ref.watch(authSessionProvider);
    return ScreenplayLocalRepository.instance;
  },
);

final screenplayTagsRepositoryProvider = Provider<ScreenplayTagsRepository>(
  (ref) {
    ref.watch(authSessionProvider);
    return ScreenplayTagsRepository.instance;
  },
);

final imageGalleryRepositoryProvider = Provider<ImageGalleryRepository>((ref) {
  ref.watch(authSessionProvider);
  return ImageGalleryRepository.instance;
});

final imageTagsRepositoryProvider = Provider<ImageTagsRepository>((ref) {
  ref.watch(authSessionProvider);
  return ImageTagsRepository.instance;
});

final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  ref.watch(authSessionProvider);
  return SceneRepository.instance;
});

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  ref.watch(authSessionProvider);
  return CharacterRepository.instance;
});

final ipRepositoryProvider = Provider<IpRepository>((ref) {
  ref.watch(authSessionProvider);
  return IpRepository.instance;
});

final shootPresetRepositoryProvider = Provider<ShootPresetRepository>((ref) {
  ref.watch(authSessionProvider);
  return ShootPresetRepository.instance;
});

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  ref.watch(authSessionProvider);
  return EquipmentRepository.instance;
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  ref.watch(authSessionProvider);
  return AssetRepository.instance;
});

/// Social engagement facade (like/follow); converges to community feature.
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  ref.watch(authSessionProvider);
  return SocialRepository.instance;
});
