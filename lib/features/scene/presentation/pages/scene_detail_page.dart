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
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/scene_local_store.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import '../../domain/scene_utils.dart';
import '../widgets/scene_detail_tabs.dart';
import '../widgets/scene_action_sheet.dart';

class SceneDetailPage extends StatefulWidget {
  const SceneDetailPage({super.key, required this.sceneId});

  final String sceneId;

  @override
  State<SceneDetailPage> createState() => _SceneDetailPageState();
}

class _SceneDetailPageState extends State<SceneDetailPage> {
  final _repo = SceneRepository.instance;
  final _auth = AuthRepository.instance;
  bool _loading = true;
  SceneEntry? _entry;
  bool _favorite = false;
  String? _localCover;
  List<String> _referenceUrls = const [];
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _repo.fetchDetail(widget.sceneId);
    final entry = result.scene;
    final favorite = await SceneLocalStore.instance.isFavorite(widget.sceneId);
    final localCover =
        await SceneLocalStore.instance.localCoverPath(widget.sceneId);
    final refs =
        await SceneLocalStore.instance.referenceImageUrls(widget.sceneId);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _favorite = favorite;
      _localCover = localCover;
      _referenceUrls = refs;
      _loading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final next = !_favorite;
    await SceneLocalStore.instance.setFavorite(widget.sceneId, next);
    if (!mounted) return;
    setState(() => _favorite = next);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(next ? '已收藏' : '已取消收藏')));
  }

  Future<void> _addToMyScenes() async {
    await SceneLocalStore.instance.setFavorite(widget.sceneId, true);
    await SceneLocalStore.instance.markOwned(widget.sceneId);
    if (!mounted) return;
    setState(() => _favorite = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已加入我的场景')));
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverPath = (_localCover != null && _localCover!.isNotEmpty)
        ? _localCover!
        : entry?.coverUrl ?? '';

    return DesktopStackScaffold(
      title: Text(entry?.title.isNotEmpty == true ? entry!.title : '场景详情'),
      onBack: () => popOrGoDiscovery(context),
      actions: [
        if (_auth.isLoggedIn && entry != null && !entry.isSeed)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await context.push(AppRoutes.sceneEditPath(entry.id));
              if (mounted) _load();
            },
          ),
        if (entry != null)
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => showSceneActionSheet(
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
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(
                        AppRoutes.lightingWithContext(sceneId: entry.id),
                      ),
                      icon: const Icon(Icons.wb_incandescent_outlined),
                      label: const Text('匹配灯光氛围'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                            _favorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          label: Text(_favorite ? '已收藏' : '收藏'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _addToMyScenes,
                          child: const Text('加入我的场景'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
            ),
      floatingActionButton: entry == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: PrimaryButton(
                label: '开始创作',
                onPressed: () => context.push(AppRoutes.studioCreate),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    const EmptyStateView(
                      icon: Icons.landscape_outlined,
                      title: '场景不存在',
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _SceneHero(entry: entry, coverPath: coverPath),
                    ),
                    SliverToBoxAdapter(
                      child: _SceneStatsRow(
                        favoriteCount: entry.favoriteCount + (_favorite ? 1 : 0),
                        useCount: entry.useCount,
                        rating: entry.rating,
                        screenplayCount:
                            _repo.countScreenplaysForScene(entry.id),
                      ),
                    ),
                    SliverToBoxAdapter(child: _SceneDescription(entry: entry)),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: PinnedFeedTabBarDelegate(
                        tabs: AppCatalog.sceneDetailTabs,
                        selectedIndex: _tabIndex,
                        onChanged: (index) => setState(() => _tabIndex = index),
                        backgroundColor: isDark
                            ? AppColors.characterBackgroundDark
                            : Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    SliverFillRemaining(
                      child: FadeSlideIndexedStack(
                        index: _tabIndex,
                        children: [
                          SceneInspirationTab(
                            entry: entry,
                            localCover: _localCover,
                            referenceUrls: _referenceUrls,
                          ),
                          SceneShootingTipsTab(entry: entry),
                          SceneRelatedTab(sceneId: entry.id),
                          const SceneWorksTab(),
                          SceneScriptsTab(sceneId: entry.id),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SceneHero extends StatelessWidget {
  const _SceneHero({required this.entry, required this.coverPath});

  final SceneEntry entry;
  final String coverPath;

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
                  entry.title,
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                if (entry.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.location,
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SceneStatsRow extends StatelessWidget {
  const _SceneStatsRow({
    required this.favoriteCount,
    required this.useCount,
    required this.rating,
    required this.screenplayCount,
  });

  final int favoriteCount;
  final int useCount;
  final double rating;
  final int screenplayCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: '收藏', value: formatSceneCount(favoriteCount)),
          _StatItem(label: '使用', value: formatSceneCount(useCount)),
          _StatItem(
            label: '推荐率',
            value: rating > 0 ? '${(rating * 100).toInt()}%' : '—',
          ),
          _StatItem(label: '剧本', value: '$screenplayCount'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.label.copyWith(fontSize: 16)),
        Text(label, style: AppTextStyles.bodySecondary.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _SceneDescription extends StatelessWidget {
  const _SceneDescription({required this.entry});

  final SceneEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.description.isNotEmpty)
            Text(entry.description, style: AppTextStyles.body),
          if (entry.themes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final theme in entry.themes)
                  Chip(label: Text(theme), visualDensity: VisualDensity.compact),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
