import 'package:flutter/material.dart';

import 'glass_title_chip.dart';
import 'rc0_app_bar.dart';
import 'wiki_mode_tag_app_bar.dart';

/// Shell branch top bar — global wiki floating chrome.
class DesktopShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DesktopShellAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.titleBarHeight = kToolbarHeight,
    this.glassTitleMode = GlassTitleMode.auto,
    this.onBack,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double titleBarHeight;
  final GlassTitleMode glassTitleMode;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(titleBarHeight);

  @override
  Widget build(BuildContext context) {
    return Rc0AppBar(
      title: title,
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      onBack: onBack,
      toolbarHeight: titleBarHeight,
      glassTitleMode: glassTitleMode,
    );
  }
}

/// Shell tab layout — wiki floating app bar + scrollable body.
class DesktopShellTabScaffold extends StatelessWidget {
  const DesktopShellTabScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return WikiModeTagPageScaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
