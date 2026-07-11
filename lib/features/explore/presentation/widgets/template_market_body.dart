import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
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
        query: _repository.query.copyWith(sortTabIndex: _feedTabIndex),
      );

  Future<void> _search(String query) => _repository.loadFirstPage(
        q: query.trim(),
        query: _repository.query.copyWith(sortTabIndex: _feedTabIndex),
      );

  void _onPublish() {
    if (!_isLoggedIn) {
      context.go(AppRoutes.loginWithRedirect(AppRoutes.studio));
      return;
    }
    context.go(AppRoutes.studio);
  }

  List<Screenplay> _scriptsForTab(int tabIndex) {
    if (tabIndex == TemplateFeedQuery.tabFollowing && !_isLoggedIn) {
      return const [];
    }
    return _repository.scriptsForTab(tabIndex);
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
    final showFeedTabs =
        !widget.embeddedInHub || Breakpoints.useSidebarShell(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopHubHeader(
          title: '发现',
          subtitle: '精选模板与社区作品',
          bottomGap: 0,
          bottom: _DiscoveryMarketChrome(
            showFeedTabs: showFeedTabs,
            horizontalPadding: 0,
            searchController: _searchController,
            onSearch: _search,
            onPublish: _onPublish,
            showSearch: widget.showSearch,
          ),
        ),
        Expanded(child: _buildFeedTabStack(horizontalPadding, compact: false)),
      ],
    );
  }

  Widget _buildMobileMarket(double horizontalPadding) {
    final chromeClearance =
        widget.embeddedInHub ? widget.topPadding : 0.0;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: chromeClearance),
            child: _DiscoveryMarketChrome(
              showFeedTabs: !widget.embeddedInHub,
              horizontalPadding: horizontalPadding,
              searchController: _searchController,
              onSearch: _search,
              onPublish: _onPublish,
              showSearch: widget.showSearch,
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
            loading: _repository.isTabLoading(i) &&
                !(i == TemplateFeedQuery.tabFollowing && !_isLoggedIn),
            loadingMore: _repository.isTabLoadingMore(i),
            hasMore: _repository.hasMoreForTab(i),
            error: _repository.errorForTab(i),
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

/// Shared discovery chrome: feed tabs → search (zero vertical gap).
class _DiscoveryMarketChrome extends StatelessWidget {
  const _DiscoveryMarketChrome({
    required this.showFeedTabs,
    required this.horizontalPadding,
    required this.searchController,
    required this.onSearch,
    required this.onPublish,
    this.showSearch = true,
  });

  final bool showFeedTabs;
  final double horizontalPadding;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onPublish;
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showFeedTabs)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: const DiscoveryFeedTopTabBar(),
          ),
        if (showSearch)
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              AppDimensions.spacingSm,
            ),
            child: _SearchPublishRow(
              controller: searchController,
              onSubmitted: onSearch,
              onPublish: onPublish,
            ),
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
    const controlHeight = AppDimensions.feedTabBarHeight;
    final radius = BorderRadius.circular(AppDimensions.tabFloatingRadius);

    return SizedBox(
      height: controlHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DiscoveryGlassSearch(
              controller: controller,
              onSubmitted: onSubmitted,
              borderRadius: radius,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          _DiscoveryPublishButton(
            onPressed: onPublish,
            borderRadius: radius,
          ),
        ],
      ),
    );
  }
}

class _DiscoveryPublishButton extends StatelessWidget {
  const _DiscoveryPublishButton({
    required this.onPressed,
    required this.borderRadius,
  });

  final VoidCallback onPressed;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                '发布作品',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryGlassSearch extends StatelessWidget {
  const _DiscoveryGlassSearch({
    required this.controller,
    required this.onSubmitted,
    required this.borderRadius,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor =
        isDark ? AppColors.textTertiaryDark : AppColors.textTertiary;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return LiquidGlassSurface(
      borderRadius: borderRadius,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          isDense: true,
          hintText: '搜索模板…',
          hintStyle: TextStyle(color: hintColor, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: iconColor, size: 20),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: AppDimensions.feedTabBarHeight,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: 0,
          ),
        ),
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
