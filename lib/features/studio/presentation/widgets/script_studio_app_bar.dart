import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

class ScriptStudioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScriptStudioAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (isDesktop) {
      return DesktopShellAppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Script Studio', style: ScriptStudioColors.title),
        actions: [
          StudioGlassIconButton(
            icon: Icons.search,
            tooltip: '搜索',
            onPressed: () => context.push(AppRoutes.search),
          ),
          StudioGlassIconButton(
            icon: Icons.notifications_outlined,
            tooltip: '消息',
            onPressed: () => context.push(AppRoutes.messages),
          ),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text('Script Studio', style: ScriptStudioColors.title),
      leading: StudioGlassIconButton(
        icon: Icons.menu,
        tooltip: '菜单',
        onPressed: () {},
      ),
      actions: [
        StudioGlassIconButton(
          icon: Icons.search,
          tooltip: '搜索',
          onPressed: () => context.push(AppRoutes.search),
        ),
        const SizedBox(width: 4),
        StudioGlassIconButton(
          icon: Icons.notifications_outlined,
          tooltip: '消息',
          onPressed: () => context.push(AppRoutes.messages),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
