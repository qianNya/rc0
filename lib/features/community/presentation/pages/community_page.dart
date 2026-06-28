import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/template_grid_card.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/status_bar_spacer.dart';
import '../utils/community_screenplay_filters.dart';
import '../widgets/community_category_chips.dart';
import '../widgets/community_featured_banner.dart';
import '../widgets/community_template_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

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

  List<Screenplay> get _displayScripts {
    final filtered = filterCommunityScreenplays(
      _repository.screenplays,
      _categoryIndex,
    );
    return sortCommunityScreenplays(filtered, _sortTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    final scripts = _displayScripts;
    final loading = _repository.loading;
    final error = _repository.error;
    final loadingMore = _repository.loadingMore;
    final hasMore = _repository.hasMore;

    return ResponsiveBuilder(
      mobile: (_) => _CommunityMobileView(
        scripts: scripts,
        loading: loading,
        loadingMore: loadingMore,
        hasMore: hasMore,
        error: error,
        categoryIndex: _categoryIndex,
        sortTabIndex: _sortTabIndex,
        searchController: _searchController,
        onCategoryChanged: (i) => setState(() => _categoryIndex = i),
        onSortTabChanged: (i) => setState(() => _sortTabIndex = i),
        onRefresh: _refresh,
        onSearch: _search,
        onLoadMore: () => _repository.loadMore(),
      ),
      desktop: (_) => _CommunityDesktopView(
        scripts: scripts,
        loading: loading,
        loadingMore: loadingMore,
        hasMore: hasMore,
        error: error,
        categoryIndex: _categoryIndex,
        sortTabIndex: _sortTabIndex,
        searchController: _searchController,
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
    required this.scripts,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.categoryIndex,
    required this.sortTabIndex,
    required this.searchController,
    required this.onCategoryChanged,
    required this.onSortTabChanged,
    required this.onRefresh,
    required this.onSearch,
    required this.onLoadMore,
  });

  final List<Screenplay> scripts;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final int categoryIndex;
  final int sortTabIndex;
  final TextEditingController searchController;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<int> onSortTabChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String query) onSearch;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: RefreshIndicator(
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
              slivers: [
                const SliverToBoxAdapter(child: StatusBarSpacer()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            hint: '搜索模板',
                            controller: searchController,
                            onSubmitted: (q) => onSearch(q),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: CommunityCategoryChips(
                    selectedIndex: categoryIndex,
                    onChanged: onCategoryChanged,
                  ),
                ),
                const SliverToBoxAdapter(child: CommunityFeaturedBanner()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: FeedTabBar(
                      tabs: AppCatalog.communitySortTabs,
                      selectedIndex: sortTabIndex,
                      onChanged: onSortTabChanged,
                      underlineStyle: true,
                    ),
                  ),
                ),
                ..._buildContentSlivers(context),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(BuildContext context) {
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
      if (error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: InlineErrorBanner(
              message: error!,
              onRetry: onRefresh,
            ),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.62,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final script = scripts[index];
              return CommunityTemplateCard(
                screenplay: script,
                showHotBadge: index == 0 && sortTabIndex == 0,
              );
            },
            childCount: scripts.length,
          ),
        ),
      ),
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

class _CommunityDesktopView extends StatelessWidget {
  const _CommunityDesktopView({
    required this.scripts,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    required this.error,
    required this.categoryIndex,
    required this.sortTabIndex,
    required this.searchController,
    required this.onCategoryChanged,
    required this.onSortTabChanged,
    required this.onRefresh,
    required this.onSearch,
    required this.onLoadMore,
  });

  final List<Screenplay> scripts;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;
  final int categoryIndex;
  final int sortTabIndex;
  final TextEditingController searchController;
  final ValueChanged<int> onCategoryChanged;
  final ValueChanged<int> onSortTabChanged;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String query) onSearch;
  final Future<void> Function() onLoadMore;

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('模板市场'),
      onBack: () => popOrGoDiscovery(context),
      centerTitle: false,
      body: RefreshIndicator(
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.spacingXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('模板市场', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hint: '搜索模板…',
                        controller: searchController,
                        onSubmitted: (q) => onSearch(q),
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
                const SizedBox(height: 16),
                FeedTabBar(
                  tabs: AppCatalog.communitySortTabs,
                  selectedIndex: sortTabIndex,
                  onChanged: onSortTabChanged,
                  underlineStyle: true,
                ),
                const SizedBox(height: 20),
                const FeaturedBanner(),
                const SizedBox(height: 24),
                Wrap(
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
                const SizedBox(height: 28),
                Text('热门模板', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 16),
                if (error != null && scripts.isNotEmpty)
                  InlineErrorBanner(message: error!, onRetry: onRefresh),
                if (loading && scripts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (error != null && scripts.isEmpty)
                  Builder(
                    builder: (context) {
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
                    },
                  )
                else if (scripts.isEmpty)
                  const EmptyStateView(
                    icon: Icons.storefront_outlined,
                    title: '暂无模板',
                    subtitle: '稍后再来看看',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: Breakpoints.gridColumns(context, desktop: 4),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: feedGridChildAspectRatio(
                        Breakpoints.gridColumns(context, desktop: 4),
                      ),
                    ),
                    itemCount: scripts.length,
                    itemBuilder: (_, index) {
                      final script = scripts[index];
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
                  ),
                if (loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(AppDimensions.spacingMd),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
