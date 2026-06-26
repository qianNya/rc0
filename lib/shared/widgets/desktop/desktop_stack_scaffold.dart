import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/platform/platform_features.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../features/shell/presentation/widgets/desktop_title_bar.dart';
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
    this.bottomNavigationBar,
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
  final Widget? bottomNavigationBar;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (!isDesktop || !shouldUseDesktopWindowChrome) {
      return Scaffold(
        appBar: AppBar(
          title: title,
          leading: leading ??
              (onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    )
                  : null),
          automaticallyImplyLeading: onBack != null && leading == null,
          actions: actions,
          centerTitle: centerTitle,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
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
                      if (backLeading != null) backLeading,
                      Expanded(
                        child: centerTitle
                            ? Center(child: title)
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: title,
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
