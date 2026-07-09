import 'package:flutter/material.dart';

import '../../../../app/theme/system_ui_style.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';

class ExploreAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ExploreAppBar({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return WikiModeTagAppBar(
      title: '模板',
      systemOverlayStyle: embeddedInHub
          ? AppSystemUi.lightStyle
          : AppSystemUi.styleFor(Theme.of(context).brightness),
      leading: StudioGlassIconButton(
        icon: Icons.menu,
        tooltip: '菜单',
        onPressed: () {},
      ),
      actions: const [ScriptStudioHeaderActionButtons(trailingSpacing: 8)],
    );
  }
}
