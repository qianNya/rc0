import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/system_ui_style.dart';
import 'glass_title_chip.dart';
import 'rc0_app_bar.dart';
import 'wiki_mode_tag_app_bar.dart';

/// Standard page shell — global [WikiModeTagPageScaffold] chrome.
class Rc0PageScaffold extends StatelessWidget {
  const Rc0PageScaffold({
    super.key,
    this.appBar,
    this.title,
    this.leading,
    this.actions,
    this.onBack,
    this.centerTitle,
    this.automaticallyImplyLeading,
    this.appBarForegroundColor,
    this.frosted,
    this.toolbarHeight,
    this.systemOverlayStyle,
    this.glassTitleMode = GlassTitleMode.auto,
    required this.body,
    this.backgroundColor,
    this.overlayAppBar = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  /// Custom app bar. When set, [title]/[leading]/[actions]/[onBack] are ignored.
  final PreferredSizeWidget? appBar;

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool? centerTitle;
  final bool? automaticallyImplyLeading;
  final Color? appBarForegroundColor;
  final bool? frosted;
  final double? toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final GlassTitleMode glassTitleMode;

  final Widget body;
  final Color? backgroundColor;

  /// Hero / immersive pages: body scrolls under floating app bar (default).
  final bool overlayAppBar;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  PreferredSizeWidget? _resolveAppBar(BuildContext context) {
    if (appBar != null) return appBar;
    if (title == null &&
        leading == null &&
        onBack == null &&
        (actions == null || actions!.isEmpty)) {
      return null;
    }

    return Rc0AppBar(
      title: title,
      leading: leading,
      onBack: onBack,
      automaticallyImplyLeading:
          automaticallyImplyLeading ?? (onBack != null && leading == null),
      actions: actions,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      foregroundColor: appBarForegroundColor,
      systemOverlayStyle: systemOverlayStyle,
      glassTitleMode: glassTitleMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = _resolveAppBar(context);
    final brightness = Theme.of(context).brightness;
    final overlayStyle =
        systemOverlayStyle ?? AppSystemUi.styleFor(brightness);

    if (resolvedAppBar == null) {
      return ScrollNotificationObserver(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SizedBox.expand(
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        ),
      );
    }

    return ScrollNotificationObserver(
      child: WikiModeTagPageScaffold(
        appBar: resolvedAppBar,
        systemOverlayStyle: overlayStyle,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        body: body,
      ),
    );
  }
}
