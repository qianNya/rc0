import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../data/feed_repository.dart';
import '../../domain/explore_feed_query.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_bar.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../widgets/explore_desktop_card.dart';
import '../widgets/explore_desktop_header.dart';
import '../widgets/explore_desktop_right_panel.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../widgets/explore_app_bar.dart';
import '../widgets/explore_featured_carousel.dart';
import '../widgets/explore_featured_section.dart';
import '../widgets/explore_quick_actions.dart';
import 'explore_page_shared.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    this.embeddedInHub = false,
    this.showInlineSearchAction = true,
    this.showInlineFeedTabs = true,
    this.mobileFeedTabIndex,
    this.onMobileFeedTabChanged,
  });

  final bool embeddedInHub;
  final bool showInlineSearchAction;
  final bool showInlineFeedTabs;
  final int? mobileFeedTabIndex;
  final ValueChanged<int>? onMobileFeedTabChanged;

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _localRepository = ScreenplayLocalRepository.instance;
  final _remoteRepository = ScreenplayRemoteRepository.instance;
  final _feedRepository = FeedRepository.instance;
  final _selectionController = ScreenplaySelectionController();
  int _feedTabIndex = 0;
  int _mobileFeedTabIndex = 0;
  String _searchQuery = '';

  int get _effectiveMobileFeedTabIndex =>
      widget.mobileFeedTabIndex ?? _mobileFeedTabIndex;

  void _handleMobileFeedTabChanged(int index) {
    final external = widget.onMobileFeedTabChanged;
    if (external != null) {
      external(index);
      return;
    }
    setState(() => _mobileFeedTabIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _localRepository.addListener(_onDataChanged);
    _remoteRepository.addListener(_onDataChanged);
    _feedRepository.addListener(_onDataChanged);
    _selectionController.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _remoteRepository.loadFirstPage();
      _feedRepository.loadFirstPage(
        feedQuery: ExploreFeedQuery.forTab(_feedTabIndex),
      );
    });
  }

  @override
  void dispose() {
    _localRepository.removeListener(_onDataChanged);
    _remoteRepository.removeListener(_onDataChanged);
    _feedRepository.removeListener(_onDataChanged);
    _selectionController.removeListener(_onDataChanged);
    _selectionController.dispose();
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  List<Screenplay> get _localScripts => _localRepository.localScreenplays;

  List<Screenplay> get _mobileFeedItems => [
    ..._localScripts,
    ..._remoteRepository.screenplays,
  ];

  List<Screenplay> get _desktopFeedItems => [
    ..._localScripts,
    ..._feedRepository.items,
  ];

  List<String> get _localIds =>
      _localScripts.map((s) => s.id).toList(growable: false);

  Future<void> _deleteScript(Screenplay script) async {
    await confirmAndDeleteScreenplays(context, [script]);
  }

  Future<void> _deleteSelected() async {
    final selected = _selectionController.selectedLocalIds.toList();
    if (selected.isEmpty) return;
    final scripts = _localScripts
        .where((s) => selected.contains(s.id))
        .toList(growable: false);
    final ok = await confirmAndDeleteScreenplays(context, scripts);
    if (ok && mounted) {
      _selectionController.exitSelection();
    }
  }

  Future<void> _onDesktopFeedTabChanged(int index) async {
    setState(() => _feedTabIndex = index);
    await _feedRepository.loadFirstPage(
      q: _searchQuery.isEmpty ? null : _searchQuery,
      feedQuery: ExploreFeedQuery.forTab(index),
    );
  }

  Future<void> _onDesktopSearch(String query) async {
    setState(() => _searchQuery = query);
    await _feedRepository.loadFirstPage(
      q: query.isEmpty ? null : query,
      feedQuery: ExploreFeedQuery.forTab(_feedTabIndex),
    );
  }

  Future<void> _onDesktopTagTap(String tag) => _onDesktopSearch(tag);

  Future<void> _refreshDesktopFeed() => _feedRepository.loadFirstPage(
    q: _searchQuery.isEmpty ? null : _searchQuery,
    feedQuery: ExploreFeedQuery.forTab(_feedTabIndex),
  );

  @override
  Widget build(BuildContext context) {
    final selectionProps = (
      controller: _selectionController,
      localIds: _localIds,
      onDeleteSelected: _deleteSelected,
    );

    return ResponsiveBuilder(
      mobile: (_) => _ExploreMobileView(
        embeddedInHub: widget.embeddedInHub,
        showInlineSearchAction: widget.showInlineSearchAction,
        showInlineFeedTabs: widget.showInlineFeedTabs,
        feedItems: _mobileFeedItems,
        feedTabIndex: _effectiveMobileFeedTabIndex,
        remoteLoading: _remoteRepository.loading,
        remoteLoadingMore: _remoteRepository.loadingMore,
        remoteError: _remoteRepository.error,
        remoteHasMore: _remoteRepository.hasMore,
        onFeedTabChanged: _handleMobileFeedTabChanged,
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
        embeddedInHub: widget.embeddedInHub,
        feedItems: _desktopFeedItems,
        feedTabIndex: _feedTabIndex,
        remoteLoading: _feedRepository.loading,
        remoteLoadingMore: _feedRepository.loadingMore,
        remoteError: _feedRepository.error,
        remoteHasMore: _feedRepository.hasMore,
        searchQuery: _searchQuery,
        onFeedTabChanged: _onDesktopFeedTabChanged,
        onSearch: _onDesktopSearch,
        onTagTap: _onDesktopTagTap,
        onDelete: _deleteScript,
        onCreate: () => context.go(AppRoutes.studio),
        onRefreshRemote: _refreshDesktopFeed,
        onLoadMore: () => _feedRepository.loadMore(),
        selectionController: selectionProps.controller,
        localIds: selectionProps.localIds,
        onDeleteSelected: selectionProps.onDeleteSelected,
        onSelectionChanged: _onDataChanged,
      ),
    );
  }
}

