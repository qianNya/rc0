import 'dart:io';

import '../../../core/domain/screenplay/screenplay_image_resolver.dart';
import '../../auth/data/auth_repository.dart';
import 'data_upload_repository.dart';
import 'screenplay_local_repository.dart';
import 'screenplay_publish_service.dart';
import 'screenplay_tree_document.dart';

class ScreenplayImageUploadService {
  ScreenplayImageUploadService._();

  static final ScreenplayImageUploadService instance =
      ScreenplayImageUploadService._();

  Future<({ScreenplayTreeDocument? document, String? error})> uploadFrameImage({
    required ScreenplayTreeDocument document,
    required int actIdx,
    required int sceneIdx,
    required int frameIdx,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (document: null, error: '请先登录');
    }

    final tree = deepCopyJson(document.tree);
    final frameMap = _frameMapAt(tree, actIdx, sceneIdx, frameIdx);
    if (frameMap == null) {
      return (document: null, error: '画格不存在');
    }

    final localPath = ScreenplayImageResolver.frameLocalPath(frameMap);
    final uploadSrc = ScreenplayImageResolver.localUploadPath(localPath);
    if (uploadSrc == null) {
      return (document: null, error: '本地图片不存在');
    }

    final uploaded =
        await DataUploadRepository.instance.uploadImage(File(uploadSrc));
    if (uploaded.error != null || uploaded.object == null) {
      return (document: null, error: uploaded.error ?? '上传失败');
    }

    frameMap['acgn_image_id'] = uploaded.object!.imageId;
    if (uploaded.object!.displayUrl.isNotEmpty) {
      frameMap['image_url'] = uploaded.object!.displayUrl;
    }
    if (uploaded.object!.thumbUrl.isNotEmpty) {
      frameMap['thumbnail_url'] = uploaded.object!.thumbUrl;
    }
    if (uploaded.object!.displayFileId != null) {
      frameMap['acgn_image_file_id'] = uploaded.object!.displayFileId;
    }

    return _persistAndMaybeSync(
      ScreenplayTreeDocument(tree: tree, meta: document.meta),
    );
  }

  Future<({ScreenplayTreeDocument? document, String? error})> uploadCoverImage({
    required ScreenplayTreeDocument document,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (document: null, error: '请先登录');
    }

    final tree = deepCopyJson(document.tree);
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final localPath = screenplayMap['local_cover_path'] as String?;
    final uploadSrc = ScreenplayImageResolver.localUploadPath(localPath);
    if (uploadSrc == null) {
      return (document: null, error: '本地封面不存在');
    }

    final remoteId = document.meta.remoteScreenplayId;
    if (remoteId != null) {
      final uploaded = await DataUploadRepository.instance.uploadScreenplayCover(
        remoteId,
        File(uploadSrc),
      );
      if (uploaded.error != null || uploaded.coverUrl == null) {
        return (document: null, error: uploaded.error ?? '上传失败');
      }
      screenplayMap['cover_url'] = uploaded.coverUrl;
    }

    return _persistAndMaybeSync(
      ScreenplayTreeDocument(tree: tree, meta: document.meta),
    );
  }

  Future<({ScreenplayTreeDocument? document, String? error})> _persistAndMaybeSync(
    ScreenplayTreeDocument document,
  ) async {
    final saved = await ScreenplayLocalRepository.instance.updateDocument(document);
    if (saved.error != null || saved.document == null) {
      return (document: null, error: saved.error ?? '保存失败');
    }

    var result = saved.document!;
    final remoteId = result.meta.remoteScreenplayId;
    if (remoteId == null) {
      return (document: result, error: null);
    }

    final sync = await ScreenplayPublishService.instance.syncToServer(
      document: result,
    );
    if (sync.error != null) {
      return (
        document: result,
        error: '图片已上传，同步失败：${sync.error}',
      );
    }

    await ScreenplayLocalRepository.instance.updateDocument(
      sync.result!.document,
    );
    return (document: sync.result!.document, error: null);
  }

  Map<String, dynamic>? _frameMapAt(
    Map<String, dynamic> tree,
    int actIdx,
    int sceneIdx,
    int frameIdx,
  ) {
    final acts = tree['acts'] as List<dynamic>? ?? [];
    if (actIdx < 0 || actIdx >= acts.length) return null;
    final scenes =
        (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
            [];
    if (sceneIdx < 0 || sceneIdx >= scenes.length) return null;
    final frames = (scenes[sceneIdx] as Map<String, dynamic>)['frames']
            as List<dynamic>? ??
        [];
    if (frameIdx < 0 || frameIdx >= frames.length) return null;
    return frames[frameIdx] as Map<String, dynamic>;
  }
}
