import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/system_ui_style.dart';
import 'glass_app_bar_background.dart';

/// iOS-style glass navigation bar wrapping [AppBar].
class Rc0AppBar extends StatelessWidget implements PreferredSizeWidget {
  const Rc0AppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
    this.toolbarHeight,
    this.foregroundColor,
    this.titleTextStyle,
    this.iconTheme,
    this.actionsIconTheme,
    this.frosted = true,
    this.systemOverlayStyle,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;
  final double? toolbarHeight;
  final Color? foregroundColor;
  final TextStyle? titleTextStyle;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool frosted;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize {
    final toolbar = toolbarHeight ?? kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(toolbar + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      foregroundColor: foregroundColor,
      titleTextStyle: titleTextStyle,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: frosted ? const GlassAppBarBackground() : null,
      systemOverlayStyle:
          systemOverlayStyle ?? AppSystemUi.styleFor(brightness),
    );
  }
}
