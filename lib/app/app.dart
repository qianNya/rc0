import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/platform/platform_features.dart';
import '../features/shell/presentation/widgets/desktop_title_bar.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/system_ui_style.dart';

class Rc0App extends StatelessWidget {
  const Rc0App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'rc0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final content = AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppSystemUi.style,
          child: child ?? const SizedBox.shrink(),
        );

        if (!shouldUseDesktopWindowChrome) {
          return content;
        }

        return Column(
          children: [
            const DesktopTitleBar(),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
