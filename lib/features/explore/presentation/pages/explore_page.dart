import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_bar.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../../../../shared/widgets/app_brand_icon.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../widgets/explore_featured_carousel.dart';
import '../widgets/explore_feed_grid_card.dart';
import '../widgets/explore_quick_actions.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _localRepository = ScreenplayLocalRepository.instance;
  final _remoteRepository = ScreenplayRemoteRepository.instance;
  final _selectionController = ScreenplaySelectionController();
  int _feedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _localRepository.addListener(_onDataChanged);
    _remoteRepository.addListener(_onDataChanged);
    _selectionController.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _remoteRepository.loadFirstPage();
    });
  }

  @override
  void dispose() {
    _localRepository.removeListener(_onDataChanged);
    _remoteRepository.removeListener(_onDataChanged);
    _selectionController.removeListener(_onDataChanged);
    _selectionController.dispose();
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  List<Screenplay> get _allScripts => _localRepository.localScreenplays;

  List<Screenplay> get _feedItems => [..._allScripts, ..._remoteRepository.screenplays];

  List<String> get _localIds =>
      _allScripts.map((s) => s.id).toList(growable: false);

  Future<void> _deleteScript(Screenplay script) async {
    await confirmAndDeleteScreenplays(context, [script]);
  }

  Future<void> _deleteSelected() async {
    final selected = _selectionController.selectedLocalIds.toList();
    if (selected.isEmpty) return;
    final scripts = _allScripts
        .where((s) => selected.contains(s.id))
        .toList(growable: false);
    final ok = await confirmAndDeleteScreenplays(context, scripts);
    if (ok && mounted) {
      _selectionController.exitSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionProps = (
      controller: _selectionController,
      localIds: _localIds,
      onDeleteSelected: _deleteSelected,
    );

    return ResponsiveBuilder(
      mobile: (_) => _ExploreMobileView(
        feedItems: _feedItems,
        feedTabIndex: _feedTabIndex,
        remoteLoading: _remoteRepository.loading,
        remoteLoadingMore: _remoteRepository.loadingMore,
        remoteError: _remoteRepository.error,
        remoteHasMore: _remoteRepository.hasMore,
        onFeedTabChanged: (i) => setState(() => _feedTabIndex = i),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.studio),
        onRefreshRemote: () => _remoteRepository.loadFirstPage(),
        onLoadMore: () => _remoteRepository.loadMore(),
        selectionController: selectionProps.controller,
        localIds: selectionProps.localIds,
        onDeleteSelected: selectionProps.onDeleteSelected,
        onSelectionChanged: _onDataChanged,
      ),
      desktop: (_) => _ExploreDesktopView(
        feedItems: _feedItems,
        feedTabIndex: _feedTabIndex,
        remoteLoading: _remoteRepository.loading,
        remoteLoadingMore: _remoteRepository.loadingMore,
        remoteError: _remoteRepository.error,
        remoteHasMore: _remoteRepository.hasMore,
        onFeedTabChanged: (i) => setState(() => _feedTabIndex = i),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.studio),
        onRefreshRemote: () => _remoteRepository.loadFirstPage(),
        onLoadMore: () => _remoteRepository.loadMore(),
        selectionController: selectionProps.controller,
        localIds: selectionProps.localIds,
        onDeleteSelected: selectionProps.onDeleteSelected,
        onSelectionChanged: _onDataChanged,
      ),
    );
  }
}

List<Widget> _buildDiscoverySlivers({
  required BuildContext context,
  required List<Screenplay> feedItems,
  required bool remoteLoading,
  required String? remoteError,
  required bool remoteLoadingMore,
  required Future<void> Function(Screenplay) onDelete,
  required VoidCallback onUpload,
  required Future<void> Function() onRefreshRemote,
  required ScreenplaySelectionController selectionController,
}) {
  return [
    SliverToBoxAdapter(
      child: _buildDiscoveryFeedBody(
        context: context,
        feedItems: feedItems,
        remoteLoading: remoteLoading,
        remoteError: remoteError,
        remoteLoadingMore: remoteLoadingMore,
        onDelete: onDelete,
        onUpload: onUpload,
        onRefreshRemote: onRefreshRemote,
        bottomPadding: 24,
        selectionController: selectionController,
      ),
    ),
    if (remoteLoadingMore)
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
  ];
}

