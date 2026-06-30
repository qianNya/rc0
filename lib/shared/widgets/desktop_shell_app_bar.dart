import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/platform/platform_features.dart';
import '../../core/responsive/breakpoints.dart';
import '../../features/shell/presentation/widgets/desktop_title_bar.dart';
import 'glass_title_chip.dart';
import 'rc0_app_bar.dart';
import 'rc0_page_scaffold.dart';
import 'desktop/desktop_card.dart';
import 'desktop/desktop_chrome.dart';

/// Shell 分支页顶栏：标题/操作与窗口控件合并为一行。
class DesktopShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DesktopShellAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.titleBarHeight = kDesktopTitleBarHeight,
    this.glassTitleMode = GlassTitleMode.auto,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final double titleBarHeight;
  final GlassTitleMode glassTitleMode;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Size get preferredSize => Size.fromHeight(
        shouldUseDesktopWindowChrome
            ? titleBarHeight
            : AppDimensions.bottomNavFloatingHeight,
      );

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isDesktop(context) || !shouldUseDesktopWindowChrome) {
      return Rc0AppBar(
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
        glassTitleMode: glassTitleMode,
      );
    }

    final resolvedLeading = leading ??
        (automaticallyImplyLeading && Navigator.of(context).canPop()
            ? const BackButton()
            : null);

    return DesktopCard(
      clipChild: true,
      child: DesktopMergedTitleBar(
        height: titleBarHeight,
        decoration: const BoxDecoration(color: AppColors.surface),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesktopChrome.gap),
          child: Row(
            children: [
              if (_isMacOS) const DesktopWindowControls(),
              ...(resolvedLeading != null
                  ? [resolvedLeading]
                  : const <Widget>[]),
              Expanded(
                child: centerTitle
                    ? Center(
                        child: GlassTitleChip.maybeWrap(
                          title,
                          mode: glassTitleMode,
                        ),
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: GlassTitleChip.maybeWrap(
                          title,
                          mode: glassTitleMode,
                        ),
                      ),
              ),
              ...actions,
              if (!_isMacOS) const SizedBox(width: DesktopChrome.gap),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shell Tab 页标准布局：顶栏卡片 + 内容卡片。
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
    if (!Breakpoints.isDesktop(context) || !shouldUseDesktopWindowChrome) {
      return Rc0PageScaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appBar,
          const SizedBox(height: DesktopChrome.gap),
          Expanded(
            child: DesktopCard(child: body),
          ),
        ],
      ),
    );
  }
}
