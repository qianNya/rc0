import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../../domain/character_utils.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/character_masonry_grid.dart';

class MyCharactersPage extends ConsumerStatefulWidget {
  const MyCharactersPage({super.key});

  @override
  ConsumerState<MyCharactersPage> createState() => _MyCharactersPageState();
}

class _MyCharactersPageState extends ConsumerState<MyCharactersPage> {
  final _repo = CharacterRepository.instance;
  final _scrollController = ScrollController();
  int _tabIndex = 1;
  Set<int> _ownedIds = {};
  Set<int> _favorites = {};
  final Map<int, String> _localCovers = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _repo.loadMore();
    }
  }

  Future<void> _load() async {
    await _repo.loadFirstPage();
    _ownedIds = await CharacterLocalStore.instance.ownedCharacterIds();
    _favorites = await CharacterLocalStore.instance.favoriteIds();
    await _loadLocalCovers();
    if (mounted) setState(() {});
  }

  Future<void> _loadLocalCovers() async {
    final covers = <int, String>{};
    for (final entry in _repo.items) {
      final path = await CharacterLocalStore.instance.localCoverPath(entry.id);
      if (path != null && path.isNotEmpty) covers[entry.id] = path;
    }
    _localCovers
      ..clear()
      ..addAll(covers);
  }

  List<CharacterEntry> _filteredForTab(int tabIndex) {
    if (tabIndex == 2) return const [];
    return _repo.items
        .where(
          (e) => matchesMyCharacterTab(
            e,
            tabIndex,
            ownedIds: _ownedIds,
          ),
        )
        .toList(growable: false);
  }

  Widget _buildCharacterTabBody(int tabIndex) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (tabIndex == 2) {
      return const EmptyStateView(
        icon: Icons.download_outlined,
        title: '暂无下载角色',
        subtitle: '从社区下载的角色将展示在这里',
      );
    }

    final filtered = _filteredForTab(tabIndex);
    if (_repo.loading && filtered.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.person_outline,
        title: '暂无角色',
        actionLabel: isLoggedIn ? '新建角色' : null,
        onAction: isLoggedIn
            ? () async {
                await context.push(AppRoutes.characterCreate);
                if (mounted) _load();
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        controller: tabIndex == _tabIndex ? _scrollController : null,
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingXl),
        children: [
          CharacterMasonryGrid(
            items: filtered,
            localCoverFor: (e) => _localCovers[e.id],
            screenplayCountFor: (e) =>
                _repo.countScreenplaysForCharacter(e.id),
            favoriteCountFor: (e) =>
                _favorites.contains(e.id) ? 1 : null,
            onTap: (entry) => context.push(
              AppRoutes.characterDetailPath(entry.id),
            ),
            onLongPress: (entry) => showCharacterActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: isLoggedIn,
              isFavorite: _favorites.contains(entry.id),
              onToggleFavorite: () async {
                final next = !_favorites.contains(entry.id);
                await CharacterLocalStore.instance.setFavorite(entry.id, next);
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
    final isLoggedIn = ref.watch(isLoggedInProvider);
    return AnimatedBuilder(
      animation: _repo,
      builder: (context, _) {
        return DesktopStackScaffold(
          title: const Text('我的角色'),
          onBack: () => popOrGoDiscovery(context),
          actions: [
            if (isLoggedIn)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await context.push(AppRoutes.characterCreate);
                  if (mounted) _load();
                },
              ),
          ],
          body: ColoredBox(
            color: AppColors.pageBackground,
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
                    tabs: AppCatalog.myCharacterTabs,
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
                      for (var i = 0;
                          i < AppCatalog.myCharacterTabs.length;
                          i++)
                        _buildCharacterTabBody(i),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
