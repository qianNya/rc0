import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/responsive/feed_grid_layout.dart';
import '../../../core/responsive/responsive_builder.dart';
import '../wiki_mode_tag_app_bar.dart';

/// Page title + actions for shell content when the desktop sidebar is visible.
///
/// Replaces the mobile floating [WikiModeTagAppBar] so PC does not stack a
/// phone chrome chip on top of the sidebar.
class DesktopHubHeader extends StatelessWidget {
  const DesktopHubHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.bottom,
    this.bottomGap = AppDimensions.spacingMd,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? bottom;

  /// Gap between title row and [bottom]; discovery chrome uses `0`.
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXl,
        AppDimensions.spacingLg,
        AppDimensions.spacingXl,
        AppDimensions.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.display.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppDimensions.spacingXs),
                      actions[i],
                    ],
                  ],
                ),
            ],
          ),
          if (bottom != null) ...[
            SizedBox(height: bottomGap),
            bottom!,
          ],
        ],
      ),
    );
  }
}

/// Shell hub page shell: mobile floating chrome vs desktop sidebar content.
class DesktopHubScaffold extends StatelessWidget {
  const DesktopHubScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.desktopHeader,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget appBar;
  final Widget body;

  /// Shown above [body] when [Breakpoints.useSidebarShell] is true.
  final Widget? desktopHeader;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.useSidebarShell(context)) {
      return WikiModeTagPageScaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: ColoredBox(
        color: AppColors.pageBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ?desktopHeader,
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// Centers hub content and caps width on large desktop canvases.
class DesktopHubContent extends StatelessWidget {
  const DesktopHubContent({
    super.key,
    required this.child,
    this.maxWidth = FeedGridLayout.maxContentWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AdaptiveContent(
      maxWidth: maxWidth,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: Breakpoints.useSidebarShell(context)
                ? AppDimensions.spacingXl
                : AppDimensions.spacingMd,
          ),
      child: child,
    );
  }
}
