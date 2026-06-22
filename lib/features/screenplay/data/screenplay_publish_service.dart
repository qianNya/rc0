import 'dart:async';
import 'dart:io';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../auth/data/auth_repository.dart';
import 'data_upload_repository.dart';
import 'screenplay_api_mapper.dart';
import 'screenplay_remote_repository.dart';
import 'screenplay_tree_document.dart';

typedef PublishProgressCallback = void Function(
  String stage,
  int done,
  int total,
);

class PublishResult {
  const PublishResult({
    required this.remoteId,
    required this.document,
  });

  final int remoteId;
  final ScreenplayTreeDocument document;
}

/// Publishes local screenplays via bulk POST/PUT `/screenplays/{id}/tree`.
class ScreenplayPublishService {
  ScreenplayPublishService._();

  static final ScreenplayPublishService instance =
      ScreenplayPublishService._();

  Future<({PublishResult? result, String? error})> publish({
    required ScreenplayTreeDocument document,
    required int visibility,
    PublishProgressCallback? onProgress,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (result: null, error: '请先登录');
    }
    if (document.meta.remoteScreenplayId != null) {
      return syncToServer(
        document: document,
        visibility: visibility,
        onProgress: onProgress,
      );
    }

    final screenplay = document.toScreenplay();
    if (screenplay.allFrames.isEmpty && screenplay.coverImagePath == null) {
      return (result: null, error: '剧本没有可发布的画格');
    }

    try {
      final tree = deepCopyJson(document.tree);
      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      final title = screenplayMap['title'] as String? ?? screenplay.title;
      final summary = screenplayMap['summary'] as String? ?? screenplay.synopsis;

      onProgress?.call('创建剧本', 0, 1);
      final created = await _createScreenplay(title: title, summary: summary);
      if (created.error != null || created.screenplay == null) {
        return (result: null, error: created.error ?? '创建剧本失败');
      }

      final remoteId = created.screenplay!.id.toInt();
      screenplayMap['id'] = remoteId;

      final uploads = await _uploadLocalAssets(
        tree,
        onProgress: onProgress,
      );
      if (uploads.error != null) {
        return (result: null, error: uploads.error);
      }
      ScreenplayApiMapper.stampUploadedImageIds(tree, uploads.refToImageId!);

      final coverUrl = await _uploadCoverIfNeeded(
        remoteId: remoteId,
        coverFile: uploads.coverFile,
        onProgress: onProgress,
      );
      if (coverUrl.error != null) {
        return (result: null, error: coverUrl.error);
      }

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _syncTreeBulk(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: visibility,
        isRepublish: false,
        coverUrl: coverUrl.url,
      );
      if (synced.error != null) {
        return (result: null, error: synced.error);
      }

      onProgress?.call('发布剧本', 0, 1);
      final published = await _publish(remoteId);
      if (published.error != null) {
        return (result: null, error: published.error);
      }

      final saved = await ScreenplayRemoteRepository.instance
          .refreshTreeAfterPublish(remoteId);
      if (saved.error != null || saved.tree == null) {
        return (result: null, error: saved.error ?? '获取剧本树失败');
      }

      final profile = AuthRepository.instance.profile;
      final authorName = profile != null && profile.nickname.isNotEmpty
          ? profile.nickname
          : (profile?.username ?? document.meta.author);

      final rawTree =
          ScreenplayRemoteRepository.instance.rawTreeAfterRefresh(remoteId);
      final resultDoc = rawTree != null
          ? ScreenplayApiMapper.applyRawTreeResponse(
              rawTree: rawTree,
              meta: document.meta.copyWith(author: authorName),
              previousTree: tree,
            )
          : ScreenplayApiMapper.applySaveTreeResponse(
              response: saved.tree!,
              meta: document.meta.copyWith(author: authorName),
              previousTree: tree,
            );

      onProgress?.call('完成', 1, 1);
      return (
        result: PublishResult(remoteId: remoteId, document: resultDoc),
        error: null,
      );
    } catch (e) {
      return (result: null, error: e.toString());
    }
  }

