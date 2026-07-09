import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/system_ui_style.dart';
import '../../app/theme/app_theme.dart';
import '../../core/responsive/breakpoints.dart';
import 'glass_title_chip.dart';
import 'status_bar_spacer.dart';

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

/// Maps legacy title widgets to [WikiModeTagTitleChip] when appropriate.
Widget wikiModeTagTitleWidget(
  Widget? title, {
  GlassTitleMode mode = GlassTitleMode.auto,
}) {
  if (title == null) return const SizedBox.shrink();
  if (title is WikiModeTagTitleChip) return title;
  if (mode == GlassTitleMode.off) return title;
  if (title is Text) {
    final plain = title.data ?? title.textSpan?.toPlainText() ?? '';
    if (plain.isNotEmpty) {
      return WikiModeTagTitleChip(text: plain, style: title.style);
    }
  }
  if (mode == GlassTitleMode.force && title is Text) {
    final plain = title.data ?? title.textSpan?.toPlainText() ?? '';
    return WikiModeTagTitleChip(text: plain, style: title.style);
  }
  return title;
}

/// Maps legacy leading controls to [WikiModeTagIconButton] when possible.
Widget? wikiModeTagLeading(
  BuildContext context, {
  Widget? leading,
  VoidCallback? onBack,
  bool automaticallyImplyLeading = true,
}) {
  if (leading != null) {
    if (leading is IconButton) {
      final icon = leading.icon;
      if (icon is Icon && icon.icon != null) {
        return WikiModeTagIconButton(
          icon: icon.icon!,
          onPressed: leading.onPressed,
          tooltip: leading.tooltip,
        );
      }
    }
    if (leading is BackButton) {
      return WikiModeTagIconButton(
        icon: Icons.arrow_back,
        onPressed: leading.onPressed ?? () => Navigator.maybePop(context),
        tooltip: '返回',
      );
    }
    return leading;
  }
  if (onBack != null) {
    return WikiModeTagIconButton(
      icon: Icons.arrow_back,
      onPressed: onBack,
      tooltip: '返回',
    );
  }
  if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
    return WikiModeTagIconButton(
      icon: Icons.arrow_back,
      onPressed: () => Navigator.of(context).maybePop(),
      tooltip: '返回',
    );
  }
  return null;
}

/// Horizontal wiki mode-tag tabs for in-page section switching (body chrome).
class WikiModeTagTabBar extends StatelessWidget {
  const WikiModeTagTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedStyle = TextStyle(
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    );

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.zero,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Opacity(
              opacity: selected ? 1 : 0.72,
              child: WikiModeTagTitleChip(
                text: tabs[index],
                style: selected ? null : mutedStyle,
              ),
            ),
          );
        },
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
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.leadingWidth,
    this.toolbarHeight,
    this.systemOverlayStyle,
  }) : assert(
          title != null || titleWidget != null,
          'Provide either title or titleWidget',
        );

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final double? leadingWidth;
  final double? toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = titleWidget ??
        WikiModeTagTitleChip(text: title!);
    final barHeight = toolbarHeight ?? kToolbarHeight;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: barHeight,
        child: NavigationToolbar(
          leading: leading,
          middle: resolvedTitle,
          centerMiddle: true,
          trailing: actions == null
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
        ),
      ),
    );
  }
}

/// System status bar inset (blank placeholder pixels for edge-to-edge layouts).
double wikiModeTagStatusBarHeight(BuildContext context) {
  return MediaQuery.paddingOf(context).top;
}

/// Floating toolbar row height (below the status bar).
double wikiModeTagToolbarHeight({double? toolbarHeight}) {
  return toolbarHeight ?? kToolbarHeight;
}

/// Full height of status bar + floating toolbar chrome.
double wikiModeTagChromeHeight(
  BuildContext context, {
  double? toolbarHeight,
}) {
  return wikiModeTagStatusBarHeight(context) +
      wikiModeTagToolbarHeight(toolbarHeight: toolbarHeight);
}

/// Scroll / hero bleed: extends content under floating chrome.
///
/// On desktop sidebar shell there is no floating phone app bar, so inset is
/// only a light top padding for the content canvas.
double wikiModeTagContentInsetHeight(
  BuildContext context, {
  double? toolbarHeight,
}) {
  if (Breakpoints.useSidebarShell(context)) {
    return AppDimensions.spacingLg;
  }
  return wikiModeTagChromeHeight(context, toolbarHeight: toolbarHeight);
}

/// Body inset below floating toolbar (status bar handled by app bar spacer).
double wikiModeTagFloatingToolbarInsetHeight(
  BuildContext context, {
  double? toolbarHeight,
}) {
  return wikiModeTagToolbarHeight(toolbarHeight: toolbarHeight);
}

/// Overlap inset for content that intentionally bleeds under floating chrome.
double wikiModeTagBleedInsetHeight(
  BuildContext context, {
  double? toolbarHeight,
}) {
  return wikiModeTagChromeHeight(context, toolbarHeight: toolbarHeight) -
      AppDimensions.spacingXl;
}

/// Standard body padding when the page does not use [WikiModeTagPageScaffold].
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

/// Transparent spacer matching the system status bar height.
typedef WikiModeTagStatusBarSpacer = StatusBarSpacer;

/// Clears full floating chrome (status bar + toolbar) for standard list/column pages.
class WikiModeTagToolbarInset extends StatelessWidget {
  const WikiModeTagToolbarInset({super.key, this.toolbarHeight});

  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: wikiModeTagChromeHeight(
        context,
        toolbarHeight: toolbarHeight,
      ),
    );
  }
}

/// Clears only the floating toolbar row (content may bleed under the status bar).
class WikiModeTagFloatingToolbarInset extends StatelessWidget {
  const WikiModeTagFloatingToolbarInset({super.key, this.toolbarHeight});

  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: wikiModeTagFloatingToolbarInsetHeight(
        context,
        toolbarHeight: toolbarHeight,
      ),
    );
  }
}

/// Wraps a wiki app bar with status-bar placeholder + floating toolbar chrome.
PreferredSizeWidget wrapWikiModeTagAppBar(
  BuildContext context,
  PreferredSizeWidget appBar,
) {
  final toolbarHeight = appBar.preferredSize.height;
  final chromeHeight = wikiModeTagChromeHeight(
    context,
    toolbarHeight: toolbarHeight,
  );

  return PreferredSize(
    preferredSize: Size.fromHeight(chromeHeight),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WikiModeTagStatusBarSpacer(),
        SizedBox(height: toolbarHeight, child: appBar),
      ],
    ),
  );
}

/// Wiki-style page shell: floating frosted chrome, transparent app bar.
class WikiModeTagPageScaffold extends StatelessWidget {
  const WikiModeTagPageScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.systemOverlayStyle,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.useSidebarShell(context)) {
      return Theme(
        data: AppTheme.light.copyWith(
          scaffoldBackgroundColor: Colors.transparent,
          canvasColor: AppColors.pageBackground,
        ),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: systemOverlayStyle ?? AppSystemUi.lightStyle,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            body: ColoredBox(
              color: AppColors.pageBackground,
              child: SizedBox.expand(child: body),
            ),
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
          ),
        ),
      );
    }

    final resolvedAppBar = wrapWikiModeTagAppBar(context, appBar);

    return Theme(
      data: AppTheme.light.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: AppColors.pageBackground,
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemOverlayStyle ?? AppSystemUi.lightStyle,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: resolvedAppBar,
          body: ColoredBox(
            color: AppColors.pageBackground,
            child: SizedBox.expand(child: body),
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
        ),
      ),
    );
  }
}
