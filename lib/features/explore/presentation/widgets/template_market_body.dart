import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/template_market_repository.dart';
import '../../domain/template_feed_query.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass_feed_card.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/shell_insets.dart';
import 'explore_desktop_right_panel.dart';
import 'discovery_feed_top_tab_bar.dart';

/// Discovery Feed — tabs + chips + search/publish + dual-column cards.
class TemplateMarketBody extends StatefulWidget {
  const TemplateMarketBody({
    super.key,
    this.compact = false,
    this.showSearch = true,
    this.showHero = false,
    this.showDesktopHeader = false,
    this.embeddedInHub = false,
    this.topPadding = 0,
  });

  final bool compact;
  final bool showSearch;

  /// Kept for API compat; Hero is no longer the Discovery main path (v2).
  @Deprecated('Discovery Feed v2 has no Hero main path.')
  final bool showHero;
  final bool showDesktopHeader;

  /// When true, feed tabs render in [DiscoveryHubAppBar] instead of the body.
  final bool embeddedInHub;

  /// Clearance for floating chrome overlaying the top of this body.
  final double topPadding;

  @override
  State<TemplateMarketBody> createState() => _TemplateMarketBodyState();
}

class _TemplateMarketBodyState extends State<TemplateMarketBody> {
  final _repository = TemplateMarketRepository.instance;
  final _searchController = TextEditingController();
  final _gridSectionKey = GlobalKey();
  int _categoryIndex = 0;

  int get _feedTabIndex => _repository.query.sortTabIndex;

