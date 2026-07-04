import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_title_chip.dart';
import 'wiki_mode_tag_app_bar.dart';

/// Global top bar — delegates to [WikiModeTagAppBar] (transparent wiki chrome).
@Deprecated('Use WikiModeTagAppBar directly')
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
    this.frosted,
    this.systemOverlayStyle,
    this.glassTitleMode = GlassTitleMode.auto,
    this.onBack,
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
  final bool? frosted;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final GlassTitleMode glassTitleMode;
  final VoidCallback? onBack;

  @override
  Size get preferredSize {
    final toolbar = toolbarHeight ?? kToolbarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(toolbar + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = wikiModeTagTitleWidget(title, mode: glassTitleMode);
    final titleWidget = titleTextStyle != null && resolvedTitle is WikiModeTagTitleChip
        ? WikiModeTagTitleChip(
            text: resolvedTitle.text,
            style: titleTextStyle,
          )
        : resolvedTitle;

    return WikiModeTagAppBar(
      titleWidget: titleWidget,
      leading: wikiModeTagLeading(
        context,
        leading: leading,
        onBack: onBack,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
      actions: actions,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: systemOverlayStyle,
    );
  }
}
