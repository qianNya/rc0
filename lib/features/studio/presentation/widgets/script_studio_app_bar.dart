import 'package:flutter/material.dart';

import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import 'script_studio_header_components.dart';

/// Shared transparent glass app bar for Script Studio and related hubs.
class ScriptStudioAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScriptStudioAppBar({
    super.key,
    this.title = '剧本工坊',
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

/// Top spacing below floating Wiki-style app bars (toolbar row only).
typedef ScriptStudioToolbarContentInset = WikiModeTagToolbarInset;

/// Script Studio hub shell: mobile floating chrome; desktop page header.
class ScriptStudioHubScaffold extends StatelessWidget {
  const ScriptStudioHubScaffold({
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
            title: '创作',
            subtitle: '从空白、模板或 AI 开始一部新作品',
          ),
      body: body,
    );
  }
}
