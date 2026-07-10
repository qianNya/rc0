import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../../domain/character_utils.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/character_category_chips.dart';
import '../widgets/character_masonry_grid.dart';
import 'wiki/wiki_character_grid_card.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';

enum CharacterLibraryMode { wiki, discovery }

/// Shared character library body for Wiki and Discovery.
class CharacterLibraryBody extends ConsumerStatefulWidget {
  const CharacterLibraryBody({
    super.key,
    required this.mode,
    this.workId,
    this.embeddedInHub = false,
    this.keepAlive = false,
    this.showAiFab = false,
    this.externalChromeInset = false,
    this.lightTone = false,
  });

  final CharacterLibraryMode mode;
  final int? workId;
  final bool embeddedInHub;
  final bool keepAlive;
  final bool showAiFab;

  /// Parent scaffold already applied [wikiModeTagContentInsetHeight] padding.
  final bool externalChromeInset;

  /// Force light surfaces/text for wiki-style character library pages.
  final bool lightTone;

  @override
  ConsumerState<CharacterLibraryBody> createState() =>
      _CharacterLibraryBodyState();
}

class _CharacterLibraryBodyState extends ConsumerState<CharacterLibraryBody>
    with AutomaticKeepAliveClientMixin {
  final _repo = CharacterRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  int _categoryIndex = 0;
  Set<int> _favorites = {};
  final Map<int, String> _localCovers = {};

  @override
  bool get wantKeepAlive => widget.keepAlive;

  List<String> get _categoryChips => switch (widget.mode) {
        CharacterLibraryMode.wiki => AppCatalog.wikiCharacterCategoryChips,
        CharacterLibraryMode.discovery => AppCatalog.characterCategoryChips,
      };

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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 220) {
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
      workId: widget.mode == CharacterLibraryMode.discovery ? widget.workId : null,
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
    setState(() {
      _localCovers
        ..clear()
        ..addAll(covers);
    });
  }

  List<CharacterEntry> get _filteredItems {
    final category = _categoryChips[_categoryIndex];
    return switch (widget.mode) {
      CharacterLibraryMode.wiki => filterWikiCharactersByCategory(
          _repo.items,
          category,
          screenplayCountFor: _repo.countScreenplaysForCharacter,
        ),
      CharacterLibraryMode.discovery =>
        filterCharactersByCategory(_repo.items, category),
    };
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
    final text = widget.mode == CharacterLibraryMode.wiki
        ? '高级筛选即将上线'
        : '筛选功能即将上线';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _openAi() => context.push(AppRoutes.characterAi);

  double _topBarInset(BuildContext context) {
    if (widget.externalChromeInset) {
      return AppDimensions.spacingSm;
    }
    if (widget.embeddedInHub) {
      return wikiModeTagContentInsetHeight(context) + AppDimensions.spacingSm;
    }
    return AppDimensions.spacingSm;
  }

  Widget _buildTopBar() {
    final useLight = widget.lightTone || widget.mode == CharacterLibraryMode.wiki;
    final fieldFill =
        useLight ? AppColors.surfaceSecondary : AppColors.surfaceSecondary;

    if (widget.mode == CharacterLibraryMode.wiki) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          _topBarInset(context),
          AppDimensions.spacingMd,
          AppDimensions.spacingXs,
        ),
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fieldFill,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
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
              color: fieldFill,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: InkWell(
                onTap: _showFilterHint,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.tune, size: 22),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        _topBarInset(context),
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
            if (ref.watch(isLoggedInProvider))
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
              onPressed: _showFilterHint,
              icon: const Icon(Icons.tune),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (widget.mode == CharacterLibraryMode.wiki) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: _scrollBottomPadding(context)),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
          GlassEmptyState(
            icon: Icons.person_outline,
            title: _repo.error ?? '暂无角色',
            subtitle: _repo.error != null ? null : '创建或收藏第一个角色',
            actionLabel: ref.watch(isLoggedInProvider) ? '新建角色' : 'AI 生成角色',
            onAction: ref.watch(isLoggedInProvider)
                ? () async {
                    await context.push(AppRoutes.characterCreate);
                    if (mounted) _load();
                  }
                : _openAi,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
        GlassEmptyState(
          icon: Icons.person_outline,
          title: _repo.error ?? '暂无角色',
          subtitle: _repo.error != null ? null : '创建第一个角色',
          actionLabel: ref.watch(isLoggedInProvider) ? '新建角色' : null,
          onAction: ref.watch(isLoggedInProvider)
              ? () async {
                  await context.push(AppRoutes.characterCreate);
                  if (mounted) _load();
                }
              : null,
        ),
      ],
    );
  }

  double _floatingChipsBottom(BuildContext context) {
    return ShellInsets.of(context) + AppDimensions.spacingSm;
  }

  double _scrollBottomPadding(BuildContext context) {
    return ShellInsets.scrollBottom(
      context,
      extra: CharacterCategoryChips.chipBarHeight + AppDimensions.spacingMd,
    );
  }

  Widget _buildWikiShell(List<CharacterEntry> filtered, bool useLight) {
    final scrollBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(),
        Expanded(child: _buildContent(filtered)),
      ],
    );

    final painted = ColoredBox(
      color: widget.embeddedInHub
          ? Colors.transparent
          : AppColors.pageBackground,
      child: scrollBody,
    );

    final chips = Positioned(
      left: 0,
      right: 0,
      bottom: _floatingChipsBottom(context),
      child: CharacterCategoryChips(
        chips: _categoryChips,
        selectedIndex: _categoryIndex,
        onChanged: (index) => setState(() => _categoryIndex = index),
      ),
    );

    if (!widget.showAiFab) {
      return Stack(
        fit: StackFit.expand,
        children: [painted, chips],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        painted,
        chips,
        Positioned(
          right: AppDimensions.spacingMd,
          bottom: _floatingChipsBottom(context) +
              CharacterCategoryChips.chipBarHeight +
              AppDimensions.spacingSm,
          child: StudioEditorShellGlassButton(
            label: 'AI 角色',
            icon: Icons.auto_awesome,
            minWidth: 120,
            onPressed: _openAi,
          ),
        ),
      ],
    );
  }

  Widget _buildWikiGrid(List<CharacterEntry> filtered) {
    return RefreshIndicator(
      onRefresh: _load,
      child: FeedGridScope(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = FeedGridLayout.columnsForWidth(constraints.maxWidth);
            return GridView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                0,
                AppDimensions.spacingMd,
                _scrollBottomPadding(context),
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
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
                  onTap: () =>
                      context.push(AppRoutes.characterDetailPath(entry.id)),
                  onLongPress: () => showCharacterActionSheet(
                    context: context,
                    entry: entry,
                    repo: _repo,
                    isLoggedIn: ref.watch(isLoggedInProvider),
                    isFavorite: favorited,
                    onToggleFavorite: () => _toggleFavorite(entry),
                    onRefresh: _load,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscoveryList(List<CharacterEntry> filtered) {
    return RefreshIndicator(
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
            screenplayCountFor: (e) => _repo.countScreenplaysForCharacter(e.id),
            favoriteCountFor: (e) => _favorites.contains(e.id) ? 1 : null,
            onTap: (entry) => context.push(AppRoutes.characterDetailPath(entry.id)),
            onLongPress: (entry) => showCharacterActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: ref.watch(isLoggedInProvider),
              isFavorite: _favorites.contains(entry.id),
              onToggleFavorite: () => _toggleFavorite(entry),
              onRefresh: _load,
            ),
          ),
          if (_repo.loadingMore)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingMd),
              child: FeedGridSkeleton(tileCount: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(List<CharacterEntry> filtered) {
    if (_repo.loading && _repo.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: FeedGridSkeleton(tileCount: 6),
      );
    }
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }
    return switch (widget.mode) {
      CharacterLibraryMode.wiki => _buildWikiGrid(filtered),
      CharacterLibraryMode.discovery => _buildDiscoveryList(filtered),
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtered = _filteredItems;
    final useLight = widget.lightTone || widget.mode == CharacterLibraryMode.wiki;

    if (widget.mode == CharacterLibraryMode.wiki) {
      return _buildWikiShell(filtered, useLight);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTopBar(),
        CharacterCategoryChips(
          chips: _categoryChips,
          selectedIndex: _categoryIndex,
          onChanged: (index) => setState(() => _categoryIndex = index),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(child: _buildContent(filtered)),
      ],
    );

    final body = ColoredBox(
      color: widget.embeddedInHub
          ? Colors.transparent
          : AppColors.pageBackground,
      child: content,
    );

    if (!widget.showAiFab) return body;

    return Stack(
      fit: StackFit.expand,
      children: [
        body,
        Positioned(
          right: AppDimensions.spacingMd,
          bottom: AppDimensions.spacingMd,
          child: StudioEditorShellGlassButton(
            label: 'AI 角色',
            icon: Icons.auto_awesome,
            minWidth: 120,
            onPressed: _openAi,
          ),
        ),
      ],
    );
  }
}