Widget _buildRemoteEmptyState({
  required BuildContext context,
  required String? remoteError,
  required Future<void> Function() onRefreshRemote,
  required VoidCallback onUpload,
}) {
  if (remoteError == null) {
    return EmptyStateView(
      icon: Icons.movie_creation_outlined,
      title: '还没有内容',
      subtitle: '上传参考图，按「剧本 → 幕 → 场 → 画」组织你的分镜',
      actionLabel: '去创作',
      onAction: onUpload,
    );
  }

  if (isUnauthorizedError(remoteError)) {
    return EmptyStateView(
      icon: Icons.lock_outline,
      title: '登录已过期',
      subtitle: '请重新登录后查看云端内容',
      actionLabel: '去登录',
      onAction: () => context.go(
        AppRoutes.loginWithRedirect(AppRoutes.discovery),
      ),
    );
  }

  if (isMaintenanceError(remoteError)) {
    return EmptyStateView(
      icon: Icons.build_circle_outlined,
      title: '系统维护中',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isNetworkError(remoteError)) {
    return EmptyStateView(
      icon: Icons.wifi_off_outlined,
      title: '网络不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isServerError(remoteError)) {
    return EmptyStateView(
      icon: Icons.cloud_off_outlined,
      title: '服务暂时不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  return EmptyStateView(
    icon: Icons.cloud_off_outlined,
    title: '加载失败',
    subtitle: remoteError,
    actionLabel: '重试',
    onAction: () => onRefreshRemote(),
  );
}

Widget _buildDiscoveryFeedBody({
  required BuildContext context,
  required List<Screenplay> feedItems,
  required bool remoteLoading,
  required String? remoteError,
  required bool remoteLoadingMore,
  required Future<void> Function(Screenplay) onDelete,
  required VoidCallback onUpload,
  required Future<void> Function() onRefreshRemote,
  required ScreenplaySelectionController selectionController,
  double bottomPadding = 32,
  double gridSpacing = 12,
}) {
  if (remoteLoading && feedItems.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  if (feedItems.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: _buildRemoteEmptyState(
        context: context,
        remoteError: remoteError,
        onRefreshRemote: onRefreshRemote,
        onUpload: onUpload,
      ),
    );
  }

  final crossAxisCount = Breakpoints.gridColumns(context, mobile: 2, desktop: 4);
  final aspectRatio = feedGridChildAspectRatio(crossAxisCount);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (remoteError != null && !isUnauthorizedError(remoteError))
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: InlineErrorBanner(
            message: remoteError,
            onRetry: () => onRefreshRemote(),
          ),
        ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: gridSpacing,
          crossAxisSpacing: gridSpacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: feedItems.length,
        itemBuilder: (_, index) {
          final item = feedItems[index];
          final isLocal = item.isLocal;
          return ExploreFeedGridCard(
            screenplay: item,
            onDelete: isLocal ? () => onDelete(item) : null,
            selectionMode: selectionController.selectionMode && isLocal,
            selected: selectionController.isSelected(item.id),
            onSelectedToggle: isLocal
                ? () => selectionController.toggle(item.id)
                : null,
            onLongPressEnterSelection: isLocal
                ? () => selectionController.enterSelection(initialLocalId: item.id)
                : null,
          );
        },
      ),
    ],
  );
}

class _ExploreMobileView extends StatelessWidget {
  const _ExploreMobileView({
    required this.feedItems,
    required this.feedTabIndex,
    required this.remoteLoading,
    required this.remoteLoadingMore,
    required this.remoteError,
    required this.remoteHasMore,
    required this.onFeedTabChanged,
    required this.onDelete,
    required this.onUpload,
    required this.onRefreshRemote,
    required this.onLoadMore,
    required this.selectionController,
    required this.localIds,
    required this.onDeleteSelected,
    required this.onSelectionChanged,
  });

