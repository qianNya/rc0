import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rc0/app/app.dart';
import 'package:rc0/app/router/routes.dart';
import 'package:rc0/features/auth/data/auth_repository.dart';
import 'package:rc0/features/favorites/data/image_favorite_repository.dart';
import 'package:rc0/features/gallery/data/image_gallery_repository.dart';
import 'package:rc0/features/gallery/data/image_tags_repository.dart';
import 'package:rc0/features/ip/data/ip_repository.dart';
import 'package:rc0/features/screenplay/data/screenplay_local_repository.dart';
import 'package:rc0/features/screenplay/data/screenplay_tags_repository.dart';
import 'package:rc0/features/screenplay/data/shoot_preset_repository.dart';
import 'package:rc0/core/services/shell_nav_config_store.dart';
import 'package:rc0/core/theme/theme_mode_notifier.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ScreenplayLocalRepository.instance.initialize();
    await ImageFavoriteRepository.instance.initialize();
    await ImageGalleryRepository.instance.initialize();
    await ImageTagsRepository.instance.initialize();
    await IpRepository.instance.initialize();
    await ScreenplayTagsRepository.instance.initialize();
    await ThemeModeNotifier.instance.initialize();
    await ShellNavConfigStore.instance.initialize();
    await AuthRepository.instance.initialize();
    await ShootPresetRepository.instance.load();
  });

  test('community route redirects to discovery template section', () {
    expect(
      AppRoutes.discoveryTemplate,
      '/discovery?section=template',
    );
    expect(AppRoutes.discoverySectionTemplate, 'template');
  });

  testWidgets('App launches explore page', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: Rc0App()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('发现'), findsWidgets);
  });
}
