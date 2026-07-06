import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';

Future<void> showSceneActionSheet({
  required BuildContext context,
  required SceneEntry entry,
  required SceneRepository repo,
  required bool isLoggedIn,
  required bool isFavorite,
  required VoidCallback onRefresh,
  Future<void> Function()? onToggleFavorite,
}) async {
  await showGlassSheet<void>(
    context,
    padding: kGlassSheetMenuPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          title: Text(isFavorite ? '取消收藏' : '收藏场景'),
          onTap: () async {
            Navigator.pop(context);
            await onToggleFavorite?.call();
            onRefresh();
          },
        ),
        if (isLoggedIn && !entry.isSeed) ...[
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑场景'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.sceneEditPath(entry.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              '删除场景',
              style: AppTextStyles.body.copyWith(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showGlassDialog<bool>(
                context,
                child: GlassDialog(
                  title: const Text('删除场景'),
                  onClose: () => Navigator.pop(context, false),
                  child: Text('确定删除「${entry.title}」？'),
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
                          child: const Text('删除'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (confirmed != true || !context.mounted) return;
              final error = await repo.delete(entry.id);
              if (!context.mounted) return;
              if (error != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(error)));
              } else {
                onRefresh();
              }
            },
          ),
        ],
        ListTile(
          leading: const Icon(Icons.movie_outlined),
          title: const Text('关联剧本'),
          onTap: () {
            Navigator.pop(context);
            context.push(AppRoutes.sceneDetailPath(entry.id));
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('关联角色'),
          onTap: () {
            Navigator.pop(context);
            context.push(AppRoutes.labsFeature('image_character_link'));
          },
        ),
      ],
    ),
  );
}
