import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';

class ScriptStudioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScriptStudioAppBar({super.key});

  @override
  Size get preferredSize => const DesktopShellAppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    return DesktopShellAppBar(
      centerTitle: true,
      automaticallyImplyLeading: !isDesktop,
      leading: isDesktop
          ? null
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
              tooltip: '菜单',
            ),
      title: const Text('Script Studio', style: AppTextStyles.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '搜索',
          onPressed: () => context.push(AppRoutes.search),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: '消息',
          onPressed: () => context.go(AppRoutes.messages),
        ),
      ],
    );
  }
}
