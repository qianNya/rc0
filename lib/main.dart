import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/network/api_auth.dart';
import 'app/app.dart';
import 'core/platform/platform_features.dart';
import 'core/services/image_favorite_store.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/favorites/data/image_favorite_repository.dart';
import 'features/ip/data/ip_repository.dart';
import 'features/gallery/data/image_gallery_repository.dart';
import 'features/gallery/data/image_tags_repository.dart';
import 'features/screenplay/data/screenplay_tags_repository.dart';
import 'features/screenplay/data/shoot_preset_repository.dart';
import 'features/screenplay/data/screenplay_local_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (shouldUseDesktopWindowChrome) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1280, 720),
        center: true,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  await ScreenplayLocalRepository.instance.initialize();
  await ThemeModeNotifier.instance.initialize();
  await AuthRepository.instance.initialize();
  onApiUnauthorized = AuthRepository.instance.handleUnauthorized;
  runApp(const Rc0App());

  // Local + network warm-up must not block first frame.
  unawaited(_initBackgroundServices());
}

Future<void> _initBackgroundServices() async {
  await Future.wait([
    ImageFavoriteRepository.instance.initialize(),
    ImageGalleryRepository.instance.initialize(),
    ImageTagsRepository.instance.initialize(),
    IpRepository.instance.initialize(),
    ScreenplayTagsRepository.instance.initialize(),
    ShootPresetRepository.instance.load(),
  ]);
  ImageFavoriteStore.instance = ImageFavoriteRepository.instance;
}
