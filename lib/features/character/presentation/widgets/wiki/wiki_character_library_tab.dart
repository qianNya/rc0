import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/data/app_catalog.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../../../shared/widgets/shell_insets.dart';
import '../../../../auth/data/auth_repository.dart';
import '../../../data/character_local_store.dart';
import '../../../data/character_repository.dart';
import '../../../domain/character_entry.dart';
import '../../../domain/character_utils.dart';
import '../character_action_sheet.dart';
import '../character_category_chips.dart';
import 'wiki_character_grid_card.dart';

/// Wiki Hub「角色」分段 — 双列角色库，对齐产品设计稿。
class WikiCharacterLibraryTab extends StatefulWidget {
  const WikiCharacterLibraryTab({super.key});

  @override
  State<WikiCharacterLibraryTab> createState() => _WikiCharacterLibraryTabState();
}

class _WikiCharacterLibraryTabState extends State<WikiCharacterLibraryTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _categoryIndex = 0;
  Set<int> _favorites = {};
  final Map<int, String> _localCovers = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 240) {
      return;
    }
    if (_repo.hasMore && !_repo.loadingMore) {
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
    final category = AppCatalog.wikiCharacterCategoryChips[_categoryIndex];
    return filterWikiCharactersByCategory(
      _repo.items,
      category,
      screenplayCountFor: _repo.countScreenplaysForCharacter,
    );
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

  void _showFilterHint() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('高级筛选即将上线')));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredItems;
    final loading = _repo.loading;
    final error = _repo.error;

    return ColoredBox(
      color: isDark
          ? AppColors.characterBackgroundDark
          : Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  AppDimensions.spacingSm,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingXs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.characterCardDark
                              : AppColors.surfaceSecondary,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                        child: AppSearchField(
                          hint: '搜索角色、标签、关键词',
                          controller: _searchController,
                          onSubmitted: (_) => _load(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: isDark
                          ? AppColors.characterCardDark
                          : AppColors.surfaceSecondary,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLg),
                      child: InkWell(
                        onTap: _showFilterHint,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.tune, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CharacterCategoryChips(
                chips: AppCatalog.wikiCharacterCategoryChips,
                selectedIndex: _categoryIndex,
                onChanged: (index) => setState(() => _categoryIndex = index),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Expanded(child: _buildGrid(context, filtered, loading, error)),
            ],
          ),
          Positioned(
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd,
            child: _WikiAiCharacterFab(
              onPressed: () => context.push(AppRoutes.characterAi),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<CharacterEntry> filtered,
    bool loading,
    String? error,
  ) {
    if (loading && _repo.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          EmptyStateView(
            icon: Icons.person_outline,
            title: error ?? '暂无角色',
            subtitle: error != null ? null : '创建或收藏第一个角色',
            actionLabel: _auth.isLoggedIn ? '新建角色' : 'AI 生成角色',
            onAction: _auth.isLoggedIn
                ? () async {
                    await context.push(AppRoutes.characterCreate);
                    if (mounted) _load();
                  }
                : () => context.push(AppRoutes.characterAi),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          0,
          AppDimensions.spacingMd,
          ShellInsets.scrollBottom(context, extra: AppDimensions.spacingXl * 3),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingSm,
          crossAxisSpacing: AppDimensions.spacingSm,
          childAspectRatio: 0.56,
        ),
        itemCount: filtered.length + (_repo.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filtered.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingMd),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final entry = filtered[index];
          final favorited = _favorites.contains(entry.id);
          return WikiCharacterGridCard(
            entry: entry,
            localCoverPath: _localCovers[entry.id],
            screenplayCount: _repo.countScreenplaysForCharacter(entry.id),
            likeCount: entry.sort > 0 ? entry.sort : (favorited ? 1 : null),
            favorited: favorited,
            onTap: () => context.push(AppRoutes.characterDetailPath(entry.id)),
            onLongPress: () => showCharacterActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: _auth.isLoggedIn,
              isFavorite: favorited,
              onToggleFavorite: () => _toggleFavorite(entry),
              onRefresh: _load,
            ),
          );
        },
      ),
    );
  }
}

class _WikiAiCharacterFab extends StatelessWidget {
  const _WikiAiCharacterFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: AppColors.accent.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.accent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text(
                'AI 角色',
                style: AppTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
