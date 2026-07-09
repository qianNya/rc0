import 'package:flutter/material.dart';

import '../../../app/theme/system_ui_style.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../features/shell/presentation/widgets/desktop_title_bar.dart';
import '../glass_title_chip.dart';
import '../rc0_page_scaffold.dart';

/// Root-stack page shell — uses global wiki floating app bar on all platforms.
class DesktopStackScaffold extends StatelessWidget {
  const DesktopStackScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.onBack,
    this.leading,
    this.centerTitle = true,
    this.titleBarHeight = kToolbarHeight,
    this.bodyPadding,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.overlayAppBar = false,
    this.appBarForegroundColor,
    this.glassTitleMode = GlassTitleMode.auto,
    this.frosted,
    this.toolbarHeight,
  });

  final Widget title;
  final Widget body;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final double titleBarHeight;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool overlayAppBar;
  final Color? appBarForegroundColor;
  final GlassTitleMode glassTitleMode;
  final bool? frosted;
  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final content = bodyPadding != null
        ? Padding(padding: bodyPadding!, child: body)
        : body;

    final page = Rc0PageScaffold(
      title: title,
      leading: leading,
      onBack: onBack,
      actions: actions,
      centerTitle: centerTitle,
      overlayAppBar: overlayAppBar,
      appBarForegroundColor: appBarForegroundColor,
      glassTitleMode: glassTitleMode,
      frosted: frosted,
      toolbarHeight: toolbarHeight ?? titleBarHeight,
      systemOverlayStyle:
          overlayAppBar ? AppSystemUi.darkStyle : null,
      body: content,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );

    // Stack routes have no sidebar — overlay Win buttons / mac lights without
    // pushing the page body down.
    if (Breakpoints.useSidebarShell(context)) {
      return DesktopWindowChromeOverlay(child: page);
    }
    return page;
  }
}
