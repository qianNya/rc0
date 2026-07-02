import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import '../../domain/scene_utils.dart';
import '../widgets/scene_action_sheet.dart';
import '../widgets/scene_create_sheet.dart';
import '../widgets/scene_masonry_grid.dart';

class MyScenesPage extends StatefulWidget {
  const MyScenesPage({super.key});

  @override
  State<MyScenesPage> createState() => _MyScenesPageState();
}

class _MyScenesPageState extends State<MyScenesPage> {
  final _repo = SceneRepository.instance;
  final _auth = AuthRepository.instance;
  int _tabIndex = 0;
  Set<String> _ownedIds = {};
  Set<String> _favorites = {};
  Set<String> _usedIds = {};
  final Map<String, String> _localCovers = {};

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    _load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _repo.loadFirstPage(pageSize: 100);
    _ownedIds = await SceneLocalStore.instance.ownedIds();
    _favorites = await SceneLocalStore.instance.favoriteIds();
    await _repo.ensureScenesInCache({..._ownedIds, ..._favorites});
    _usedIds = await SceneLocalStore.instance.usedIds();
    await _loadLocalCovers();
    if (mounted) setState(() {});
  }

  Future<void> _loadLocalCovers() async {
    final covers = <String, String>{};
    for (final entry in _repo.items) {
      final path = await SceneLocalStore.instance.localCoverPath(entry.id);
      if (path != null && path.isNotEmpty) covers[entry.id] = path;
    }
    _localCovers
      ..clear()
      ..addAll(covers);
  }

  List<SceneEntry> _filteredForTab(int tabIndex) {
    return _repo.items
        .where(
          (e) => matchesMySceneTab(
            e,
            tabIndex,
            favoriteIds: _favorites,
            ownedIds: _ownedIds,
            usedIds: _usedIds,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _openCreateScene() async {
    await showSceneCreateSheet(context);
    if (mounted) _load();
  }

  Widget _buildSceneTabBody(int tabIndex) {
    final filtered = _filteredForTab(tabIndex);
    if (filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.landscape_outlined,
        title: '暂无场景',
        actionLabel: _auth.isLoggedIn ? '新建场景' : null,
        onAction: _auth.isLoggedIn ? _openCreateScene : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SceneMasonryGrid(
            items: filtered,
            localCoverFor: (e) => _localCovers[e.id],
            screenplayCountFor: (e) => _repo.countScreenplaysForScene(e.id),
            favoriteCountFor: (e) =>
                _favorites.contains(e.id) ? e.favoriteCount + 1 : e.favoriteCount,
            onTap: (entry) => context.push(AppRoutes.sceneDetailPath(entry.id)),
            onLongPress: (entry) => showSceneActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: _auth.isLoggedIn,
              isFavorite: _favorites.contains(entry.id),
              onToggleFavorite: () async {
                final next = !_favorites.contains(entry.id);
                await SceneLocalStore.instance.setFavorite(entry.id, next);
                await _load();
              },
              onRefresh: _load,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DesktopStackScaffold(
      title: const Text('我的场景'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        if (_auth.isLoggedIn)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openCreateScene,
          ),
      ],
      body: ColoredBox(
        color: isDark
            ? AppColors.characterBackgroundDark
            : Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                0,
              ),
              child: FeedTabBar(
                tabs: AppCatalog.mySceneTabs,
                selectedIndex: _tabIndex,
                onChanged: (index) => setState(() => _tabIndex = index),
                underlineStyle: true,
                embedded: true,
              ),
            ),
            Expanded(
              child: FadeSlideIndexedStack(
                index: _tabIndex,
                children: [
                  for (var i = 0; i < AppCatalog.mySceneTabs.length; i++)
                    _buildSceneTabBody(i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
