import 'package:flutter/material.dart';

import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import 'script_studio_header_components.dart';
import 'script_studio_theme.dart';

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

/// Top spacing below floating Wiki-style app bars when [extendBodyBehindAppBar] is true.
typedef ScriptStudioToolbarContentInset = WikiModeTagToolbarInset;

/// Script Studio hub shell: Wiki-style floating chrome, no title-bar fill.
class ScriptStudioHubScaffold extends StatelessWidget {
  const ScriptStudioHubScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.includeShellBottomSpacer = false,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final bool includeShellBottomSpacer;

  @override
  Widget build(BuildContext context) {
    return WikiModeTagPageScaffold(
      appBar: appBar,
      pageBackgroundColor: ScriptStudioColors.background,
      bleedUnderAppBar: true,
      includeShellBottomSpacer: includeShellBottomSpacer,
      body: body,
    );
  }
}
