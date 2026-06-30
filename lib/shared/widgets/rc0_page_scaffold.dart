import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import 'glass_title_chip.dart';
import 'rc0_app_bar.dart';
import 'shell_insets.dart';
import 'status_bar_spacer.dart';

/// Standard stack-page shell: floating [Rc0AppBar] glass chrome over content.
///
/// Mobile layout matches [DesktopStackScaffold] and script-studio hub pages:
/// `extendBodyBehindAppBar` + [AppBarContentInset] so content never overlaps
/// the system status bar or floating top nav.
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
    this.systemOverlayStyle,
    this.glassTitleMode = GlassTitleMode.auto,
    required this.body,
    this.backgroundColor,
    this.overlayAppBar = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.includeShellBottomSpacer = true,
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
  final SystemUiOverlayStyle? systemOverlayStyle;
  final GlassTitleMode glassTitleMode;

  final Widget body;
  final Color? backgroundColor;

  /// Hero / immersive pages: body scrolls under a transparent app bar.
  final bool overlayAppBar;

  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool includeShellBottomSpacer;

  PreferredSizeWidget? _resolveAppBar() {
    if (appBar != null) return appBar;
    if (title == null &&
        leading == null &&
        onBack == null &&
        (actions == null || actions!.isEmpty)) {
      return null;
    }

    final resolvedLeading = leading ??
        (onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null);

    return Rc0AppBar(
      title: title,
      leading: resolvedLeading,
      automaticallyImplyLeading:
          automaticallyImplyLeading ?? (onBack != null && leading == null),
      actions: actions,
      centerTitle: centerTitle,
      frosted: frosted ?? !overlayAppBar,
      foregroundColor: appBarForegroundColor,
      iconTheme: appBarForegroundColor != null
          ? IconThemeData(color: appBarForegroundColor)
          : null,
      actionsIconTheme: appBarForegroundColor != null
          ? IconThemeData(color: appBarForegroundColor)
          : null,
      systemOverlayStyle: systemOverlayStyle,
      glassTitleMode: glassTitleMode,
    );
  }

  Widget _buildBody(PreferredSizeWidget? resolvedAppBar) {
    if (resolvedAppBar == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: body),
          if (includeShellBottomSpacer) const ShellBottomSpacer(),
        ],
      );
    }

    if (overlayAppBar) {
      return body;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppBarContentInset(
          toolbarHeight: resolvedAppBar.preferredSize.height,
        ),
        Expanded(child: body),
        if (includeShellBottomSpacer) const ShellBottomSpacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = _resolveAppBar();

    return ScrollNotificationObserver(
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.background,
        extendBodyBehindAppBar: resolvedAppBar != null && !overlayAppBar,
        appBar: resolvedAppBar,
        body: _buildBody(resolvedAppBar),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}
