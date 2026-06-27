import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import '../../domain/scene_utils.dart';
import '../widgets/scene_action_sheet.dart';
import '../widgets/scene_category_chips.dart';
import '../widgets/scene_masonry_grid.dart';

class SceneListPage extends StatefulWidget {
  const SceneListPage({super.key});

  @override
  State<SceneListPage> createState() => _SceneListPageState();
}

class _SceneListPageState extends State<SceneListPage> {
  final _repo = SceneRepository.instance;
  final _auth = AuthRepository.instance;
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

  List<SceneEntry> get _categoryFiltered {
    final category = AppCatalog.sceneCategoryChips[_categoryIndex];
    return filterScenesByCategory(_repo.filteredItems, category);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hot = _repo.hotScenes;
    final recommended = sortScenesByTab(
      _categoryFiltered,
      AppCatalog.sceneSortTabs[_sortTabIndex],
    );

    return DesktopStackScaffold(
      title: const Text('场景库'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        IconButton(
          tooltip: '我的场景',
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => context.push(AppRoutes.myScenes),
        ),
        if (_auth.isLoggedIn)
          IconButton(
            tooltip: '新建场景',
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push(AppRoutes.sceneCreate);
              if (mounted) _load();
            },
          ),
      ],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: StudioEditorShellGlassButton(
          label: 'AI 场景',
          icon: Icons.auto_awesome,
          minWidth: 120,
          onPressed: () => context.push(AppRoutes.sceneAi),
        ),
      ),
      body: ColoredBox(
        color: isDark
            ? AppColors.characterBackgroundDark
            : Theme.of(context).scaffoldBackgroundColor,
        child: Column(
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
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: '筛选',
                    onPressed: () => _showFilterSheet(context),
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            SceneCategoryChips(
              chips: AppCatalog.sceneCategoryChips,
              selectedIndex: _categoryIndex,
              onChanged: (index) => setState(() => _categoryIndex = index),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: _repo.loading && _repo.items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : recommended.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.15,
                            ),
                            EmptyStateView(
                              icon: Icons.landscape_outlined,
                              title: _repo.error ?? '暂无场景',
                              subtitle: _repo.error != null ? null : '创建第一个场景',
                              actionLabel: _auth.isLoggedIn ? '新建场景' : null,
                              onAction: _auth.isLoggedIn
                                  ? () async {
                                      await context.push(AppRoutes.sceneCreate);
                                      if (mounted) _load();
                                    }
                                  : null,
                            ),
                          ],
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacingXl * 2,
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
                                    isLoggedIn: _auth.isLoggedIn,
                                    isFavorite: _favorites.contains(entry.id),
                                    onToggleFavorite: () =>
                                        _toggleFavorite(entry),
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
                                            AppCatalog.sceneSortTabs[
                                                _sortTabIndex],
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
                                  isLoggedIn: _auth.isLoggedIn,
                                  isFavorite: _favorites.contains(entry.id),
                                  onToggleFavorite: () => _toggleFavorite(entry),
                                  onRefresh: _load,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
          ),
        );
      },
    );
  }
}
