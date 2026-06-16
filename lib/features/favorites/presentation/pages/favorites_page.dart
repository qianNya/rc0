import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../data/favorite_image_item.dart';
import '../../data/image_favorite_repository.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);
    final repo = ImageFavoriteRepository.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: '我的收藏'),
              const SizedBox(height: 16),
              Expanded(
                child: ListenableBuilder(
                  listenable: repo,
                  builder: (context, _) {
                    final items = repo.items;
                    if (items.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.favorite_border,
                        title: '暂无收藏',
                        subtitle: '在全屏预览中收藏喜欢的画格',
                        actionLabel: '去探索',
                        onAction: () => context.go(AppRoutes.explore),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 5 : 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
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
            ],
          ),
        ),
      ),
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
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('取消收藏'),
            content: const Text('确定从收藏中移除这张画格吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('移除'),
              ),
            ],
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
                        padding: EdgeInsets.all(4),
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
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.placeholder,
          child: Icon(Icons.broken_image_outlined),
        ),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.placeholder,
        child: Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
