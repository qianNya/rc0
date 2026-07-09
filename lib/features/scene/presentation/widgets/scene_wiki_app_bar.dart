import 'package:flutter/material.dart';

import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';

/// Shared transparent glass app bar for the scene hub shell tab.
class SceneHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SceneHubAppBar({
    super.key,
    this.title = '场景',
    this.leading,
    this.actions,
    this.leadingWidth,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final double? leadingWidth;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return WikiModeTagAppBar(
      title: title,
      leadingWidth: leadingWidth,
      leading: leading ??
          WikiModeTagIconButton(
            icon: Icons.menu,
            tooltip: '菜单',
            onPressed: () {},
          ),
      actions: actions ??
          const [ScriptStudioHeaderActionButtons(trailingSpacing: 8)],
    );
  }
}

/// Top spacing below floating wiki app bars on scene hub pages.
typedef SceneHubToolbarContentInset = WikiModeTagToolbarInset;

/// Scene hub shell — mobile floating chrome; desktop sidebar content header.
class SceneHubScaffold extends StatelessWidget {
  const SceneHubScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.desktopHeader,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? desktopHeader;

  @override
  Widget build(BuildContext context) {
    return DesktopHubScaffold(
      appBar: appBar,
      desktopHeader: desktopHeader ??
          const DesktopHubHeader(
            title: '场景',
            subtitle: '场景库与拍摄空间',
          ),
      body: body,
    );
  }
}
