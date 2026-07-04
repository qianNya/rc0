import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/template_grid_card.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../utils/community_screenplay_filters.dart';
import '../widgets/community_category_chips.dart';
import '../widgets/community_featured_banner.dart';
import '../widgets/community_template_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, this.embeddedInHub = false});

  /// When true, rendered inside the bottom-nav shell (no back affordance).
  final bool embeddedInHub;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _repository = ScreenplayRemoteRepository.instance;
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
      );

  Future<void> _search(String query) =>
      _repository.loadFirstPage(q: query.trim());

  List<Screenplay> _scriptsForSortTab(int sortIndex) {
    final filtered = filterCommunityScreenplays(
      _repository.screenplays,
      _categoryIndex,
    );
    return sortCommunityScreenplays(filtered, sortIndex);
  }

  @override
  Widget build(BuildContext context) {
    final loading = _repository.loading;
    final error = _repository.error;
    final loadingMore = _repository.loadingMore;
    final hasMore = _repository.hasMore;

    return ResponsiveBuilder(
      mobile: (_) => _CommunityMobileView(
        embeddedInHub: widget.embeddedInHub,
        loading: loading,
        loadingMore: loadingMore,
        hasMore: hasMore,
        error: error,
        categoryIndex: _categoryIndex,
        sortTabIndex: _sortTabIndex,
        searchController: _searchController,
        scriptsForSortTab: _scriptsForSortTab,
        onCategoryChanged: (i) => setState(() => _categoryIndex = i),
        onSortTabChanged: (i) => setState(() => _sortTabIndex = i),
        onRefresh: _refresh,
        onSearch: _search,
        onLoadMore: () => _repository.loadMore(),
      ),
      desktop: (_) => _CommunityDesktopView(
        embeddedInHub: widget.embeddedInHub,
        loading: loading,
        loadingMore: loadingMore,
        hasMore: hasMore,
        error: error,
        categoryIndex: _categoryIndex,
        sortTabIndex: _sortTabIndex,
        searchController: _searchController,
        scriptsForSortTab: _scriptsForSortTab,
        onCategoryChanged: (i) => setState(() => _categoryIndex = i),
        onSortTabChanged: (i) => setState(() => _sortTabIndex = i),
        onRefresh: _refresh,
        onSearch: _search,
        onLoadMore: () => _repository.loadMore(),
      ),
    );
  }
}

class _CommunityMobileView extends StatelessWidget {
  const _CommunityMobileView({
    required this.embeddedInHub,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.categoryIndex,
    required this.sortTabIndex,
    required this.searchController,
    required this.scriptsForSortTab,
    required this.onCategoryChanged,
    required this.onSortTabChanged,
    required this.onRefresh,
    required this.onSearch,
    required this.onLoadMore,
  });

  final bool embeddedInHub;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final int categoryIndex;
  final int sortTabIndex;
  final TextEditingController searchController;
  final List<Screenplay> Function(int sortIndex) scriptsForSortTab;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<int> onSortTabChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String query) onSearch;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WikiModeTagToolbarInset(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: AppSearchField(
                  hint: '搜索模板',
                  controller: searchController,
                  onSubmitted: onSearch,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {},
              ),
            ],
          ),
        ),
        CommunityCategoryChips(
          selectedIndex: categoryIndex,
          onChanged: onCategoryChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 4,
            left: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
          ),
          child: FeedTabBar(
            tabs: AppCatalog.communitySortTabs,
            selectedIndex: sortTabIndex,
            onChanged: onSortTabChanged,
            underlineStyle: true,
          ),
        ),
        Expanded(
          child: FadeSlideIndexedStack(
            index: sortTabIndex,
            children: [
              for (var i = 0; i < AppCatalog.communitySortTabs.length; i++)
                _CommunitySortTabBody(
                  key: ValueKey('community-sort-mobile-$i'),
                  scripts: scriptsForSortTab(i),
                  sortTabIndex: i,
                  loading: loading,
                  loadingMore: loadingMore,
                  hasMore: hasMore,
                  error: error,
                  onRefresh: onRefresh,
                  onLoadMore: onLoadMore,
                  mobile: true,
                ),
            ],
          ),
        ),
      ],
    );

    return WikiModeTagPageScaffold(
      appBar: WikiModeTagAppBar(
        title: '社区',
        leading: embeddedInHub
            ? null
            : WikiModeTagIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                tooltip: '返回',
                onPressed: () => popOrGoDiscovery(context),
              ),
      ),
      body: content,
    );
  }
}

