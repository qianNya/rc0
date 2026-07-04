import 'package:flutter/material.dart';

import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';

/// Production assets hub — single-title wiki app bar.
class AssetsWikiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AssetsWikiAppBar({
    super.key,
    this.title = '资产',
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return WikiModeTagAppBar(
      title: title,
      leading: leading,
      actions: actions,
    );
  }
}
