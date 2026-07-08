import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../profile/data/screenplay_favorite_repository.dart';
import '../../data/favorite_image_item.dart';
import '../../data/image_favorite_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _spFavorites = ScreenplayFavoriteRepository.instance;
  bool _loadingScreenplays = false;
  String? _spError;
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab.clamp(0, 1);
    _loadScreenplayFavorites();
  }

  Future<void> _loadScreenplayFavorites() async {
    setState(() {
      _loadingScreenplays = true;
      _spError = null;
    });
    final result = await _spFavorites.fetchFavorites();
    if (!mounted) return;
    setState(() {
      _spError = result.error;
      _loadingScreenplays = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final imageRepo = ImageFavoriteRepository.instance;

    return DesktopStackScaffold(
      title: const Text('我的收藏'),
      onBack: () => popOrGoDiscovery(context),
      centerTitle: false,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              FeedTabBar(
                tabs: const ['画格收藏', '剧本收藏'],
                selectedIndex: _tabIndex,
                onChanged: (index) => setState(() => _tabIndex = index),
                underlineStyle: true,
                embedded: true,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FadeSlideIndexedStack(
                  index: _tabIndex,
                  children: [
                    _FrameFavoritesTab(repo: imageRepo, isDesktop: isDesktop),
                    _ScreenplayFavoritesTab(
                      loading: _loadingScreenplays,
                      error: _spError,
                      items: _spFavorites.items,
                      screenplays: _spFavorites.screenplays,
                      onRefresh: _loadScreenplayFavorites,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _FrameFavoritesTab extends StatelessWidget {
  const _FrameFavoritesTab({
    required this.repo,
    required this.isDesktop,
  });

  final ImageFavoriteRepository repo;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final items = repo.items;
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => repo.load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
                EmptyStateView(
                  icon: Icons.favorite_border,
                  title: '暂无画格收藏',
                  subtitle: '在全屏预览中收藏喜欢的画格',
                  actionLabel: '去探索',
                  onAction: () => context.go(AppRoutes.discovery),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => repo.load(),
          child: FeedGridScope(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = FeedGridLayout.columnsForWidth(
                  constraints.maxWidth,
                );
                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: FeedGridLayout.padding(bottom: 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: FeedGridLayout.spacing,
                    crossAxisSpacing: FeedGridLayout.spacing,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _FavoriteImageTile(
                      item: items[index],
                      onTap: () => _openPreview(context, items, index),
                      onRemove: () => repo.remove(items[index].id),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openPreview(
    BuildContext context,
    List<FavoriteImageItem> items,
    int index,
  ) {
    final paths = items.map((e) => e.imagePath).toList();
    final captions = items.map((e) => e.caption ?? '').toList();
    final keys = items.map((e) => e.id).toList();

    showImagePreview(
      context,
      imagePaths: paths,
      initialIndex: index,
      captions: captions,
      options: ImagePreviewOptions(
        favoriteKeys: keys,
        sourceLabel: items[index].sourceLabel,
      ),
    );
  }
}

class _ScreenplayFavoritesTab extends StatelessWidget {
  const _ScreenplayFavoritesTab({
    required this.loading,
    required this.error,
    required this.items,
    required this.screenplays,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final List<FavoriteScreenplayRef> items;
  final Map<int, Screenplay> screenplays;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyStateView(
        icon: Icons.bookmark_border,
        title: '暂无剧本收藏',
        subtitle: error ?? '在社区中收藏喜欢的剧本',
        actionLabel: '去社区',
        onAction: () => context.go(AppRoutes.discoveryTemplate),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final fav = items[i];
          final spId = fav.screenplayId;
          final screenplay = screenplays[spId];
          final title = screenplay?.title.isNotEmpty == true
              ? screenplay!.title
              : '剧本 #$spId';
          return ListTile(
            tileColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: CircleAvatar(
              backgroundImage: screenplay?.coverUrl != null
                  ? NetworkImage(screenplay!.coverUrl!)
                  : null,
              child: screenplay?.coverUrl == null
                  ? const Icon(Icons.movie_outlined, size: 20)
                  : null,
            ),
            title: Text(title),
            subtitle: Text(fav.createdAt),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.script('$spId')),
          );
        },
      ),
    );
  }
}

class _FavoriteImageTile extends StatelessWidget {
  const _FavoriteImageTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
  });

  final FavoriteImageItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () async {
        final confirmed = await showGlassDialog<bool>(
          context,
          child: GlassDialog(
            title: const Text('取消收藏'),
            onClose: () => Navigator.pop(context, false),
            child: const Text('确定从收藏中移除这张画格吗？'),
            footer: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('移除'),
                  ),
                ],
              ),
            ),
          ),
        );
        if (confirmed == true) onRemove();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  child: _FavoriteThumb(path: item.imagePath),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXs),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (item.sourceLabel != null && item.sourceLabel!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.sourceLabel!,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (item.caption != null && item.caption!.isNotEmpty)
            Text(
              item.caption!,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _FavoriteThumb extends StatelessWidget {
  const _FavoriteThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (isNetworkImagePath(path)) {
      return Rc0Image(
        path: path,
        fit: BoxFit.cover,
        errorWidget: const ColoredBox(
          color: AppColors.placeholder,
          child: Icon(Icons.broken_image_outlined),
        ),
      );
    }

    return Rc0Image(
      path: path,
      fit: BoxFit.cover,
      errorWidget: const ColoredBox(
        color: AppColors.placeholder,
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