class _ExploreMobileView extends StatelessWidget {
  const _ExploreMobileView({
    this.embeddedInHub = false,
    this.showInlineSearchAction = true,
    this.showInlineFeedTabs = true,
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

  final bool embeddedInHub;
  final bool showInlineSearchAction;
  final bool showInlineFeedTabs;

  @override
  Widget build(BuildContext context) {
    final showSecondaryBar =
        showInlineFeedTabs ||
        localIds.isNotEmpty ||
        selectionController.selectionMode;

    Widget buildFeedScroll() {
      return RefreshIndicator(
        onRefresh: onRefreshRemote,
        child: FadeSlideIndexedStack(
          index: feedTabIndex,
          children: [
            for (var i = 0; i < AppCatalog.feedTabs.length; i++)
              NotificationListener<ScrollNotification>(
                key: ValueKey('explore-mobile-tab-$i'),
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
                      child: const ExploreFeaturedCarousel(
                        bleedUnderHeader: false,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: ExploreQuickActions(),
                    ),
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        title: '灵感推荐',
                        action: '更多',
                        showChevron: true,
                        onActionTap: () => context.go(AppRoutes.community),
                        titleStyle: AppTextStyles.title.copyWith(
                          fontSize: 16,
                        ),
                        actionStyle: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 13,
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      ),
                    ),
                    ...buildDiscoverySlivers(
                      context: context,
                      feedItems: feedItems,
                      remoteLoading: remoteLoading,
                      remoteError: remoteError,
                      remoteLoadingMore: remoteLoadingMore,
                      onDelete: onDelete,
                      onUpload: onUpload,
                      onRefreshRemote: onRefreshRemote,
                      selectionController: selectionController,
                      overlayMetrics: false,
                    ),
                    ListenableBuilder(
                      listenable: selectionController,
                      builder: (context, _) {
                        final selectionExtra =
                            selectionController.selectionMode
                            ? AppDimensions.primaryButtonHeight +
                                  AppDimensions.spacingMd * 2
                            : 0.0;
                        return SliverToBoxAdapter(
                          child: ShellBottomSpacer(extra: selectionExtra),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    Widget buildBodyContent() {
      final scroll = buildFeedScroll();
      if (!showSecondaryBar) return scroll;

      final bar = Padding(
        padding: const EdgeInsets.only(top: 4, right: 4),
        child: SizedBox(
          height: AppDimensions.shellBarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showInlineFeedTabs)
                Expanded(
                  child: FeedTabBar(
                    tabs: AppCatalog.feedTabs,
                    selectedIndex: feedTabIndex,
                    onChanged: onFeedTabChanged,
                    underlineStyle: true,
                    embedded: true,
                  ),
                )
              else
                const Spacer(),
              ScreenplaySelectionAppBarActions(
                controller: selectionController,
                localIds: localIds,
                onSelectionChanged: onSelectionChanged,
              ),
            ],
          ),
        ),
      );

      if (embeddedInHub) {
        return Stack(
          fit: StackFit.expand,
          children: [
            scroll,
            Positioned(top: 0, left: 0, right: 0, child: bar),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar,
          Expanded(child: scroll),
        ],
      );
    }

    final selectionBar = ScreenplaySelectionBottomBar(
      controller: selectionController,
      onDelete: () => onDeleteSelected(),
    );

    if (embeddedInHub) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: buildBodyContent()),
          selectionBar,
        ],
      );
    }

    return WikiModeTagPageScaffold(
      appBar: const ExploreAppBar(embeddedInHub: false),
      body: buildBodyContent(),
      bottomNavigationBar: selectionBar,
    );
  }
}

class _ExploreDesktopFeedPanel extends StatelessWidget {
  const _ExploreDesktopFeedPanel({
    super.key,
    required this.feedTabIndex,
    required this.tabIndex,
    required this.remoteOnly,
    required this.feedItems,
    required this.remoteLoading,
    required this.remoteLoadingMore,
    required this.remoteError,
    required this.remoteHasMore,
    required this.onDelete,
    required this.onCreate,
    required this.onRefreshRemote,
    required this.onLoadMore,
    required this.selectionController,
    this.embeddedInHub = false,
  });

  final int feedTabIndex;
  final int tabIndex;
  final List<Screenplay> remoteOnly;
  final List<Screenplay> feedItems;
  final bool remoteLoading;
  final bool remoteLoadingMore;
  final String? remoteError;
  final bool remoteHasMore;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onCreate;
  final Future<void> Function() onRefreshRemote;
  final Future<void> Function() onLoadMore;
  final ScreenplaySelectionController selectionController;
  final bool embeddedInHub;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefreshRemote,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (feedTabIndex != tabIndex) return false;
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 320 &&
              remoteHasMore &&
              !remoteLoadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: ExploreDesktopChrome.gap * 2),
          children: [
            ExploreFeaturedSection(items: remoteOnly),
            const SizedBox(height: ExploreDesktopChrome.gap * 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ExploreDesktopChrome.gap * 2,
                0,
                ExploreDesktopChrome.gap * 2,
                ExploreDesktopChrome.gap,
              ),
              child: Row(
                children: [
                  Text(
                    '精选内容',
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.community),
                    child: const Text('模板市场'),
                  ),
                ],
              ),
            ),
            buildDiscoveryFeedBody(
              context: context,
              feedItems: feedItems,
              remoteLoading: remoteLoading,
              remoteError: remoteError,
              remoteLoadingMore: remoteLoadingMore,
              onDelete: onDelete,
              onUpload: onCreate,
              onRefreshRemote: onRefreshRemote,
              selectionController: selectionController,
              bottomPadding: ExploreDesktopChrome.gap,
              gridSpacing: ExploreDesktopChrome.gap,
              overlayMetrics: false,
            ),
            if (remoteHasMore && !remoteLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ExploreDesktopChrome.gap * 2,
                  vertical: ExploreDesktopChrome.gap,
                ),
                child: Center(
                  child: remoteLoadingMore
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : OutlinedButton(
                          onPressed: () => onLoadMore(),
                          child: const Text('加载更多'),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExploreDesktopView extends StatelessWidget {
  const _ExploreDesktopView({
    this.embeddedInHub = false,
    required this.feedItems,
    required this.feedTabIndex,
    required this.remoteLoading,
    required this.remoteLoadingMore,
    required this.remoteError,
    required this.remoteHasMore,
    required this.searchQuery,
    required this.onFeedTabChanged,
    required this.onSearch,
    required this.onTagTap,
    required this.onDelete,
    required this.onCreate,
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
  final String searchQuery;
  final ValueChanged<int> onFeedTabChanged;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onTagTap;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onCreate;
  final Future<void> Function() onRefreshRemote;
  final Future<void> Function() onLoadMore;
  final ScreenplaySelectionController selectionController;
  final List<String> localIds;
  final Future<void> Function() onDeleteSelected;
  final VoidCallback onSelectionChanged;

  final bool embeddedInHub;

  @override
  Widget build(BuildContext context) {
    final remoteOnly = feedItems.where((s) => !s.isLocal).toList();

    if (embeddedInHub) {
      return _ExploreDesktopFeedPanel(
        key: const ValueKey('discovery-embedded'),
        feedTabIndex: feedTabIndex,
        tabIndex: feedTabIndex,
        remoteOnly: remoteOnly,
        feedItems: feedItems,
        remoteLoading: remoteLoading,
        remoteLoadingMore: remoteLoadingMore,
        remoteError: remoteError,
        remoteHasMore: remoteHasMore,
        onDelete: onDelete,
        onCreate: onCreate,
        onRefreshRemote: onRefreshRemote,
        onLoadMore: onLoadMore,
        selectionController: selectionController,
        embeddedInHub: true,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExploreDesktopHeader(
            initialQuery: searchQuery,
            onSearch: onSearch,
            onCreate: onCreate,
          ),
          const SizedBox(height: ExploreDesktopChrome.gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ExploreDesktopCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ExploreDesktopChrome.gap * 2,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: FeedTabBar(
                                  tabs: ExploreFeedQuery.desktopTabs,
                                  selectedIndex: feedTabIndex,
                                  onChanged: onFeedTabChanged,
                                  underlineStyle: true,
                                  embedded: true,
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
                        Expanded(
                          child: FadeSlideIndexedStack(
                            index: feedTabIndex,
                            children: [
                              for (
                                var i = 0;
                                i < ExploreFeedQuery.desktopTabs.length;
                                i++
                              )
                                _ExploreDesktopFeedPanel(
                                  key: ValueKey('explore-desktop-tab-$i'),
                                  feedTabIndex: feedTabIndex,
                                  tabIndex: i,
                                  remoteOnly: remoteOnly,
                                  feedItems: feedItems,
                                  remoteLoading: remoteLoading,
                                  remoteLoadingMore: remoteLoadingMore,
                                  remoteError: remoteError,
                                  remoteHasMore: remoteHasMore,
                                  onDelete: onDelete,
                                  onCreate: onCreate,
                                  onRefreshRemote: onRefreshRemote,
                                  onLoadMore: onLoadMore,
                                  selectionController: selectionController,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: ExploreDesktopChrome.gap),
                ExploreDesktopRightPanel(
                  feedItems: remoteOnly,
                  onTagTap: onTagTap,
                  onCreate: onCreate,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ScreenplaySelectionBottomBar(
        controller: selectionController,
        onDelete: () => onDeleteSelected(),
      ),
    );
  }
}