class _CommunityDesktopView extends StatelessWidget {
  const _CommunityDesktopView({
    required this.embeddedInHub,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.categoryIndex,
    required this.sortTabIndex,
    required this.searchController,
    required this.scriptsForSortTab,
    required this.onCategoryChanged,
    required this.onSortTabChanged,
    required this.onRefresh,
    required this.onSearch,
    required this.onLoadMore,
  });

  final bool embeddedInHub;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final int categoryIndex;
  final int sortTabIndex;
  final TextEditingController searchController;
  final List<Screenplay> Function(int sortIndex) scriptsForSortTab;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<int> onSortTabChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String query) onSearch;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('模板市场'),
      onBack: embeddedInHub ? null : () => popOrGoDiscovery(context),
      centerTitle: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingXl,
              AppDimensions.spacingXl,
              AppDimensions.spacingXl,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!embeddedInHub)
                  Text(
                    '模板市场',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                if (!embeddedInHub) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hint: '搜索模板…',
                        controller: searchController,
                        onSubmitted: onSearch,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CommunityCategoryChips(
                  selectedIndex: categoryIndex,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: 8),
                FeedTabBar(
                  tabs: AppCatalog.communitySortTabs,
                  selectedIndex: sortTabIndex,
                  onChanged: onSortTabChanged,
                  underlineStyle: true,
                ),
              ],
            ),
          ),
          Expanded(
            child: FadeSlideIndexedStack(
              index: sortTabIndex,
              children: [
                for (var i = 0; i < AppCatalog.communitySortTabs.length; i++)
                  _CommunitySortTabBody(
                    key: ValueKey('community-sort-desktop-$i'),
                    scripts: scriptsForSortTab(i),
                    sortTabIndex: i,
                    loading: loading,
                    loadingMore: loadingMore,
                    hasMore: hasMore,
                    error: error,
                    onRefresh: onRefresh,
                    onLoadMore: onLoadMore,
                    mobile: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunitySortTabBody extends StatelessWidget {
  const _CommunitySortTabBody({
    super.key,
    required this.scripts,
    required this.sortTabIndex,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.onRefresh,
    required this.onLoadMore,
    required this.mobile,
  });

  final List<Screenplay> scripts;
  final int sortTabIndex;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool mobile;

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

    final horizontalPadding = mobile
        ? AppDimensions.spacingMd
        : AppDimensions.spacingXl;

    return [
      if (mobile)
        const SliverToBoxAdapter(child: CommunityFeaturedBanner())
      else ...[
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
            padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 8),
            child: InlineErrorBanner(
              message: error!,
              onRetry: onRefresh,
            ),
          ),
        ),
      if (mobile)
        const SliverToBoxAdapter(child: SizedBox(height: 8))
      else
        const SliverToBoxAdapter(child: SizedBox.shrink()),
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
                gridSpacing: mobile ? 12 : 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final script = scripts[index];
                  if (mobile) {
                    return CommunityTemplateCard(
                      screenplay: script,
                      showHotBadge: index == 0 && sortTabIndex == 0,
                    );
                  }
                  return TemplateGridCard(
                    screenplay: script,
                    compact: true,
                    showBadge: index == 0
                        ? ContentBadgeType.hot
                        : index == 1
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
        subtitle: '登录后查看社区内容',
        actionLabel: '去登录',
        onAction: () => context.go(
          AppRoutes.loginWithRedirect(AppRoutes.community),
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
