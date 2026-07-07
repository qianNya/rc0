import 'dart:io';

void main() {
  const files = [
    'lib/features/screenplay/data/screenplay_image_upload_service.dart',
    'lib/features/gallery/data/image_gallery_repository.dart',
    'lib/features/screenplay/data/screenplay_publish_service.dart',
    'lib/features/screenplay/data/shoot_preset_repository.dart',
    'lib/features/profile/data/screenplay_favorite_repository.dart',
    'lib/features/profile/data/screenplay_like_repository.dart',
    'lib/features/scene/data/scene_repository.dart',
    'lib/features/gallery/data/image_tags_repository.dart',
    'lib/features/screenplay/data/frame_generation_repository.dart',
    'lib/features/ip/data/ip_repository.dart',
    'lib/features/user/data/user_profile_repository.dart',
    'lib/features/social/data/social_repository.dart',
    'lib/features/character/data/character_repository.dart',
    'lib/features/production_assets/data/asset_repository.dart',
    'lib/features/cine_equipment/data/equipment_repository.dart',
    'lib/features/screenplay/data/screenplay_tags_repository.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var text = file.readAsStringSync();
    text = text.replaceAllMapped(
      RegExp("import ['\"].*auth/data/auth_repository.dart['\"];\\r?\\n"),
      (_) => "import '../../../core/auth/auth_bridge.dart';\n",
    );
    text = text
        .replaceAll('AuthRepository.instance.isLoggedIn', 'AuthBridge.isLoggedIn')
        .replaceAll('AuthRepository.instance.hasAuthToken', 'AuthBridge.hasAuthToken')
        .replaceAll('AuthRepository.instance.profile', 'AuthBridge.profile')
        .replaceAll('AuthRepository.instance.addListener', 'AuthBridge.addListener')
        .replaceAll(
          'AuthRepository.instance.removeListener',
          'AuthBridge.removeListener',
        )
        .replaceAll(
          'AuthRepository.instance.refreshProfile',
          'AuthBridge.repository.refreshProfile',
        );
    file.writeAsStringSync(text);
    stdout.writeln('migrated $path');
  }
}
