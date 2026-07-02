import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/system_ui_style.dart';
import 'shell_insets.dart';

/// Frosted pill title chip for Wiki-style floating headers.
class WikiModeTagTitleChip extends StatelessWidget {
  const WikiModeTagTitleChip({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(999);
    final fill = isDark
        ? AppColors.glassNavSurfaceDark
        : AppColors.glassNavSurfaceLight;
    final border = isDark
        ? AppColors.glassNavBorderDark
        : AppColors.glassNavBorderLight;
    final textStyle =
        style ??
        const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        );

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: fill,
            border: Border.all(color: border, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Text(text, style: textStyle),
          ),
        ),
      ),
    );
  }
}

/// Circular frosted nav icon button for Wiki-style floating headers.
class WikiModeTagIconButton extends StatelessWidget {
  const WikiModeTagIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconSize = 22,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(size / 2);
    final fill = isDark
        ? AppColors.glassNavSurfaceDark
        : AppColors.glassNavSurfaceLight;
    final border = isDark
        ? AppColors.glassNavBorderDark
        : AppColors.glassNavBorderLight;
    final iconColor = isDark
        ? AppColors.glassNavIconDark
        : AppColors.glassNavIconLight;

    final button = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: Border.all(color: border, width: 0.8),
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size, height: size),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: button,
    );
  }
}

/// Wiki-style transparent header: frosted mode-tag title, no bar fill.
class WikiModeTagAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WikiModeTagAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.leadingWidth,
    this.systemOverlayStyle,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final double? leadingWidth;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: true,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: leadingWidth,
      systemOverlayStyle:
          systemOverlayStyle ?? AppSystemUi.styleFor(brightness),
      title: WikiModeTagTitleChip(text: title),
      leading: leading,
      actions: actions,
    );
  }
}

/// Full height of status bar + floating toolbar chrome.
double wikiModeTagChromeHeight(BuildContext context) {
  final statusTop = MediaQuery.paddingOf(context).top;
  return statusTop + kToolbarHeight;
}

/// Content padding top: clears floating chrome (no extra gap).
double wikiModeTagContentInsetHeight(BuildContext context) {
  return wikiModeTagChromeHeight(context);
}

/// Overlap inset for content that intentionally bleeds under floating chrome.
double wikiModeTagBleedInsetHeight(BuildContext context) {
  return wikiModeTagChromeHeight(context) - AppDimensions.spacingXl;
}

/// Standard body padding for wiki-mode-tag pages with [bleedUnderAppBar].
///
/// [tight] uses [wikiModeTagBleedInsetHeight] so content sits closer to
/// floating chrome (wiki / explore embedded style).
EdgeInsets wikiModeTagBodyPadding(
  BuildContext context, {
  double horizontal = AppDimensions.spacingMd,
  double contentGap = 0,
  double bottom = AppDimensions.spacingMd,
  bool tight = false,
}) {
  final top = tight
      ? wikiModeTagBleedInsetHeight(context)
      : wikiModeTagContentInsetHeight(context) + contentGap;
  return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
}

/// Top spacing below [WikiModeTagAppBar] when [extendBodyBehindAppBar] is true.
class WikiModeTagToolbarInset extends StatelessWidget {
  const WikiModeTagToolbarInset({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: wikiModeTagContentInsetHeight(context));
  }
}

/// Wiki-style page shell: floating frosted chrome, no title-bar fill.
class WikiModeTagPageScaffold extends StatelessWidget {
  const WikiModeTagPageScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.pageBackgroundColor,
    this.bleedUnderAppBar = false,
    this.includeShellBottomSpacer = false,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final Color? pageBackgroundColor;

  /// When true, [body] is full-bleed under the app bar (caller handles inset).
  final bool bleedUnderAppBar;
  final bool includeShellBottomSpacer;

  @override
  Widget build(BuildContext context) {
    final background = pageBackgroundColor ?? AppColors.surface;

    final Widget content;
    if (bleedUnderAppBar) {
      content = ColoredBox(color: background, child: body);
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WikiModeTagToolbarInset(),
          Expanded(
            child: ColoredBox(color: background, child: body),
          ),
          if (includeShellBottomSpacer) const ShellBottomSpacer(),
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.lightStyle,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: content,
      ),
    );
  }
}
