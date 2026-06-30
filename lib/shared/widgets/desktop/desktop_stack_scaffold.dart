import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/system_ui_style.dart';
import '../../../core/platform/platform_features.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../features/shell/presentation/widgets/desktop_title_bar.dart';
import '../glass_title_chip.dart';
import '../rc0_page_scaffold.dart';
import 'desktop_card.dart';
import 'desktop_chrome.dart';

/// 根栈页面桌面外壳：无侧栏，顶栏卡片 + 内容卡片。
class DesktopStackScaffold extends StatelessWidget {
  const DesktopStackScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.onBack,
    this.leading,
    this.centerTitle = true,
    this.titleBarHeight = kDesktopTitleBarHeight,
    this.bodyPadding,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.overlayAppBar = false,
    this.appBarForegroundColor,
    this.glassTitleMode = GlassTitleMode.auto,
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

  /// Immersive hero pages: transparent app bar over body, no top inset.
  final bool overlayAppBar;
  final Color? appBarForegroundColor;
  final GlassTitleMode glassTitleMode;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (!isDesktop || !shouldUseDesktopWindowChrome) {
      return Rc0PageScaffold(
        title: title,
        leading: leading,
        onBack: onBack,
        actions: actions,
        centerTitle: centerTitle,
        overlayAppBar: overlayAppBar,
        appBarForegroundColor: appBarForegroundColor,
        glassTitleMode: glassTitleMode,
        systemOverlayStyle:
            overlayAppBar ? AppSystemUi.darkStyle : null,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    final backLeading = leading ??
        (onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                tooltip: '返回',
                onPressed: onBack,
                visualDensity: VisualDensity.compact,
              )
            : null);
    final leadingWidgets =
        backLeading == null ? null : <Widget>[backLeading];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Padding(
        padding: const EdgeInsets.all(DesktopChrome.gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DesktopCard(
              clipChild: true,
              child: DesktopMergedTitleBar(
                height: titleBarHeight,
                decoration: const BoxDecoration(color: AppColors.surface),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesktopChrome.gap,
                  ),
                  child: Row(
                    children: [
                      if (_isMacOS) const DesktopWindowControls(),
                      ...?leadingWidgets,
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
            ),
            const SizedBox(height: DesktopChrome.gap),
            Expanded(
              child: DesktopCard(
                padding: bodyPadding,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