  bool get _isLoggedIn => AuthRepository.instance.isLoggedIn;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _repository.loadFirstPage(
          query: TemplateFeedQuery(sortTabIndex: _feedTabIndex),
        );
      }
    });
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Future<void> _refresh() => _repository.loadFirstPage(
        q: _searchController.text.trim(),
        query: _repository.query.copyWith(
          categoryIndex: _categoryIndex,
          sortTabIndex: _feedTabIndex,
        ),
      );

  Future<void> _search(String query) => _repository.loadFirstPage(
        q: query.trim(),
        query: _repository.query.copyWith(
          categoryIndex: _categoryIndex,
          sortTabIndex: _feedTabIndex,
        ),
      );

  void _onCategoryChanged(int index) {
    setState(() => _categoryIndex = index);
    _repository.updateFilters(categoryIndex: index);
  }

  void _onPublish() {
    if (!_isLoggedIn) {
      context.go(AppRoutes.loginWithRedirect(AppRoutes.studio));
      return;
    }
    context.go(AppRoutes.studio);
  }

  List<Screenplay> _scriptsForTab(int tabIndex) {
    if (tabIndex != _feedTabIndex) return const [];
    if (tabIndex == TemplateFeedQuery.tabFollowing && !_isLoggedIn) {
      return const [];
    }
    return _repository.items;
  }

  @override
  Widget build(BuildContext context) {
    final desktop = widget.showDesktopHeader ||
        Breakpoints.useSidebarShell(context);
    final horizontalPadding = desktop
        ? AppDimensions.spacingXl
        : AppDimensions.spacingMd;
    final showRightPanel =
        desktop && Breakpoints.isExpanded(context);

    final marketColumn = desktop
        ? _buildDesktopMarket(horizontalPadding)
        : _buildMobileMarket(horizontalPadding);

    if (!showRightPanel) return marketColumn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: marketColumn),
        ExploreDesktopRightPanel(
          feedItems: _repository.items,
          onTagTap: (tag) {
            _searchController.text = tag;
            _search(tag);
          },
          onCreate: _onPublish,
          onBrowseTemplates: () {},
        ),
      ],
    );
  }

  Widget _buildDesktopMarket(double horizontalPadding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopHubHeader(
          title: '发现',
          subtitle: '精选模板与社区作品',
          bottom: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.embeddedInHub || Breakpoints.useSidebarShell(context))
                const DiscoveryFeedTopTabBar(),
              if (widget.showSearch) ...[
                if (!widget.embeddedInHub ||
                    Breakpoints.useSidebarShell(context))
                  const SizedBox(height: AppDimensions.spacingSm),
                _SearchPublishRow(
                  controller: _searchController,
                  onSubmitted: _search,
                  onPublish: _onPublish,
                ),
              ],
            ],
          ),
        ),
        _CategoryChipRow(
          selectedIndex: _categoryIndex,
          onChanged: _onCategoryChanged,
          horizontalPadding: horizontalPadding,
        ),
        Expanded(child: _buildFeedTabStack(horizontalPadding, compact: false)),
      ],
    );
  }

  Widget _buildMobileMarket(double horizontalPadding) {
    final contentTop = widget.embeddedInHub
        ? widget.topPadding
        : AppDimensions.spacingSm;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        if (!widget.embeddedInHub)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppDimensions.spacingSm,
                horizontalPadding,
                0,
              ),
              child: const DiscoveryFeedTopTabBar(),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: contentTop),
            child: _CategoryChipRow(
              selectedIndex: _categoryIndex,
              onChanged: _onCategoryChanged,
              horizontalPadding: horizontalPadding,
            ),
          ),
        ),
        if (widget.showSearch)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppDimensions.spacingSm,
                horizontalPadding,
                AppDimensions.spacingSm,
              ),
              child: _SearchPublishRow(
                controller: _searchController,
                onSubmitted: _search,
                onPublish: _onPublish,
              ),
            ),
          ),
      ],
      body: _buildFeedTabStack(horizontalPadding, compact: true, nested: true),
    );
  }

  Widget _buildFeedTabStack(
    double horizontalPadding, {
    required bool compact,
    bool nested = false,
  }) {
    return FadeSlideIndexedStack(
      index: _feedTabIndex,
      children: [
        for (var i = 0; i < AppCatalog.discoveryFeedTabs.length; i++)
          _DiscoveryFeedTabBody(
            key: ValueKey('discovery-feed-$i'),
            gridSectionKey: i == _feedTabIndex ? _gridSectionKey : null,
            scripts: _scriptsForTab(i),
            feedTabIndex: i,
            loading: _repository.loading &&
                !(i == TemplateFeedQuery.tabFollowing && !_isLoggedIn),
            loadingMore: _repository.loadingMore,
            hasMore: _repository.hasMore,
            error: _repository.error,
            requireLogin: i == TemplateFeedQuery.tabFollowing && !_isLoggedIn,
            onRefresh: _refresh,
            onLoadMore: () => _repository.loadMore(),
            onLogin: () => context.go(
              AppRoutes.loginWithRedirect(AppRoutes.discoveryTemplate),
            ),
            compact: compact,
            nested: nested,
            horizontalPadding: horizontalPadding,
          ),
      ],
    );
  }
}

class _SearchPublishRow extends StatelessWidget {
  const _SearchPublishRow({
    required this.controller,
    required this.onSubmitted,
    required this.onPublish,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DiscoveryGlassSearch(
            controller: controller,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        GlassButton(
          label: '发布作品',
          icon: Icons.add,
          filled: true,
          onPressed: onPublish,
        ),
      ],
    );
  }
}