  Future<({PublishResult? result, String? error})> syncToServer({
    required ScreenplayTreeDocument document,
    int? visibility,
    PublishProgressCallback? onProgress,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (result: null, error: '请先登录');
    }

    final remoteId = document.meta.remoteScreenplayId;
    if (remoteId == null) {
      return (result: null, error: '剧本尚未发布，无法同步');
    }

    final effectiveVisibility =
        visibility ?? document.meta.visibility ?? 0;

    try {
      final tree = deepCopyJson(document.tree);
      final uploads = await _uploadLocalAssets(
        tree,
        onProgress: onProgress,
      );
      if (uploads.error != null) {
        return (result: null, error: uploads.error);
      }
      ScreenplayApiMapper.stampUploadedImageIds(tree, uploads.refToImageId!);

      final coverUrl = await _uploadCoverIfNeeded(
        remoteId: remoteId,
        coverFile: uploads.coverFile,
        onProgress: onProgress,
      );
      if (coverUrl.error != null) {
        return (result: null, error: coverUrl.error);
      }

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _syncTreeBulk(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: effectiveVisibility,
        isRepublish: true,
        coverUrl: coverUrl.url,
      );
      if (synced.error != null) {
        return (result: null, error: synced.error);
      }

      final saved = await ScreenplayRemoteRepository.instance
          .refreshTreeAfterPublish(remoteId);
      if (saved.error != null || saved.tree == null) {
        return (result: null, error: saved.error ?? '同步失败');
      }

      final profile = AuthRepository.instance.profile;
      final authorName = profile != null && profile.nickname.isNotEmpty
          ? profile.nickname
          : (profile?.username ?? document.meta.author);

      final rawTree =
          ScreenplayRemoteRepository.instance.rawTreeAfterRefresh(remoteId);
      final resultDoc = rawTree != null
          ? ScreenplayApiMapper.applyRawTreeResponse(
              rawTree: rawTree,
              meta: document.meta.copyWith(author: authorName),
              previousTree: document.tree,
            )
          : ScreenplayApiMapper.applySaveTreeResponse(
              response: saved.tree!,
              meta: document.meta.copyWith(author: authorName),
              previousTree: document.tree,
            );

      onProgress?.call('完成', 1, 1);
      return (
        result: PublishResult(remoteId: remoteId, document: resultDoc),
        error: null,
      );
    } catch (e) {
      return (result: null, error: e.toString());
    }
  }

  Future<({
    Map<String, int>? refToImageId,
    File? coverFile,
    String? error,
  })> _uploadLocalAssets(
    Map<String, dynamic> tree, {
    PublishProgressCallback? onProgress,
  }) async {
    final coverFile = ScreenplayApiMapper.collectLocalCoverFile(tree);
    final refToFile = ScreenplayApiMapper.collectLocalFrameAssets(tree);

    if (refToFile.isEmpty) {
      return (
        refToImageId: <String, int>{},
        coverFile: coverFile,
        error: null,
      );
    }

    final total = refToFile.length;
    onProgress?.call('上传图片', 0, total);

    final result = await DataUploadRepository.instance.uploadBatch(
      refToFile,
      onProgress: (done, batchTotal) {
        onProgress?.call('上传图片', done, batchTotal);
      },
    );

    if (result.error != null || result.refToImageId == null) {
      return (
        refToImageId: null,
        coverFile: null,
        error: result.error ?? '图片上传失败',
      );
    }

    return (
      refToImageId: result.refToImageId,
      coverFile: coverFile,
      error: null,
    );
  }

  Future<({String? url, String? error})> _uploadCoverIfNeeded({
    required int remoteId,
    required File? coverFile,
    PublishProgressCallback? onProgress,
  }) async {
    if (coverFile == null) {
      return (url: null, error: null);
    }
    onProgress?.call('上传封面', 0, 1);
    final cover = await DataUploadRepository.instance.uploadScreenplayCover(
      remoteId,
      coverFile,
    );
    if (cover.error != null) {
      return (url: null, error: cover.error);
    }
    return (url: cover.coverUrl, error: null);
  }

  Future<({String? error})> _syncTreeBulk({
    required int remoteId,
    required Map<String, dynamic> tree,
    required Map<String, int> refToImageId,
    required int visibility,
    required bool isRepublish,
    String? coverUrl,
  }) async {
    final payload = ScreenplayApiMapper.buildSaveTreePayload(
      tree: tree,
      visibility: visibility,
      refToImageId: refToImageId,
      isRepublish: isRepublish,
      coverUrl: coverUrl,
    );

    final saved = await ScreenplayRemoteRepository.instance.saveScreenplayTree(
      remoteId,
      payload,
      isInitial: !isRepublish,
    );
    if (saved.error != null) {
      return (error: saved.error);
    }
    return (error: null);
  }

  Future<({api.Screenplay? screenplay, String? error})> _createScreenplay({
    required String title,
    required String summary,
  }) async {
    final completer = Completer<({api.Screenplay? screenplay, String? error})>();

    await screenplay_api.createScreenplay(
      api.CreateScreenplayReq(
        kind: 1,
        title: title,
        subtitle: '',
        summary: summary,
        coverUrl: '',
        publishStatus: 0,
        visibility: 0,
        status: 0,
      ),
      ok: (sp) => completer.complete((screenplay: sp, error: null)),
      fail: (msg) => completer.complete((screenplay: null, error: msg)),
    );

    return completer.future;
  }

  Future<({String? error})> _publish(int remoteId) async {
    final completer = Completer<({String? error})>();
    await screenplay_api.publishScreenplay(
      remoteId,
      ok: (_) => completer.complete((error: null)),
      fail: (msg) => completer.complete((error: msg)),
    );
    return completer.future;
  }
}
