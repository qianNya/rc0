import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../../domain/character_utils.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/character_masonry_grid.dart';

class MyCharactersPage extends StatefulWidget {
  const MyCharactersPage({super.key});

  @override
  State<MyCharactersPage> createState() => _MyCharactersPageState();
}

class _MyCharactersPageState extends State<MyCharactersPage> {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
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

  List<CharacterEntry> get _filtered {
    if (_tabIndex == 2) return const [];
    return _repo.items
        .where(
          (e) => matchesMyCharacterTab(
            e,
            _tabIndex,
            ownedIds: _ownedIds,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return AnimatedBuilder(
      animation: Listenable.merge([_repo, _auth]),
      builder: (context, _) {
        return DesktopStackScaffold(
          title: const Text('我的角色'),
          onBack: () => popOrGoDiscovery(context),
          actions: [
            if (_auth.isLoggedIn)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await context.push(AppRoutes.characterCreate);
                  if (mounted) _load();
                },
              ),
          ],
          body: ColoredBox(
            color: isDark
                ? AppColors.characterBackgroundDark
                : Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  child: SegmentedButton<int>(
                    segments: [
                      for (var i = 0; i < AppCatalog.myCharacterTabs.length; i++)
                        ButtonSegment(
                          value: i,
                          label: Text(AppCatalog.myCharacterTabs[i]),
                        ),
                    ],
                    selected: {_tabIndex},
                    onSelectionChanged: (value) {
                      setState(() => _tabIndex = value.first);
                    },
                  ),
                ),
                Expanded(
                  child: _tabIndex == 2
                      ? const EmptyStateView(
                          icon: Icons.download_outlined,
                          title: '暂无下载角色',
                          subtitle: '从社区下载的角色将展示在这里',
                        )
                      : _repo.loading && filtered.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : filtered.isEmpty
                              ? EmptyStateView(
                                  icon: Icons.person_outline,
                                  title: '暂无角色',
                                  actionLabel:
                                      _auth.isLoggedIn ? '新建角色' : null,
                                  onAction: _auth.isLoggedIn
                                      ? () async {
                                          await context
                                              .push(AppRoutes.characterCreate);
                                          if (mounted) _load();
                                        }
                                      : null,
                                )
                              : RefreshIndicator(
                                  onRefresh: _load,
                                  child: ListView(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.only(
                                      bottom: AppDimensions.spacingXl,
                                    ),
                                    children: [
                                      CharacterMasonryGrid(
                                        items: filtered,
                                        localCoverFor: (e) =>
                                            _localCovers[e.id],
                                        screenplayCountFor: (e) => _repo
                                            .countScreenplaysForCharacter(e.id),
                                        favoriteCountFor: (e) =>
                                            _favorites.contains(e.id)
                                                ? 1
                                                : null,
                                        onTap: (entry) => context.push(
                                          AppRoutes.characterDetailPath(
                                            entry.id,
                                          ),
                                        ),
                                        onLongPress: (entry) =>
                                            showCharacterActionSheet(
                                          context: context,
                                          entry: entry,
                                          repo: _repo,
                                          isLoggedIn: _auth.isLoggedIn,
                                          isFavorite:
                                              _favorites.contains(entry.id),
                                          onToggleFavorite: () async {
                                            final next = !_favorites
                                                .contains(entry.id);
                                            await CharacterLocalStore.instance
                                                .setFavorite(entry.id, next);
                                            await _load();
                                          },
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
      },
    );
  }
}
