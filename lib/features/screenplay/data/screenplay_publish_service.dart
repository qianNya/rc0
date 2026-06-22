import 'dart:async';

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

/// Publishes local screenplays via Rust stepwise REST API.
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

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _syncTreeStepwise(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: visibility,
        isRepublish: false,
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

      final resultDoc = ScreenplayApiMapper.applySaveTreeResponse(
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

      onProgress?.call('同步剧本树', 0, 1);
      final synced = await _syncTreeStepwise(
        remoteId: remoteId,
        tree: tree,
        refToImageId: uploads.refToImageId!,
        visibility: effectiveVisibility,
        isRepublish: true,
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

      final resultDoc = ScreenplayApiMapper.applySaveTreeResponse(
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

  Future<({Map<String, int>? refToImageId, String? error})> _uploadLocalAssets(
    Map<String, dynamic> tree, {
    PublishProgressCallback? onProgress,
  }) async {
    final refToFile = ScreenplayApiMapper.collectLocalAssets(tree);
    if (refToFile.isEmpty) {
      return (refToImageId: <String, int>{}, error: null);
    }

    final deduped = ScreenplayApiMapper.dedupeRefsByFile(refToFile);
    final total = refToFile.length;
    onProgress?.call('上传图片', 0, total);

    final result = await DataUploadRepository.instance.uploadBatch(
      deduped.unique,
      onProgress: (done, batchTotal) {
        onProgress?.call('上传图片', done, batchTotal);
      },
    );

    if (result.error != null || result.refToImageId == null) {
      return (refToImageId: null, error: result.error ?? '图片上传失败');
    }

    final expanded = <String, int>{};
    for (final entry in refToFile.entries) {
      final primary = deduped.refToPrimaryRef[entry.key] ?? entry.key;
      final imageId = result.refToImageId![primary];
      if (imageId == null) {
        return (refToImageId: null, error: '图片上传不完整: ${entry.key}');
      }
      expanded[entry.key] = imageId;
    }

    return (refToImageId: expanded, error: null);
  }

  Future<({String? error})> _syncTreeStepwise({
    required int remoteId,
    required Map<String, dynamic> tree,
    required Map<String, int> refToImageId,
    required int visibility,
    required bool isRepublish,
  }) async {
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final updateErr = await _updateScreenplayMetadata(
      remoteId,
      title: screenplayMap['title'] as String? ?? '',
      summary: screenplayMap['summary'] as String? ?? '',
      visibility: visibility,
      isRepublish: isRepublish,
    );
    if (updateErr != null) return (error: updateErr);

    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final actNode = acts[actIdx] as Map<String, dynamic>;
      final actMap = actNode['act'] as Map<String, dynamic>;
      final actSort = (actMap['sort'] as num?)?.toInt() ?? actIdx + 1;
      final actTitle = actMap['title'] as String? ?? '';
      final actSummary = actMap['summary'] as String? ?? '';
      final existingActId = (actMap['id'] as num?)?.toInt() ?? 0;

      late final int actId;
      if (isRepublish && existingActId > 0) {
        final err = await _updateAct(
          remoteId,
          existingActId,
          title: actTitle,
          summary: actSummary,
          sort: actSort,
        );
        if (err != null) return (error: err);
        actId = existingActId;
      } else {
        final created = await _createAct(
          remoteId,
          title: actTitle,
          summary: actSummary,
          sort: actSort,
        );
        if (created.error != null || created.act == null) {
          return (error: created.error ?? '创建幕失败');
        }
        actId = created.act!.id.toInt();
        actMap['id'] = actId;
      }

      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final sceneNode = scenes[sceneIdx] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneSort = (sceneMap['sort'] as num?)?.toInt() ?? sceneIdx + 1;
        final sceneTitle = sceneMap['title'] as String? ?? '';
        final sceneSummary = sceneMap['summary'] as String? ?? '';
        final existingSceneId = (sceneMap['id'] as num?)?.toInt() ?? 0;

        late final int sceneId;
        if (isRepublish && existingSceneId > 0) {
          final err = await _updateScene(
            remoteId,
            actId,
            existingSceneId,
            title: sceneTitle,
            summary: sceneSummary,
            sort: sceneSort,
          );
          if (err != null) return (error: err);
          sceneId = existingSceneId;
        } else {
          final created = await _createScene(
            remoteId,
            actId,
            title: sceneTitle,
            summary: sceneSummary,
            sort: sceneSort,
          );
          if (created.error != null || created.scene == null) {
            return (error: created.error ?? '创建场失败');
          }
          sceneId = created.scene!.id.toInt();
          sceneMap['id'] = sceneId;
        }

        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
          final frameMap = frames[frameIdx] as Map<String, dynamic>;
          final frameSort = (frameMap['sort'] as num?)?.toInt() ?? frameIdx + 1;
          final frameTitle = frameMap['title'] as String? ?? '';
          final ref = ScreenplayApiMapper.frameRef(actIdx, sceneIdx, frameIdx);
          final imageId = refToImageId[ref];
          final existingFrameId = (frameMap['id'] as num?)?.toInt() ?? 0;

          if (isRepublish && existingFrameId > 0) {
            final err = await _updateFrame(
              remoteId,
              actId,
              sceneId,
              existingFrameId,
              title: frameTitle,
              sort: frameSort,
              imageId: imageId,
              dialogue: frameMap['dialogue'] as String? ?? '',
              actionNote: frameMap['action_note'] as String? ?? '',
            );
            if (err != null) return (error: err);
          } else {
            if (imageId == null) {
              return (error: '缺少帧图片: $ref');
            }
            final created = await _createFrame(
              remoteId,
              actId,
              sceneId,
              title: frameTitle,
              sort: frameSort,
              imageId: imageId,
              dialogue: frameMap['dialogue'] as String? ?? '',
              actionNote: frameMap['action_note'] as String? ?? '',
            );
            if (created.error != null || created.frame == null) {
              return (error: created.error ?? '创建帧失败');
            }
            frameMap['id'] = created.frame!.id.toInt();
          }
        }
      }
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

  Future<String?> _updateScreenplayMetadata(
    int remoteId, {
    required String title,
    required String summary,
    required int visibility,
    required bool isRepublish,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      if (summary.isNotEmpty) 'summary': summary,
    };
    if (isRepublish) {
      body['visibility'] = visibility;
    }

    final completer = Completer<String?>();
    await screenplay_api.updateScreenplay(
      remoteId,
      body,
      ok: (_) => completer.complete(null),
      fail: completer.complete,
    );
    return completer.future;
  }

  Future<({api.Act? act, String? error})> _createAct(
    int remoteId, {
    required String title,
    required String summary,
    required int sort,
  }) async {
    final completer = Completer<({api.Act? act, String? error})>();
    await screenplay_api.createAct(
      remoteId,
      {
        'title': title,
        if (summary.isNotEmpty) 'summary': summary,
        'sort': sort,
      },
      ok: (act) => completer.complete((act: act, error: null)),
      fail: (msg) => completer.complete((act: null, error: msg)),
    );
    return completer.future;
  }

  Future<String?> _updateAct(
    int remoteId,
    int actId, {
    required String title,
    required String summary,
    required int sort,
  }) async {
    final completer = Completer<String?>();
    await screenplay_api.updateAct(
      remoteId,
      actId,
      {
        'title': title,
        if (summary.isNotEmpty) 'summary': summary,
        'sort': sort,
      },
      ok: (_) => completer.complete(null),
      fail: completer.complete,
    );
    return completer.future;
  }

  Future<({api.Scene? scene, String? error})> _createScene(
    int remoteId,
    int actId, {
    required String title,
    required String summary,
    required int sort,
  }) async {
    final completer = Completer<({api.Scene? scene, String? error})>();
    await screenplay_api.createScene(
      remoteId,
      actId,
      {
        'title': title,
        if (summary.isNotEmpty) 'summary': summary,
        'sort': sort,
      },
      ok: (scene) => completer.complete((scene: scene, error: null)),
      fail: (msg) => completer.complete((scene: null, error: msg)),
    );
    return completer.future;
  }

  Future<String?> _updateScene(
    int remoteId,
    int actId,
    int sceneId, {
    required String title,
    required String summary,
    required int sort,
  }) async {
    final completer = Completer<String?>();
    await screenplay_api.updateScene(
      remoteId,
      actId,
      sceneId,
      {
        'title': title,
        if (summary.isNotEmpty) 'summary': summary,
        'sort': sort,
      },
      ok: (_) => completer.complete(null),
      fail: completer.complete,
    );
    return completer.future;
  }

  Future<({api.Frame? frame, String? error})> _createFrame(
    int remoteId,
    int actId,
    int sceneId, {
    required String title,
    required int sort,
    required int imageId,
    required String dialogue,
    required String actionNote,
  }) async {
    final completer = Completer<({api.Frame? frame, String? error})>();
    await screenplay_api.createFrame(
      remoteId,
      actId,
      sceneId,
      {
        'title': title,
        'sort': sort,
        'acgn_image_id': imageId,
        if (dialogue.isNotEmpty) 'dialogue': dialogue,
        if (actionNote.isNotEmpty) 'action_note': actionNote,
        'duration_sec': 3,
      },
      ok: (frame) => completer.complete((frame: frame, error: null)),
      fail: (msg) => completer.complete((frame: null, error: msg)),
    );
    return completer.future;
  }

  Future<String?> _updateFrame(
    int remoteId,
    int actId,
    int sceneId,
    int frameId, {
    required String title,
    required int sort,
    int? imageId,
    required String dialogue,
    required String actionNote,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'sort': sort,
      if (dialogue.isNotEmpty) 'dialogue': dialogue,
      if (actionNote.isNotEmpty) 'action_note': actionNote,
    };
    if (imageId != null) {
      body['acgn_image_id'] = imageId;
    }

    final completer = Completer<String?>();
    await screenplay_api.updateFrame(
      remoteId,
      actId,
      sceneId,
      frameId,
      body,
      ok: (_) => completer.complete(null),
      fail: completer.complete,
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
