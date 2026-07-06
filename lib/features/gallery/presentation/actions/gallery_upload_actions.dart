import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../upload/data/image_pick_service.dart';
import '../../data/image_gallery_repository.dart';
import '../../data/image_tags_repository.dart';
import '../../data/media_vault_repository.dart';

/// Picks images and uploads them to the user gallery (restored from MyGalleryPage).
Future<void> pickAndUploadGalleryImages(
  BuildContext context, {
  required ValueChanged<bool> onUploadingChanged,
  required void Function(String message) showSnack,
}) async {
  final auth = AuthRepository.instance;
  if (!auth.isLoggedIn) {
    context.go(AppRoutes.loginWithRedirect(AppRoutes.gallery));
    return;
  }

  final picker = ImagePickService();
  final gallery = ImageGalleryRepository.instance;

  final picked = await picker.pickImages();
  if (!context.mounted || picked.added.isEmpty) return;

  onUploadingChanged(true);
  var success = 0;
  String? lastError;

  for (final file in picked.added) {
    final result = await gallery.uploadStandalone(File(file.path));
    if (result.error != null) {
      lastError = result.error;
    } else {
      success += 1;
    }
  }

  if (!context.mounted) return;
  onUploadingChanged(false);

  if (success > 0) {
    await Future.wait([
      MediaVaultRepository.instance.refresh(),
      ImageTagsRepository.instance.loadTags(),
    ]);
    if (context.mounted) {
      showSnack('已上传 $success 张图片');
    }
  } else if (context.mounted) {
    showSnack(lastError ?? '上传失败');
  }
}
