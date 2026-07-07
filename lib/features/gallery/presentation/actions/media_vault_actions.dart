import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/glass/glass_dialog.dart';
import '../../../../shared/widgets/glass/glass_text_field.dart';
import '../../data/media_vault_repository.dart';
import '../../domain/media_vault_image.dart';

/// Create a new media vault album.
Future<String?> showCreateMediaVaultAlbumDialog(BuildContext context) async {
  final controller = TextEditingController();
  final name = await showGlassDialog<String>(
    context,
    child: GlassDialog(
      title: const Text('新建专辑'),
      onClose: () => Navigator.pop(context),
      child: GlassTextField(
        controller: controller,
        hintText: '专辑名称，例如：人像精选',
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
        },
      ),
      footer: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) return;
                Navigator.pop(context, trimmed);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    ),
  );
  controller.dispose();
  if (name == null || name.trim().isEmpty) return null;
  return MediaVaultRepository.instance.createAlbum(name.trim());
}

/// Pick an album and add [image] to it.
Future<String?> showAddImageToAlbumSheet(
  BuildContext context,
  MediaVaultImage image,
) async {
  final repo = MediaVaultRepository.instance;
  final albums = repo.albums;
  if (albums.isEmpty) {
    return '请先创建专辑';
  }

  final album = await showModalBottomSheet<MediaAlbum>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            clipBehavior: Clip.antiAlias,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '添加到专辑',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                for (final item in albums)
                  ListTile(
                    leading: const Icon(Icons.photo_album_outlined),
                    title: Text(item.name),
                    subtitle: Text('${item.imageCount} 张'),
                    onTap: () => Navigator.pop(context, item),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (album == null) return null;
  return repo.addImageToAlbum(albumId: album.id, imageId: image.id);
}

Future<bool> confirmDeleteMediaVaultAlbum(
  BuildContext context,
  MediaAlbum album,
) async {
  return await showGlassDialog<bool>(
        context,
        child: GlassDialog(
          title: const Text('删除专辑'),
          onClose: () => Navigator.pop(context, false),
          child: Text('确定删除「${album.name}」？专辑内图片不会被删除。'),
          footer: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
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
      ) ??
      false;
}

Future<bool> confirmMoveImageToTrash(BuildContext context) async {
  return await showGlassDialog<bool>(
        context,
        child: GlassDialog(
          title: const Text('移入回收站'),
          onClose: () => Navigator.pop(context, false),
          child: const Text('图片将移入回收站，可在 30 天内恢复。'),
          footer: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('移入'),
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

Future<bool> confirmPermanentlyDeleteImage(BuildContext context) async {
  return await showGlassDialog<bool>(
        context,
        child: GlassDialog(
          title: const Text('永久删除'),
          onClose: () => Navigator.pop(context, false),
          child: const Text('图片将被永久删除且无法恢复，确定继续？'),
          footer: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('永久删除'),
                ),
              ],
            ),
          ),
        ),
      ) ??
      false;
}

Future<void> showTrashImageActions(
  BuildContext context,
  MediaVaultImage image,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.restore_outlined),
            title: const Text('恢复'),
            onTap: () => Navigator.pop(context, 'restore'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('永久删除'),
            onTap: () => Navigator.pop(context, 'purge'),
          ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;

  if (action == 'restore') {
    final error = await MediaVaultRepository.instance.restoreFromTrash(image.id);
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
    return;
  }

  if (action == 'purge') {
    final confirmed = await confirmPermanentlyDeleteImage(context);
    if (!context.mounted || !confirmed) return;
    final error =
        await MediaVaultRepository.instance.permanentlyDelete(image.id);
    if (context.mounted && error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
