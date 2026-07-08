import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../community/presentation/widgets/community_category_chips.dart';
import '../../../community/presentation/widgets/community_featured_banner.dart';
import '../../data/template_market_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/template_grid_card.dart';

/// Shared template market grid — used by discovery template tab.
class TemplateMarketBody extends StatefulWidget {
  const TemplateMarketBody({
    super.key,
    this.compact = false,
    this.showSearch = true,
    this.showFeaturedBanner = true,
    this.showDesktopHeader = false,
  });

  final bool compact;
  final bool showSearch;
  final bool showFeaturedBanner;
  final bool showDesktopHeader;

  @override
  State<TemplateMarketBody> createState() => _TemplateMarketBodyState();
}

class _TemplateMarketBodyState extends State<TemplateMarketBody> {
  final _repository = TemplateMarketRepository.instance;
  final _searchController = TextEditingController();
  int _categoryIndex = 0;
  int _sortTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _repository.loadFirstPage();
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
          sortTabIndex: _sortTabIndex,
        ),
      );

  Future<void> _search(String query) => _repository.loadFirstPage(
        q: query.trim(),
        query: _repository.query.copyWith(
          categoryIndex: _categoryIndex,
          sortTabIndex: _sortTabIndex,
        ),
      );

  void _onCategoryChanged(int index) {
    setState(() => _categoryIndex = index);
    _repository.updateFilters(categoryIndex: index);
  }

  void _onSortTabChanged(int index) {
    setState(() => _sortTabIndex = index);
    _repository.updateFilters(sortTabIndex: index);
    _refresh();
  }

  List<Screenplay> _scriptsForSortTab(int sortIndex) {
    if (sortIndex != _sortTabIndex) return const [];
    return _repository.items;
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.compact
        ? AppDimensions.spacingMd
        : AppDimensions.spacingXl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showDesktopHeader)
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppDimensions.spacingXl,
              horizontalPadding,
              0,
            ),
            child: Text(
              '模板市场',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        if (widget.showSearch)
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              widget.showDesktopHeader ? 16 : 12,
              horizontalPadding,
              8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hint: widget.compact ? '搜索模板' : '搜索模板…',
                    controller: _searchController,
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        CommunityCategoryChips(
          selectedIndex: _categoryIndex,
          onChanged: _onCategoryChanged,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 4,
            left: horizontalPadding,
            right: horizontalPadding,
          ),
          child: FeedTabBar(
            tabs: AppCatalog.communitySortTabs,
            selectedIndex: _sortTabIndex,
            onChanged: _onSortTabChanged,
            underlineStyle: true,
          ),
        ),
        Expanded(
          child: FadeSlideIndexedStack(
            index: _sortTabIndex,
            children: [
              for (var i = 0; i < AppCatalog.communitySortTabs.length; i++)
                _TemplateSortTabBody(
                  key: ValueKey('template-sort-$i'),
                  scripts: _scriptsForSortTab(i),
                  sortTabIndex: i,
                  loading: _repository.loading,
                  loadingMore: _repository.loadingMore,
                  hasMore: _repository.hasMore,
                  error: _repository.error,
                  onRefresh: _refresh,
                  onLoadMore: () => _repository.loadMore(),
                  compact: widget.compact,
                  showFeaturedBanner: widget.showFeaturedBanner,
                  horizontalPadding: horizontalPadding,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateSortTabBody extends StatelessWidget {
  const _TemplateSortTabBody({
    super.key,
    required this.scripts,
    required this.sortTabIndex,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.onRefresh,
    required this.onLoadMore,
    required this.compact,
    required this.showFeaturedBanner,
    required this.horizontalPadding,
  });

  final List<Screenplay> scripts;
  final int sortTabIndex;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool compact;
  final bool showFeaturedBanner;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 240 &&
              hasMore &&
              !loadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: _buildSlivers(context),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    if (loading && scripts.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (error != null && scripts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildErrorState(context),
        ),
      ];
    }

    if (scripts.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.storefront_outlined,
            title: '暂无模板',
            subtitle: '稍后再来看看',
          ),
        ),
      ];
    }

    return [
      if (showFeaturedBanner && compact)
        const SliverToBoxAdapter(child: CommunityFeaturedBanner())
      else if (showFeaturedBanner && !compact) ...[
        const SliverToBoxAdapter(child: FeaturedBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 8,
            runSpacing: 12,
            children: [
              for (var i = 0; i < AppCatalog.marketQuickActions.length; i++)
                QuickActionCircle(
                  label: AppCatalog.marketQuickActions[i],
                  icon: [
                    Icons.grid_view,
                    Icons.local_fire_department_outlined,
                    Icons.schedule,
                    Icons.card_giftcard_outlined,
                  ][i],
                ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              28,
              horizontalPadding,
              16,
            ),
            child: Text(
              '热门模板',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ],
      if (error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              0,
              horizontalPadding,
              8,
            ),
            child: InlineErrorBanner(
              message: error!,
              onRetry: onRefresh,
            ),
          ),
        ),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 0),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final gridWidth = FeedGridLayout.layoutWidth(
              constraints.crossAxisExtent,
            );
            return SliverGrid(
              gridDelegate: FeedGridLayout.sliverDelegate(
                gridWidth,
                gridSpacing: compact ? 12 : 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final script = scripts[index];
                  return TemplateGridCard(
                    screenplay: script,
                    compact: compact,
                    showBadge: index == 0 && sortTabIndex == 0
                        ? ContentBadgeType.hot
                        : index == 1 && !compact
                            ? ContentBadgeType.now
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
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMd),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: ShellBottomSpacer()),
    ];
  }

  Widget _buildErrorState(BuildContext context) {
    final needsLogin = isUnauthorizedError(error);
    if (needsLogin) {
      return EmptyStateView(
        icon: Icons.lock_outline,
        title: '请先登录',
        subtitle: '登录后查看模板市场',
        actionLabel: '去登录',
        onAction: () => context.go(
          AppRoutes.loginWithRedirect(AppRoutes.discoveryTemplate),
        ),
      );
    }
    return EmptyStateView(
      icon: Icons.cloud_off_outlined,
      title: '加载失败',
      subtitle: error,
      actionLabel: '重试',
      onAction: onRefresh,
    );
  }
}
