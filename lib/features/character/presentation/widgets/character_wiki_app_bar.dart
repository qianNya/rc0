import 'package:flutter/material.dart';

import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';

/// Shared transparent glass app bar for the character library hub.
class CharacterHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CharacterHubAppBar({
    super.key,
    this.title = '角色',
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

/// Top spacing below floating wiki app bars on character hub pages.
typedef CharacterHubToolbarContentInset = WikiModeTagToolbarInset;

/// Character library shell — mobile floating chrome; desktop page header.
class CharacterHubScaffold extends StatelessWidget {
  const CharacterHubScaffold({
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
            title: '角色',
            subtitle: '角色库与可复用形象',
          ),
      body: body,
    );
  }
}
