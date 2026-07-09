import 'dart:async';
import 'dart:io';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../../core/auth/auth_bridge.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/media/app_media_upload_service.dart';
import '../../../core/media/upload_legacy_adapter.dart';
import '../../../core/network/api_callback.dart';
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
    required int kind,
    PublishProgressCallback? onProgress,
  }) async {
    if (!AuthBridge.isLoggedIn) {
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

    final effectiveKind =
        kind == Screenplay.kindTemplate ? Screenplay.kindTemplate : Screenplay.kindPersonal;
    final effectiveVisibility =
        effectiveKind == Screenplay.kindTemplate ? 1 : visibility;

    try {
      final tree = deepCopyJson(document.tree);
      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      final title = screenplayMap['title'] as String? ?? screenplay.title;
      final summary = screenplayMap['summary'] as String? ?? screenplay.synopsis;
      screenplayMap['kind'] = effectiveKind;
      screenplayMap['visibility'] = effectiveVisibility;

      onProgress?.call('创建剧本', 0, 1);
      final created = await _createScreenplay(
        title: title,
        summary: summary,
        kind: effectiveKind,
        visibility: effectiveVisibility,
      );
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
      ScreenplayApiMapper.stampUploadedImages(tree, uploads.refToUploaded!);

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
        refToUploaded: uploads.refToUploaded!,
        visibility: effectiveVisibility,
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

      final profile = AuthBridge.profile;
      final authorName = profile != null && profile.nickname.isNotEmpty
          ? profile.nickname
          : (profile?.username ?? document.meta.author);

      final rawTree =
          ScreenplayRemoteRepository.instance.rawTreeAfterRefresh(remoteId);
      final resultMeta = document.meta.copyWith(
        author: authorName,
        kind: effectiveKind,
        visibility: effectiveVisibility,
      );
      final resultDoc = rawTree != null
          ? ScreenplayApiMapper.applyRawTreeResponse(
              rawTree: rawTree,
              meta: resultMeta,
              previousTree: tree,
            )
          : ScreenplayApiMapper.applySaveTreeResponse(
              response: saved.tree!,
              meta: resultMeta,
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
    if (!AuthBridge.isLoggedIn) {
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
      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      // Keep existing kind from document meta/tree unless already set.
      final existingKind = document.meta.kind > 0
          ? document.meta.kind
          : ((screenplayMap['kind'] as num?)?.toInt() ??
              Screenplay.kindPersonal);
      screenplayMap['kind'] = existingKind;
      screenplayMap['visibility'] = effectiveVisibility;
      final uploads = await _uploadLocalAssets(
        tree,
        onProgress: onProgress,
      );
      if (uploads.error != null) {
        return (result: null, error: uploads.error);
      }
      ScreenplayApiMapper.stampUploadedImages(tree, uploads.refToUploaded!);

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
        refToUploaded: uploads.refToUploaded!,
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

      final profile = AuthBridge.profile;
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
    Map<String, UploadedImage>? refToUploaded,
    File? coverFile,
    String? error,
  })> _uploadLocalAssets(
    Map<String, dynamic> tree, {
    PublishProgressCallback? onProgress,
  }) async {
    final coverFile = ScreenplayApiMapper.collectLocalCoverFile(tree);
    final refToFile = <String, File>{
      ...ScreenplayApiMapper.collectLocalFrameAssets(tree),
      ...ScreenplayApiMapper.collectLocalReferenceAssets(tree),
    };

    if (refToFile.isEmpty) {
      return (
        refToUploaded: <String, UploadedImage>{},
        coverFile: coverFile,
        error: null,
      );
    }

    final total = refToFile.length;
    onProgress?.call('上传图片', 0, total);

    final refToPath = refToFile.map((key, file) => MapEntry(key, file.path));
    final result = await AppMediaUploadService.instance.uploadLocalBatch(
      refToPath,
      onProgress: (done, batchTotal) {
        onProgress?.call('上传图片', done, batchTotal);
      },
    );

    if (result.error != null || result.results == null) {
      return (
        refToUploaded: null,
        coverFile: null,
        error: result.error ?? '图片上传失败',
      );
    }

    return (
      refToUploaded: uploadedImagesFromMediaBatch(result.results!),
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
    final cover = await AppMediaUploadService.instance.uploadScreenplayCover(
      screenplayId: remoteId,
      localPath: coverFile.path,
    );
    if (cover.error != null) {
      return (url: null, error: cover.error);
    }
    return (url: cover.coverUrl, error: null);
  }

  Future<({String? error})> _syncTreeBulk({
    required int remoteId,
    required Map<String, dynamic> tree,
    required Map<String, UploadedImage> refToUploaded,
    required int visibility,
    required bool isRepublish,
    String? coverUrl,
  }) async {
    var effectiveRepublish = isRepublish;
    var treeToSave = tree;

    if (!isRepublish) {
      final hasRemoteTree = await ScreenplayRemoteRepository.instance
          .remoteTreeHasHierarchy(remoteId);
      if (hasRemoteTree) {
        effectiveRepublish = true;
        treeToSave = deepCopyJson(tree);
        await _stampServerNodeIds(remoteId, treeToSave);
      }
    }

    var saved = await _saveTreePayload(
      remoteId: remoteId,
      tree: treeToSave,
      refToUploaded: refToUploaded,
      visibility: visibility,
      isRepublish: effectiveRepublish,
      coverUrl: coverUrl,
    );

    if (saved.error != null &&
        !effectiveRepublish &&
        _isTreeAlreadyExistsError(saved.error)) {
      effectiveRepublish = true;
      treeToSave = deepCopyJson(tree);
      await _stampServerNodeIds(remoteId, treeToSave);
      saved = await _saveTreePayload(
        remoteId: remoteId,
        tree: treeToSave,
        refToUploaded: refToUploaded,
        visibility: visibility,
        isRepublish: true,
        coverUrl: coverUrl,
      );
    }

    if (saved.error != null) {
      return (error: saved.error);
    }
    return (error: null);
  }

  Future<({api.GetScreenplayTreeResp? tree, String? error})> _saveTreePayload({
    required int remoteId,
    required Map<String, dynamic> tree,
    required Map<String, UploadedImage> refToUploaded,
    required int visibility,
    required bool isRepublish,
    String? coverUrl,
  }) {
    final payload = ScreenplayApiMapper.buildSaveTreePayload(
      tree: tree,
      visibility: visibility,
      refToUploaded: refToUploaded,
      isRepublish: isRepublish,
      coverUrl: coverUrl,
    );
    return ScreenplayRemoteRepository.instance.saveScreenplayTree(
      remoteId,
      payload,
      isInitial: !isRepublish,
    );
  }

  Future<void> _stampServerNodeIds(
    int remoteId,
    Map<String, dynamic> localTree,
  ) async {
    final serverTree = await ScreenplayRemoteRepository.instance.fetchRawTree(
      remoteId,
      useCache: false,
    );
    if (serverTree.tree != null) {
      ScreenplayApiMapper.stampServerNodeIds(localTree, serverTree.tree!);
    }
  }

  bool _isTreeAlreadyExistsError(String? error) {
    if (error == null) return false;
    final lower = error.toLowerCase();
    return lower.contains('409') ||
        lower.contains('conflict') ||
        error.contains('冲突') ||
        error.contains('已有');
  }

  Future<({api.Screenplay? screenplay, String? error})> _createScreenplay({
    required String title,
    required String summary,
    required int kind,
    required int visibility,
  }) async {
    final completer = Completer<({api.Screenplay? screenplay, String? error})>();

    await screenplay_api.createScreenplay(
      api.CreateScreenplayReq(
        kind: kind,
        title: title,
        subtitle: '',
        summary: summary,
        coverUrl: '',
        publishStatus: 0,
        visibility: visibility,
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

  /// Upgrade a published personal work to a template (`kind=2`).
  Future<({api.Screenplay? screenplay, String? error})> promoteToTemplate(
    int remoteId,
  ) async {
    if (!AuthBridge.isLoggedIn) {
      return (screenplay: null, error: '请先登录');
    }
    final (sp, error) = await apiCallback<api.Screenplay>(
      ({ok, fail, eventually}) => screenplay_api.updateScreenplay(
        remoteId,
        {'kind': Screenplay.kindTemplate, 'visibility': 1},
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) {
      return (screenplay: null, error: error);
    }
    return (screenplay: sp, error: null);
  }
}
