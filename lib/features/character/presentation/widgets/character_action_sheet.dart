import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../domain/character_entry.dart';
import '../../data/character_repository.dart';

Future<void> showCharacterActionSheet({
  required BuildContext context,
  required CharacterEntry entry,
  required CharacterRepository repo,
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
          title: Text(isFavorite ? '取消收藏' : '收藏角色'),
          onTap: () async {
            Navigator.pop(context);
            await onToggleFavorite?.call();
            onRefresh();
          },
        ),
        if (isLoggedIn) ...[
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑角色'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.characterEditPath(entry.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.link_outlined),
            title: const Text('关联剧本'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.characterEditPath(entry.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('生成剧本'),
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.comingSoon('AI 生成剧本'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              '删除角色',
              style: AppTextStyles.body.copyWith(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('删除角色'),
                  content: Text('确定删除「${entry.name}」？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('删除'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final error = await repo.delete(entry.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(error ?? '已删除'),
                      ),
                    );
                }
                onRefresh();
              }
            },
          ),
        ],
      ],
    ),
  );
}
