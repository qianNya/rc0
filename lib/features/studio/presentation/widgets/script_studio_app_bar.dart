import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import 'script_studio_header_components.dart';
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
        title: Text('剧本工坊', style: ScriptStudioColors.title),
        actions: const [ScriptStudioHeaderActionButtons()],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: const ScriptStudioHeaderTitleChip(text: '剧本工坊'),
      leading: StudioGlassIconButton(
        icon: Icons.menu,
        tooltip: '菜单',
        onPressed: () {},
      ),
      actions: const [ScriptStudioHeaderActionButtons(trailingSpacing: 8)],
    );
  }
}