  final List<Screenplay> feedItems;
  final int feedTabIndex;
  final bool remoteLoading;
  final bool remoteLoadingMore;
  final String? remoteError;
  final bool remoteHasMore;
  final ValueChanged<int> onFeedTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;
  final Future<void> Function() onRefreshRemote;
  final Future<void> Function() onLoadMore;
  final ScreenplaySelectionController selectionController;
  final List<String> localIds;
  final Future<void> Function() onDeleteSelected;
  final VoidCallback onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefreshRemote,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 240 &&
                  remoteHasMore &&
                  !remoteLoadingMore) {
                onLoadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, right: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: FeedTabBar(
                            // Cosmetic tabs until feed API is wired.
                            tabs: AppCatalog.feedTabs,
                            selectedIndex: feedTabIndex,
                            onChanged: onFeedTabChanged,
                            underlineStyle: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => context.push(AppRoutes.search),
                        ),
                        ScreenplaySelectionAppBarActions(
                          controller: selectionController,
                          localIds: localIds,
                          onSelectionChanged: onSelectionChanged,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: ExploreFeaturedCarousel()),
                const SliverToBoxAdapter(child: ExploreQuickActions()),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: '灵感推荐',
                    action: '更多',
                    showChevron: true,
                    onActionTap: () => context.push(AppRoutes.community),
                    titleStyle: AppTextStyles.title.copyWith(fontSize: 16),
                    actionStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  ),
                ),
                ..._buildDiscoverySlivers(
                  context: context,
                  feedItems: feedItems,
                  remoteLoading: remoteLoading,
                  remoteError: remoteError,
                  remoteLoadingMore: remoteLoadingMore,
                  onDelete: onDelete,
                  onUpload: onUpload,
                  onRefreshRemote: onRefreshRemote,
                  selectionController: selectionController,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ScreenplaySelectionBottomBar(
        controller: selectionController,
        onDelete: () => onDeleteSelected(),
      ),
    );
  }
}

class _ExploreDesktopView extends StatelessWidget {
  const _ExploreDesktopView({
    required this.feedItems,
    required this.feedTabIndex,
    required this.remoteLoading,
    required this.remoteLoadingMore,
    required this.remoteError,
    required this.remoteHasMore,
    required this.onFeedTabChanged,
    required this.onDelete,
    required this.onUpload,
    required this.onRefreshRemote,
    required this.onLoadMore,
    required this.selectionController,
    required this.localIds,
    required this.onDeleteSelected,
    required this.onSelectionChanged,
  });

  final List<Screenplay> feedItems;
  final int feedTabIndex;
  final bool remoteLoading;
  final bool remoteLoadingMore;
  final String? remoteError;
  final bool remoteHasMore;
  final ValueChanged<int> onFeedTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;
  final Future<void> Function() onRefreshRemote;
  final Future<void> Function() onLoadMore;
  final ScreenplaySelectionController selectionController;
  final List<String> localIds;
  final Future<void> Function() onDeleteSelected;
  final VoidCallback onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefreshRemote,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.extentAfter < 240 &&
                remoteHasMore &&
                !remoteLoadingMore) {
              onLoadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: AdaptiveContent(
                    child: Row(
                      children: [
                        Expanded(
                          child: FeedTabBar(
                            tabs: AppCatalog.feedTabs,
                            selectedIndex: feedTabIndex,
                            onChanged: onFeedTabChanged,
                            underlineStyle: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => context.push(AppRoutes.search),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: '创作',
                          child: IconButton(
                            onPressed: onUpload,
                            icon: const AppBrandIcon(size: 22),
                          ),
                        ),
                        ScreenplaySelectionAppBarActions(
                          controller: selectionController,
                          localIds: localIds,
                          onSelectionChanged: onSelectionChanged,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: AdaptiveContent(child: ExploreFeaturedCarousel()),
              ),
              const SliverToBoxAdapter(
                child: AdaptiveContent(child: ExploreQuickActions()),
              ),
              SliverToBoxAdapter(
                child: AdaptiveContent(
                  child: SectionHeader(
                    title: '灵感推荐',
                    action: '更多',
                    showChevron: true,
                    onActionTap: () => context.push(AppRoutes.community),
                    titleStyle: AppTextStyles.title.copyWith(fontSize: 16),
                    actionStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AdaptiveContent(
                  child: _buildDiscoveryFeedBody(
                    context: context,
                    feedItems: feedItems,
                    remoteLoading: remoteLoading,
                    remoteError: remoteError,
                    remoteLoadingMore: remoteLoadingMore,
                    onDelete: onDelete,
                    onUpload: onUpload,
                    onRefreshRemote: onRefreshRemote,
                    gridSpacing: 16,
                    selectionController: selectionController,
                  ),
                ),
              ),
              if (remoteLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ScreenplaySelectionBottomBar(
        controller: selectionController,
        onDelete: () => onDeleteSelected(),
      ),
    );
  }
}
