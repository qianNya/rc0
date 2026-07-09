import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_mode_notifier.dart';
import '../features/shell/presentation/widgets/desktop_title_bar.dart';
import 'providers/router_providers.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/system_ui_style.dart';

class Rc0App extends ConsumerStatefulWidget {
  const Rc0App({super.key});

  @override
  ConsumerState<Rc0App> createState() => _Rc0AppState();
}

class _Rc0AppState extends ConsumerState<Rc0App> {
  final _themeNotifier = ThemeModeNotifier.instance;

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'rc0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeNotifier.themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        AppSystemUi.applyFor(brightness);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.styleFor(brightness),
          child: DesktopWindowShortcuts(
            child: ColoredBox(
              color: AppColors.pageBackground,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