class _DiscoveryGlassSearch extends StatelessWidget {
  const _DiscoveryGlassSearch({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final radius =
        BorderRadius.circular(AppDimensions.tabFloatingRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -4,
          ),
        ],
      ),
      child: LiquidGlassSurface(
        borderRadius: radius,
        child: TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '搜索模板…',
            hintStyle: TextStyle(color: hintColor),
            prefixIcon: Icon(Icons.search, color: iconColor),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingMd,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChipRow extends StatelessWidget {
  const _CategoryChipRow({
    required this.selectedIndex,
    required this.onChanged,
    required this.horizontalPadding,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chips = AppCatalog.communityCategoryChips;
    final secondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final border =
        isDark ? AppColors.glassNavBorderDark : AppColors.glassNavBorderLight;

    return SizedBox(
      height: AppDimensions.feedTabBarHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: chips.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: isDark ? 0.16 : 0.85)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppDimensions.tabFloatingRadius),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.28)
                      : border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                chips[index],
                style: AppTextStyles.caption.copyWith(
                  color: selected
                      ? (isDark ? Colors.white : AppColors.textPrimary)
                      : secondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiscoveryFeedTabBody extends StatelessWidget {
  const _DiscoveryFeedTabBody({
    super.key,
    required this.scripts,
    required this.feedTabIndex,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.requireLogin,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onLogin,
    required this.compact,
    required this.horizontalPadding,
    this.nested = false,
    this.gridSectionKey,
  });

  final List<Screenplay> scripts;
  final int feedTabIndex;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final bool requireLogin;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final VoidCallback onLogin;
  final bool compact;
  final bool nested;
  final double horizontalPadding;
  final Key? gridSectionKey;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: requireLogin ? () async {} : onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (requireLogin) return false;
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 240 &&
              hasMore &&
              !loadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: CustomScrollView(
          primary: !nested,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _buildSlivers(context),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    if (requireLogin) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: GlassEmptyState(
              icon: Icons.person_add_alt_1_outlined,
              title: '登录后查看关注',
              subtitle: '关注创作者后，他们的模板会出现在这里',
              actionLabel: '去登录',
              onAction: onLogin,
            ),
          ),
        ),
      ];
    }

    if (loading && scripts.isEmpty) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppDimensions.spacingSm,
            horizontalPadding,
            0,
          ),
          sliver: FeedGridSkeleton(
            sliver: true,
            tileCount: compact ? 6 : 9,
          ),
        ),
      ];
    }

    if (error != null && scripts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: _buildErrorState(context)),
        ),
      ];
    }

    if (scripts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: GlassEmptyState(
              icon: Icons.storefront_outlined,
              title: feedTabIndex == TemplateFeedQuery.tabFollowing
                  ? '暂无关注内容'
                  : '暂无模板',
              subtitle: feedTabIndex == TemplateFeedQuery.tabFollowing
                  ? '去发现页关注喜欢的创作者吧'
                  : '换个分类看看，或稍后再来',
              actionLabel: '刷新',
              onAction: onRefresh,
            ),
          ),
        ),
      ];
    }

    return [
      if (error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppDimensions.spacingSm,
              horizontalPadding,
              AppDimensions.spacingSm,
            ),
            child: InlineErrorBanner(
              message: error!,
              onRetry: onRefresh,
            ),
          ),
        ),
      SliverPadding(
        key: gridSectionKey,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppDimensions.spacingSm,
          horizontalPadding,
          0,
        ),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final gridWidth = FeedGridLayout.layoutWidth(
              constraints.crossAxisExtent,
            );
            final columns = compact
                ? 2
                : FeedGridLayout.columnsForWidth(gridWidth);
            final gap = compact
                ? AppDimensions.spacingMd - AppDimensions.spacingXs
                : AppDimensions.spacingMd;

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                childAspectRatio: feedGridChildAspectRatio(
                  columns,
                  overlayMetrics: compact,
                ),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final script = scripts[index];
                  return GlassFeedCard(
                    screenplay: script,
                    badge: script.isFeatured ||
                            (index == 0 &&
                                feedTabIndex == TemplateFeedQuery.tabHot)
                        ? ContentBadgeType.hot
                        : null,
                  );
                },
                childCount: scripts.length,
              ),
            );
          },
        ),
      ),
      if (loadingMore)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppDimensions.spacingSm,
            horizontalPadding,
            0,
          ),
          sliver: FeedGridSkeleton(
            sliver: true,
            tileCount: compact ? 4 : 6,
          ),
        ),
      const SliverToBoxAdapter(child: ShellBottomSpacer()),
    ];
  }

  Widget _buildErrorState(BuildContext context) {
    final needsLogin = isUnauthorizedError(error);
    if (needsLogin) {
      return GlassEmptyState(
        icon: Icons.lock_outline,
        title: '请先登录',
        subtitle: '登录后查看发现页内容',
        actionLabel: '去登录',
        onAction: onLogin,
      );
    }
    return GlassEmptyState(
      icon: Icons.cloud_off_outlined,
      title: '加载失败',
      subtitle: error,
      actionLabel: '重试',
      onAction: onRefresh,
    );
  }
}
