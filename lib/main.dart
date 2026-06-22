import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/network/api_auth.dart';
import 'app/app.dart';
import 'core/platform/platform_features.dart';
import 'core/services/image_favorite_store.dart';
import 'core/theme/theme_mode_notifier.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/favorites/data/image_favorite_repository.dart';
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
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  await ScreenplayLocalRepository.instance.initialize();
  await ImageFavoriteRepository.instance.initialize();
  ImageFavoriteStore.instance = ImageFavoriteRepository.instance;
  await ThemeModeNotifier.instance.initialize();
  await AuthRepository.instance.initialize();
  onApiUnauthorized = AuthRepository.instance.handleUnauthorized;
  runApp(const Rc0App());
}
