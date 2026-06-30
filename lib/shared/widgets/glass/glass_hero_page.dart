import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/system_ui_style.dart';
import '../../../core/responsive/breakpoints.dart';
import '../desktop/desktop_stack_scaffold.dart';
import '../rc0_app_bar.dart';
import '../rc0_page_scaffold.dart';
import 'glass_card.dart';

/// Immersive hero layout: full-bleed image, gradient scrim, floating glass info.
class GlassHeroPage extends StatelessWidget {
  const GlassHeroPage({
    super.key,
    required this.hero,
    this.heroHeight,
    this.title,
    this.leading,
    this.actions,
    this.onBack,
    this.infoCard,
    this.tabs,
    this.tabBar,
    required this.body,
    this.bottomBar,
    this.extendBodyBehindAppBar = true,
  });

  final Widget hero;
  final double? heroHeight;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final Widget? infoCard;
  final List<Widget>? tabs;
  final PreferredSizeWidget? tabBar;
  final Widget body;
  final Widget? bottomBar;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final height = heroHeight ??
        (Breakpoints.isDesktop(context) ? 360.0 : 280.0);

    final content = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(height: height, width: double.infinity, child: hero),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.heroScrimTop,
                        AppColors.heroScrimMid,
                        AppColors.heroScrimBottom,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
              if (infoCard != null)
                Positioned(
                  left: AppDimensions.spacingMd,
                  right: AppDimensions.spacingMd,
                  bottom: -AppDimensions.spacingLg,
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: infoCard!,
                  ),
                ),
            ],
          ),
        ),
        if (infoCard != null)
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.spacingXl),
          ),
        if (tabBar != null)
          SliverPersistentHeader(
            pinned: true,
            delegate: _GlassHeroTabDelegate(tabBar!),
          ),
        SliverToBoxAdapter(child: body),
      ],
    );

    if (Breakpoints.isDesktop(context)) {
      return DesktopStackScaffold(
        title: title ?? const SizedBox.shrink(),
        onBack: onBack,
        leading: leading,
        actions: actions ?? const [],
        overlayAppBar: extendBodyBehindAppBar,
        appBarForegroundColor:
            extendBodyBehindAppBar ? Colors.white : null,
        body: content,
        bottomNavigationBar: bottomBar,
      );
    }

    return Rc0PageScaffold(
      overlayAppBar: extendBodyBehindAppBar,
      includeShellBottomSpacer: bottomBar == null,
      appBar: Rc0AppBar(
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
        frosted: !extendBodyBehindAppBar,
        foregroundColor:
            extendBodyBehindAppBar ? Colors.white : null,
        iconTheme: extendBodyBehindAppBar
            ? const IconThemeData(color: Colors.white)
            : null,
        bottom: tabBar,
        systemOverlayStyle:
            extendBodyBehindAppBar ? AppSystemUi.darkStyle : null,
      ),
      body: content,
      bottomNavigationBar: bottomBar,
    );
  }
}

class _GlassHeroTabDelegate extends SliverPersistentHeaderDelegate {
  _GlassHeroTabDelegate(this.tabBar);

  final PreferredSizeWidget tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _GlassHeroTabDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
