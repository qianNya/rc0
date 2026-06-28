import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../../domain/character_utils.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/character_category_chips.dart';
import '../widgets/character_masonry_grid.dart';

class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key, this.workId, this.embeddedInHub = false});

  final int? workId;
  final bool embeddedInHub;

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _categoryIndex = 0;
  Set<int> _favorites = {};
  final Map<int, String> _localCovers = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _repo.loadMore();
    }
  }

  Future<void> _loadFavorites() async {
    final ids = await CharacterLocalStore.instance.favoriteIds();
    if (!mounted) return;
    setState(() => _favorites = ids);
  }

  Future<void> _load() async {
    await _repo.loadFirstPage(
      workId: widget.workId,
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
    await _loadLocalCovers();
  }

  Future<void> _loadLocalCovers() async {
    final covers = <int, String>{};
    for (final entry in _repo.items) {
      final path = await CharacterLocalStore.instance.localCoverPath(entry.id);
      if (path != null && path.isNotEmpty) {
        covers[entry.id] = path;
      }
    }
    if (!mounted) return;
    setState(() => _localCovers
      ..clear()
      ..addAll(covers));
  }

  List<CharacterEntry> get _filteredItems {
    final category = AppCatalog.characterCategoryChips[_categoryIndex];
    return filterCharactersByCategory(_repo.items, category);
  }

  Future<void> _toggleFavorite(CharacterEntry entry) async {
    final next = !_favorites.contains(entry.id);
    await CharacterLocalStore.instance.setFavorite(entry.id, next);
    await _loadFavorites();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(next ? '已收藏' : '已取消收藏')));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_repo, _auth]),
      builder: (context, _) {
        final filtered = _filteredItems;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final body = _buildBody(context, filtered, isDark);

        if (widget.embeddedInHub) {
          return ColoredBox(
            color: isDark
                ? AppColors.characterBackgroundDark
                : Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                body,
                Positioned(
                  right: AppDimensions.spacingMd,
                  bottom: AppDimensions.spacingMd,
                  child: StudioEditorShellGlassButton(
                    label: 'AI 角色',
                    icon: Icons.auto_awesome,
                    minWidth: 120,
                    onPressed: () => context.push(AppRoutes.characterAi),
                  ),
                ),
              ],
            ),
          );
        }

        return DesktopStackScaffold(
          title: Text(widget.workId != null ? 'IP 角色' : '角色库'),
          onBack: () => popOrGoDiscovery(context),
          actions: [
            IconButton(
              tooltip: '我的角色',
              icon: const Icon(Icons.folder_outlined),
              onPressed: () => context.push(AppRoutes.myCharacters),
            ),
            if (_auth.isLoggedIn)
              IconButton(
                tooltip: '新建角色',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await context.push(AppRoutes.characterCreate);
                  if (mounted) _load();
                },
              ),
          ],
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StudioEditorShellGlassButton(
              label: 'AI 角色',
              icon: Icons.auto_awesome,
              minWidth: 120,
              onPressed: () => context.push(AppRoutes.characterAi),
            ),
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<CharacterEntry> filtered,
    bool isDark,
  ) {
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
                    hint: '搜索角色名称、标签、关键词',
                    controller: _searchController,
                    onSubmitted: (_) => _load(),
                  ),
                ),
              ),
              if (widget.embeddedInHub) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: '我的角色',
                  onPressed: () => context.push(AppRoutes.myCharacters),
                  icon: const Icon(Icons.folder_outlined),
                ),
                if (_auth.isLoggedIn)
                  IconButton(
                    tooltip: '新建角色',
                    onPressed: () async {
                      await context.push(AppRoutes.characterCreate);
                      if (mounted) _load();
                    },
                    icon: const Icon(Icons.add),
                  ),
              ] else ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: '筛选',
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(content: Text('筛选功能即将上线')),
                      );
                  },
                  icon: const Icon(Icons.tune),
                ),
              ],
            ],
          ),
        ),
        CharacterCategoryChips(
          chips: AppCatalog.characterCategoryChips,
          selectedIndex: _categoryIndex,
          onChanged: (index) => setState(() => _categoryIndex = index),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(
          child: _repo.loading && _repo.items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                        ),
                        EmptyStateView(
                          icon: Icons.person_outline,
                          title: _repo.error ?? '暂无角色',
                          subtitle: _repo.error != null ? null : '创建第一个角色',
                          actionLabel: _auth.isLoggedIn ? '新建角色' : null,
                          onAction: _auth.isLoggedIn
                              ? () async {
                                  await context.push(AppRoutes.characterCreate);
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
                        padding: EdgeInsets.only(
                          bottom: widget.embeddedInHub
                              ? AppDimensions.spacingXl * 3
                              : AppDimensions.spacingXl * 2,
                        ),
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
                              isLoggedIn: _auth.isLoggedIn,
                              isFavorite: _favorites.contains(entry.id),
                              onToggleFavorite: () => _toggleFavorite(entry),
                              onRefresh: _load,
                            ),
                          ),
                          if (_repo.loadingMore)
                            const Padding(
                              padding:
                                  EdgeInsets.all(AppDimensions.spacingMd),
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
}
