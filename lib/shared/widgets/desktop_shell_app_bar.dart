import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/platform/platform_features.dart';
import '../../features/shell/presentation/widgets/desktop_title_bar.dart';

/// Shell 分支页顶栏：标题/操作与窗口控件合并为一行。
class DesktopShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DesktopShellAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  @override
  Size get preferredSize => Size.fromHeight(
        shouldUseDesktopWindowChrome ? kDesktopTitleBarHeight : kToolbarHeight,
      );

  @override
  Widget build(BuildContext context) {
    if (!shouldUseDesktopWindowChrome) {
      return AppBar(
        title: title,
        leading: leading,
        actions: actions,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }

    final resolvedLeading = leading ??
        (automaticallyImplyLeading && Navigator.of(context).canPop()
            ? const BackButton()
            : null);

    return DesktopMergedTitleBar(
      child: Row(
        children: [
          if (_isMacOS) const DesktopWindowControls(),
          if (resolvedLeading != null) resolvedLeading,
          Expanded(
            child: centerTitle
                ? Center(child: title)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: title,
                  ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
