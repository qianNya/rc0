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
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/character_local_store.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';
import '../widgets/character_action_sheet.dart';
import '../widgets/detail/character_info_tab.dart';
import '../widgets/detail/character_scripts_tab.dart';

class CharacterDetailPage extends StatefulWidget {
  const CharacterDetailPage({super.key, required this.characterId});

  final int characterId;

  @override
  State<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends State<CharacterDetailPage>
    with SingleTickerProviderStateMixin {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
  bool _loading = true;
  String? _error;
  CharacterEntry? _entry;
  bool _favorite = false;
  String? _localCover;
  int _refImageCount = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AppCatalog.characterDetailTabs.length,
      vsync: this,
    );
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _repo.fetchDetail(widget.characterId);
    final favorite = await CharacterLocalStore.instance
        .isFavorite(widget.characterId);
    final localCover =
        await CharacterLocalStore.instance.localCoverPath(widget.characterId);
    final refs = await CharacterLocalStore.instance
        .referenceImageUrls(widget.characterId);
    if (!mounted) return;
    setState(() {
      _entry = result.character;
      _error = result.error;
      _favorite = favorite;
      _localCover = localCover;
      _refImageCount = refs.isEmpty ? (result.character?.coverUrl.isNotEmpty == true ? 1 : 0) : refs.length;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final next = !_favorite;
    await CharacterLocalStore.instance.setFavorite(widget.characterId, next);
    if (!mounted) return;
    setState(() => _favorite = next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(next ? '已收藏' : '已取消收藏')));
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverPath = (_localCover != null && _localCover!.isNotEmpty)
        ? _localCover!
        : entry?.effectiveCoverUrl ?? '';

    return DesktopStackScaffold(
      title: Text(entry?.name.isNotEmpty == true ? entry!.name : '角色详情'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        if (_auth.isLoggedIn && entry != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await context.push(AppRoutes.characterEditPath(entry.id));
              if (mounted) _load();
            },
          ),
        if (entry != null)
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => showCharacterActionSheet(
              context: context,
              entry: entry,
              repo: _repo,
              isLoggedIn: _auth.isLoggedIn,
              isFavorite: _favorite,
              onToggleFavorite: _toggleFavorite,
              onRefresh: _load,
            ),
          ),
      ],
      bottomNavigationBar: entry == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: PrimaryButton(
                  label: '开始创作',
                  onPressed: () => context.push(AppRoutes.studioCreate),
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    EmptyStateView(
                      icon: Icons.person_outline,
                      title: _error ?? '角色不存在',
                      subtitle: _error,
                      actionLabel: _error != null ? '重试' : null,
                      onAction: _error != null ? _load : null,
                    ),
                  ],
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerScrolled) => [
                    SliverToBoxAdapter(
                      child: _CharacterHero(
                        entry: entry,
                        coverPath: coverPath,
                        isFavorite: _favorite,
                        onFavorite: _toggleFavorite,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _CharacterStatsRow(
                        screenplayCount:
                            _repo.countScreenplaysForCharacter(entry.id),
                        refImageCount: _refImageCount,
                        favoriteLabel: _favorite ? '1' : '—',
                        viewLabel: '—',
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelColor: AppColors.accent,
                          unselectedLabelColor: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          indicatorColor: AppColors.accent,
                          tabs: [
                            for (final tab in AppCatalog.characterDetailTabs)
                              Tab(text: tab),
                          ],
                        ),
                        isDark: isDark,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      CharacterScriptsTab(characterId: entry.id),
                      const CharacterPlaceholderTab(
                        title: '姿势库即将上线',
                        subtitle: '关联动作库后可在此浏览参考姿势',
                      ),
                      const CharacterPlaceholderTab(
                        title: '暂无摄影作品',
                        subtitle: '用户围绕该角色创作的作品将展示在这里',
                      ),
                      const CharacterPlaceholderTab(
                        title: '服装参考即将上线',
                        subtitle: '角色服装参考与购买链接将在此展示',
                      ),
                      CharacterInfoTab(entry: entry),
                    ],
                  ),
                ),
    );
  }
}

class _CharacterHero extends StatelessWidget {
  const _CharacterHero({
    required this.entry,
    required this.coverPath,
    required this.isFavorite,
    required this.onFavorite,
  });

  final CharacterEntry entry;
  final String coverPath;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverPath.isNotEmpty)
            Rc0Image(path: coverPath, fit: BoxFit.cover)
          else
            const PlaceholderImage(aspectRatio: 16 / 9, borderRadius: 0),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.scrim,
                  AppColors.characterBackgroundDark,
                ],
              ),
            ),
          ),
          Positioned(
            left: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
            bottom: AppDimensions.spacingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in entry.displayTags.take(5))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.glassSurfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorderDark),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onFavorite,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(isFavorite ? '已收藏' : '收藏'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterStatsRow extends StatelessWidget {
  const _CharacterStatsRow({
    required this.screenplayCount,
    required this.refImageCount,
    required this.favoriteLabel,
    required this.viewLabel,
  });

  final int screenplayCount;
  final int refImageCount;
  final String favoriteLabel;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.characterCardDark : AppColors.surfaceSecondary;

    Widget cell(String value, String label) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(
        children: [
          cell('$screenplayCount', '剧本'),
          const SizedBox(width: 8),
          cell('$refImageCount', '参考图'),
          const SizedBox(width: 8),
          cell(favoriteLabel, '收藏'),
          const SizedBox(width: 8),
          cell(viewLabel, '浏览'),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, {required this.isDark});

  final TabBar tabBar;
  final bool isDark;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: isDark
          ? AppColors.characterBackgroundDark
          : Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar || oldDelegate.isDark != isDark;
}
