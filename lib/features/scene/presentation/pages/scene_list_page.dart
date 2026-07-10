import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import '../../domain/scene_utils.dart';
import '../widgets/scene_action_sheet.dart';
import '../widgets/scene_category_chips.dart';
import '../widgets/scene_create_sheet.dart';
import '../widgets/scene_map_pick.dart';
import '../widgets/scene_map_sheet.dart';
import '../widgets/scene_masonry_grid.dart';
import '../widgets/scene_wiki_app_bar.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';

class SceneListPage extends ConsumerStatefulWidget {
  const SceneListPage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  ConsumerState<SceneListPage> createState() => _SceneListPageState();
}

class _SceneListPageState extends ConsumerState<SceneListPage> {
  final _repo = SceneRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _categoryIndex = 0;
  int _sortTabIndex = 1;
  Set<String> _favorites = {};
  final Map<String, String> _localCovers = {};

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _scrollController.addListener(_onScroll);
    _load();
    _loadFavorites();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 480) {
      _repo.loadMore();
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await SceneLocalStore.instance.favoriteIds();
    if (!mounted) return;
    setState(() => _favorites = ids);
  }

  Future<void> _load() async {
    await _repo.loadFirstPage(
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      category: AppCatalog.sceneCategoryChips[_categoryIndex],
      sortTab: AppCatalog.sceneSortTabs[_sortTabIndex],
    );
    await _loadLocalCovers();
  }

  Future<void> _loadLocalCovers() async {
    final covers = <String, String>{};
    for (final entry in _repo.items) {
      final path = await SceneLocalStore.instance.localCoverPath(entry.id);
      if (path != null && path.isNotEmpty) {
        covers[entry.id] = path;
      }
    }
    if (!mounted) return;
    setState(() => _localCovers
      ..clear()
      ..addAll(covers));
  }

  List<SceneEntry> get _recommended {
    return sortScenesByTab(
      _repo.filteredItems,
      AppCatalog.sceneSortTabs[_sortTabIndex],
    );
  }

  Future<void> _toggleFavorite(SceneEntry entry) async {
    final next = !_favorites.contains(entry.id);
    await SceneLocalStore.instance.setFavorite(entry.id, next);
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(next ? '已收藏' : '已取消收藏')));
  }

  Future<void> _openCreateScene() async {
    await showSceneCreateSheet(context);
    if (mounted) _load();
  }

  Future<void> _openCreateSceneAtFromMap(SceneMapPick pick) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await showSceneCreateSheet(
      context,
      useRootNavigator: true,
      initialLatitude: pick.point.latitude,
      initialLongitude: pick.point.longitude,
      initialCity: pick.city,
      initialLocation: pick.locationLabel,
    );
    if (mounted) _load();
  }

  Future<void> _openMapSheet() async {
    final isLoggedIn = ref.read(isLoggedInProvider);
    await showSceneMapSheet(
      context,
      repo: _repo,
      isLoggedIn: isLoggedIn,
      onCreateSceneAt: isLoggedIn ? _openCreateSceneAtFromMap : null,
    );
    if (mounted) _load();
  }

  List<Widget> _desktopActions(bool isLoggedIn) {
    return [
      StudioGlassIconButton(
        tooltip: '场景地图',
        icon: Icons.map_outlined,
        onPressed: _openMapSheet,
      ),
      StudioGlassIconButton(
        tooltip: 'AI 场景',
        icon: Icons.auto_awesome,
        onPressed: () => context.push(AppRoutes.sceneAi),
      ),
      StudioGlassIconButton(
        tooltip: '我的场景',
        icon: Icons.folder_outlined,
        onPressed: () => context.push(AppRoutes.myScenes),
      ),
      if (isLoggedIn)
        StudioGlassIconButton(
          tooltip: '新建场景',
          icon: Icons.add,
          onPressed: _openCreateScene,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final hot = _repo.hotScenes;
    final recommended = _recommended;
    final desktop = Breakpoints.useSidebarShell(context);
    final chromeTop = wikiModeTagContentInsetHeight(context);
    final body = Padding(
      padding: EdgeInsets.only(top: desktop ? 0 : chromeTop),
      child: _buildBody(
        context,
        hot: hot,
        recommended: recommended,
        isLoggedIn: isLoggedIn,
      ),
    );

    if (widget.embeddedInHub) {
      return SceneHubScaffold(
        appBar: const SceneHubAppBar(),
        desktopHeader: DesktopHubHeader(
          title: '场景',
          subtitle: '场景库与拍摄空间',
          actions: _desktopActions(isLoggedIn),
        ),
        body: body,
      );
    }

    return DesktopStackScaffold(
      overlayAppBar: true,
      title: const Text('场景库'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        StudioGlassIconButton(
          tooltip: '场景地图',
          icon: Icons.map_outlined,
          onPressed: _openMapSheet,
        ),
        StudioGlassIconButton(
          tooltip: 'AI 场景',
          icon: Icons.auto_awesome,
          onPressed: () => context.push(AppRoutes.sceneAi),
        ),
        StudioGlassIconButton(
          tooltip: '我的场景',
          icon: Icons.folder_outlined,
          onPressed: () => context.push(AppRoutes.myScenes),
        ),
        if (isLoggedIn)
          StudioGlassIconButton(
            tooltip: '新建场景',
            icon: Icons.add,
            onPressed: _openCreateScene,
          ),
      ],
      body: body,
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<SceneEntry> hot,
    required List<SceneEntry> recommended,
    required bool isLoggedIn,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: AppSearchField(
                    hint: '搜索场景名称、标签、地点',
                    controller: _searchController,
                    onSubmitted: (_) => _load(),
                  ),
                ),
              ),
              if (widget.embeddedInHub &&
                  !Breakpoints.useSidebarShell(context)) ...[
                const SizedBox(width: 4),
                StudioGlassIconButton(
                  size: 36,
                  iconSize: 20,
                  tooltip: '场景地图',
                  onPressed: _openMapSheet,
                  icon: Icons.map_outlined,
                ),
                StudioGlassIconButton(
                  size: 36,
                  iconSize: 20,
                  tooltip: '我的场景',
                  onPressed: () => context.push(AppRoutes.myScenes),
                  icon: Icons.folder_outlined,
                ),
                if (isLoggedIn)
                  StudioGlassIconButton(
                    size: 36,
                    iconSize: 20,
                    tooltip: '新建场景',
                    onPressed: _openCreateScene,
                    icon: Icons.add,
                  ),
                StudioGlassIconButton(
                  size: 36,
                  iconSize: 20,
                  tooltip: 'AI 场景',
                  onPressed: () => context.push(AppRoutes.sceneAi),
                  icon: Icons.auto_awesome,
                ),
              ] else if (!widget.embeddedInHub) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '筛选',
                  onPressed: () => _showFilterSheet(context),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ],
          ),
        ),
        SceneCategoryChips(
          chips: AppCatalog.sceneCategoryChips,
          selectedIndex: _categoryIndex,
          onChanged: (index) {
            setState(() => _categoryIndex = index);
            _load();
          },
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(
          child: _repo.loading && _repo.items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMd),
                  child: FeedGridSkeleton(tileCount: 4),
                )
              : recommended.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                        ),
                        GlassEmptyState(
                          icon: Icons.landscape_outlined,
                          title: _repo.error ?? '暂无场景',
                          subtitle: _repo.error != null
                              ? '请检查网络后重试'
                              : '创建第一个场景',
                          actionLabel: _repo.error != null
                              ? '重试'
                              : (isLoggedIn ? '新建场景' : null),
                          onAction: _repo.error != null
                              ? _load
                              : (isLoggedIn ? _openCreateScene : null),
                        ),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: widget.embeddedInHub
                              ? AppDimensions.spacingXl * 3
                              : AppDimensions.spacingXl * 2,
                        ),
                        children: [
                          if (hot.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingMd,
                              ),
                              child: Text(
                                '热门场景',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SceneMasonryGrid(
                              items: hot,
                              localCoverFor: (e) => _localCovers[e.id],
                              screenplayCountFor: (e) =>
                                  _repo.countScreenplaysForScene(e.id),
                              favoriteCountFor: (e) =>
                                  _favorites.contains(e.id)
                                      ? e.favoriteCount + 1
                                      : e.favoriteCount,
                              onTap: (entry) => context.push(
                                AppRoutes.sceneDetailPath(entry.id),
                              ),
                              onLongPress: (entry) => showSceneActionSheet(
                                context: context,
                                entry: entry,
                                repo: _repo,
                                isLoggedIn: isLoggedIn,
                                isFavorite: _favorites.contains(entry.id),
                                onToggleFavorite: () => _toggleFavorite(entry),
                                onRefresh: _load,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spacingMd),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingMd,
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    '推荐场景',
                                    style: AppTextStyles.title,
                                  ),
                                ),
                                PopupMenuButton<int>(
                                  initialValue: _sortTabIndex,
                                  onSelected: (index) {
                                    setState(() => _sortTabIndex = index);
                                    _load();
                                  },
                                  itemBuilder: (context) => [
                                    for (var i = 0;
                                        i < AppCatalog.sceneSortTabs.length;
                                        i++)
                                      PopupMenuItem(
                                        value: i,
                                        child: Text(
                                          AppCatalog.sceneSortTabs[i],
                                        ),
                                      ),
                                  ],
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppCatalog.sceneSortTabs[_sortTabIndex],
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                      const Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SceneMasonryGrid(
                            items: recommended,
                            localCoverFor: (e) => _localCovers[e.id],
                            screenplayCountFor: (e) =>
                                _repo.countScreenplaysForScene(e.id),
                            favoriteCountFor: (e) =>
                                _favorites.contains(e.id)
                                    ? e.favoriteCount + 1
                                    : e.favoriteCount,
                            onTap: (entry) => context.push(
                              AppRoutes.sceneDetailPath(entry.id),
                            ),
                            onLongPress: (entry) => showSceneActionSheet(
                              context: context,
                              entry: entry,
                              repo: _repo,
                              isLoggedIn: isLoggedIn,
                              isFavorite: _favorites.contains(entry.id),
                              onToggleFavorite: () => _toggleFavorite(entry),
                              onRefresh: _load,
                            ),
                          ),
                          if (_repo.loadingMore)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showGlassSheet<void>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('筛选', style: AppTextStyles.title),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final style in AppCatalog.sceneFilterStyles)
                ActionChip(label: Text(style), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('重置'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已应用本地筛选')),
                    );
                  },
                  child: const Text('应用'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
