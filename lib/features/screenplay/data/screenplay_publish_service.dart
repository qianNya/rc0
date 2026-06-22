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

/// Publishes local screenplays via POST/PUT `/screenplays/{id}/tree`.
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

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _saveTree(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: visibility,
        isRepublish: false,
      );
      if (synced.error != null) {
        return (result: null, error: synced.error);
      }

      if (uploads.coverFile != null) {
        onProgress?.call('上传封面', 0, 1);
        final cover = await DataUploadRepository.instance.uploadScreenplayCover(
          remoteId,
          uploads.coverFile!,
        );
        if (cover.error != null) {
          return (result: null, error: cover.error);
        }
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

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _saveTree(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: effectiveVisibility,
        isRepublish: true,
      );
      if (synced.error != null) {
        return (result: null, error: synced.error);
      }

      if (uploads.coverFile != null) {
        onProgress?.call('上传封面', 0, 1);
        final cover = await DataUploadRepository.instance.uploadScreenplayCover(
          remoteId,
          uploads.coverFile!,
        );
        if (cover.error != null) {
          return (result: null, error: cover.error);
        }
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

  Future<({api.GetScreenplayTreeResp? tree, String? error})> _saveTree({
    required int remoteId,
    required Map<String, dynamic> tree,
    required Map<String, int> refToImageId,
    required int visibility,
    required bool isRepublish,
  }) async {
    final payload = ScreenplayApiMapper.buildSaveTreePayload(
      tree: tree,
      visibility: visibility,
      refToImageId: refToImageId,
      isRepublish: isRepublish,
    );

    final completer =
        Completer<({api.GetScreenplayTreeResp? tree, String? error})>();

    if (isRepublish) {
      await screenplay_api.saveScreenplayTree(
        remoteId,
        payload,
        ok: (tree) => completer.complete((tree: tree, error: null)),
        fail: (msg) => completer.complete((tree: null, error: msg)),
      );
    } else {
      await screenplay_api.createScreenplayTree(
        remoteId,
        payload,
        ok: (tree) => completer.complete((tree: tree, error: null)),
        fail: (msg) => completer.complete((tree: null, error: msg)),
      );
    }

    return completer.future;
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
