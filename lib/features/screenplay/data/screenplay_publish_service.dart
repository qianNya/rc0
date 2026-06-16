import 'dart:async';
import 'dart:io';

import '../../../api/screenplay/api/screenplay-api.dart' as screenplay_api;
import '../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../auth/data/auth_repository.dart';
import 'data_upload_repository.dart';
import 'screenplay_image_resolver.dart';
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

class ScreenplayPublishService {
  ScreenplayPublishService._();

  static final ScreenplayPublishService instance =
      ScreenplayPublishService._();

  static const _uploadConcurrency = 3;

  Future<({PublishResult? result, String? error})> publish({
    required ScreenplayTreeDocument document,
    required int visibility,
    PublishProgressCallback? onProgress,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (result: null, error: '请先登录');
    }
    if (document.meta.remoteScreenplayId != null) {
      return (result: null, error: '该剧本已发布，暂不支持重新发布');
    }

    final screenplay = document.toScreenplay();
    if (screenplay.allFrames.isEmpty && screenplay.coverImagePath == null) {
      return (result: null, error: '剧本没有可发布的画格');
    }

    try {
      final tree = deepCopyJson(document.tree);
      final paths = _collectImagePaths(tree);
      if (paths.isEmpty) {
        return (result: null, error: '没有可上传的图片');
      }

      onProgress?.call('上传图片', 0, paths.length);
      final urlMap = await _uploadImages(paths, onProgress);

      _applyUrlMap(tree, urlMap);

      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      final title = screenplayMap['title'] as String? ?? screenplay.title;
      final summary = screenplayMap['summary'] as String? ?? screenplay.synopsis;
      final coverUrl = screenplayMap['cover_url'] as String? ?? '';

      onProgress?.call('创建剧本', 0, 1);
      final created = await _createScreenplay(
        title: title,
        summary: summary,
        coverUrl: coverUrl,
        visibility: visibility,
      );
      if (created.error != null || created.screenplay == null) {
        return (result: null, error: created.error ?? '创建剧本失败');
      }

      final remoteId = created.screenplay!.id.toInt();
      screenplayMap['id'] = remoteId;
      screenplayMap['cover_url'] = coverUrl;
      screenplayMap['publish_status'] = 1;
      screenplayMap['visibility'] = visibility;
      screenplayMap['published_at'] = DateTime.now().toIso8601String();

      onProgress?.call('同步结构', 0, 1);
      final structureError = await _createStructure(remoteId, tree);
      if (structureError != null) {
        return (result: null, error: structureError);
      }

      onProgress?.call('完成', 1, 1);
      final updated = await _updateScreenplay(
        remoteId: remoteId,
        title: title,
        summary: summary,
        coverUrl: coverUrl,
        visibility: visibility,
      );
      if (updated.error != null) {
        return (result: null, error: updated.error);
      }

      final profile = AuthRepository.instance.profile;
      final authorName = profile != null && profile.nickname.isNotEmpty
          ? profile.nickname
          : (profile?.username ?? '我');
      final updatedMeta = document.meta.copyWith(
        remoteScreenplayId: remoteId,
        visibility: visibility,
        publishedAt: DateTime.now(),
        author: authorName,
      );

      return (
        result: PublishResult(
          remoteId: remoteId,
          document: ScreenplayTreeDocument(tree: tree, meta: updatedMeta),
        ),
        error: null,
      );    } catch (e) {
      return (result: null, error: e.toString());
    }
  }

  List<String> _collectImagePaths(Map<String, dynamic> tree) {
    final paths = <String>{};
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>?;
    final coverLocal = screenplayMap?['local_cover_path'] as String?;
    final coverUrl = screenplayMap?['cover_url'] as String? ?? '';
    final coverSrc = ScreenplayImageResolver.uploadSourcePath(
      localPath: coverLocal,
      imageUrl: coverUrl,
    );
    if (coverSrc != null) paths.add(coverSrc);

    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (final actNode in acts) {
      final scenes =
          (actNode as Map<String, dynamic>)['scenes'] as List<dynamic>? ?? [];
      for (final sceneNode in scenes) {
        final frames =
            (sceneNode as Map<String, dynamic>)['frames'] as List<dynamic>? ??
                [];
        for (final frame in frames) {
          final frameMap = frame as Map<String, dynamic>;
          final uploadSrc = ScreenplayImageResolver.uploadSourcePath(
            localPath: frameMap['local_image_path'] as String?,
            imageUrl: frameMap['image_url'] as String?,
          );
          if (uploadSrc != null) paths.add(uploadSrc);
        }
      }
    }
    return paths.toList();
  }
  Future<Map<String, String>> _uploadImages(
    List<String> paths,
    PublishProgressCallback? onProgress,
  ) async {
    final urlMap = <String, String>{};
    var done = 0;

    Future<void> uploadOne(String path) async {
      if (ScreenplayImageResolver.isNetworkUrl(path)) {
        urlMap[path] = path;
        return;
      }
      final file = File(path);
      if (!file.existsSync()) {
        throw StateError('图片不存在: $path');
      }
      final result = await DataUploadRepository.instance.uploadImage(file);
      if (result.error != null || result.object == null) {
        throw StateError(result.error ?? '图片上传失败');
      }
      urlMap[path] = result.object!.downloadUrl;
    }

    for (var i = 0; i < paths.length; i += _uploadConcurrency) {
      final batch = paths.skip(i).take(_uploadConcurrency).toList();
      await Future.wait(batch.map(uploadOne));
      done += batch.length;
      onProgress?.call('上传图片', done, paths.length);
    }

    return urlMap;
  }

  void _applyUrlMap(Map<String, dynamic> tree, Map<String, String> urlMap) {
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final coverLocal = screenplayMap['local_cover_path'] as String?;
    final coverUrl = screenplayMap['cover_url'] as String? ?? '';
    final coverSrc = ScreenplayImageResolver.uploadSourcePath(
      localPath: coverLocal,
      imageUrl: coverUrl,
    );
    if (coverSrc != null && urlMap.containsKey(coverSrc)) {
      screenplayMap['cover_url'] = urlMap[coverSrc]!;
      screenplayMap['local_cover_path'] = coverSrc;
    } else if (coverUrl.isEmpty) {
      final firstUrl = _firstFrameUrl(tree, urlMap);
      if (firstUrl != null) screenplayMap['cover_url'] = firstUrl;
    }

    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (final actNode in acts) {
      final scenes =
          (actNode as Map<String, dynamic>)['scenes'] as List<dynamic>? ?? [];
      for (final sceneNode in scenes) {
        final frames =
            (sceneNode as Map<String, dynamic>)['frames'] as List<dynamic>? ??
                [];
        for (final frame in frames) {
          final frameMap = frame as Map<String, dynamic>;
          final imageUrl = frameMap['image_url'] as String? ?? '';
          final localPath = frameMap['local_image_path'] as String?;
          final uploadSrc = ScreenplayImageResolver.uploadSourcePath(
            localPath: localPath,
            imageUrl: imageUrl,
          );
          if (uploadSrc != null && urlMap.containsKey(uploadSrc)) {
            final url = urlMap[uploadSrc]!;
            frameMap['image_url'] = url;
            frameMap['thumbnail_url'] = url;
            frameMap['local_image_path'] = uploadSrc;
            frameMap['local_thumbnail_path'] = uploadSrc;
          }
        }
      }
    }
  }
  String? _firstFrameUrl(
    Map<String, dynamic> tree,
    Map<String, String> urlMap,
  ) {
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (final actNode in acts) {
      final scenes =
          (actNode as Map<String, dynamic>)['scenes'] as List<dynamic>? ?? [];
      for (final sceneNode in scenes) {
        final frames =
            (sceneNode as Map<String, dynamic>)['frames'] as List<dynamic>? ??
                [];
        for (final frame in frames) {
          final frameMap = frame as Map<String, dynamic>;
          final uploadSrc = ScreenplayImageResolver.uploadSourcePath(
            localPath: frameMap['local_image_path'] as String?,
            imageUrl: frameMap['image_url'] as String?,
          );
          if (uploadSrc != null) {
            return urlMap[uploadSrc] ?? frameMap['image_url'] as String?;
          }
        }
      }
    }
    return null;
  }
  Future<({api.Screenplay? screenplay, String? error})> _createScreenplay({
    required String title,
    required String summary,
    required String coverUrl,
    required int visibility,
  }) async {
    final completer = Completer<({api.Screenplay? screenplay, String? error})>();

    await screenplay_api.createScreenplay(
      api.CreateScreenplayReq(
        kind: 1,
        title: title,
        subtitle: '',
        summary: summary,
        coverUrl: coverUrl,
        coverObjectId: 0,
        publishStatus: 1,
        visibility: visibility,
        status: 0,
      ),
      ok: (sp) => completer.complete((screenplay: sp, error: null)),
      fail: (msg) => completer.complete((screenplay: null, error: msg)),
    );

    return completer.future;
  }

  Future<String?> _createStructure(int remoteId, Map<String, dynamic> tree) async {
    final acts = tree['acts'] as List<dynamic>? ?? [];

    for (var actIndex = 0; actIndex < acts.length; actIndex++) {
      final actNode = acts[actIndex] as Map<String, dynamic>;
      final actMap = actNode['act'] as Map<String, dynamic>;
      final actResult = await _createAct(
        remoteId: remoteId,
        title: actMap['title'] as String? ?? '第${actIndex + 1}幕',
        summary: actMap['summary'] as String? ?? '',
        sort: (actMap['sort'] as num?)?.toInt() ?? actIndex + 1,
      );
      if (actResult.error != null || actResult.act == null) {
        return actResult.error ?? '创建幕失败';
      }
      final actId = actResult.act!.id.toInt();

      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIndex = 0; sceneIndex < scenes.length; sceneIndex++) {
        final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneResult = await _createScene(
          remoteId: remoteId,
          actId: actId,
          title: sceneMap['title'] as String? ?? '第${sceneIndex + 1}场',
          summary: sceneMap['summary'] as String? ?? '',
          location: sceneMap['location'] as String? ?? '',
          timeOfDay: sceneMap['time_of_day'] as String? ?? '',
          sort: (sceneMap['sort'] as num?)?.toInt() ?? sceneIndex + 1,
        );
        if (sceneResult.error != null || sceneResult.scene == null) {
          return sceneResult.error ?? '创建场失败';
        }
        final sceneId = sceneResult.scene!.id.toInt();

        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIndex = 0; frameIndex < frames.length; frameIndex++) {
          final frameMap = frames[frameIndex] as Map<String, dynamic>;
          final frameResult = await _createFrame(
            remoteId: remoteId,
            actId: actId,
            sceneId: sceneId,
            dialogue: frameMap['dialogue'] as String? ?? '',
            actionNote: frameMap['action_note'] as String? ?? '',
            imageUrl: frameMap['image_url'] as String? ?? '',
            sort: (frameMap['sort'] as num?)?.toInt() ?? frameIndex + 1,
          );
          if (frameResult != null) return frameResult;
        }
      }
    }
    return null;
  }

  Future<({api.Act? act, String? error})> _createAct({
    required int remoteId,
    required String title,
    required String summary,
    required int sort,
  }) async {
    final completer = Completer<({api.Act? act, String? error})>();
    await screenplay_api.createAct(
      remoteId,
      api.CreateActReq(
        screenplayId: remoteId,
        title: title,
        summary: summary,
        sort: sort,
        status: 0,
      ),
      ok: (act) => completer.complete((act: act, error: null)),
      fail: (msg) => completer.complete((act: null, error: msg)),
    );
    return completer.future;
  }

  Future<({api.Scene? scene, String? error})> _createScene({
    required int remoteId,
    required int actId,
    required String title,
    required String summary,
    required String location,
    required String timeOfDay,
    required int sort,
  }) async {
    final completer = Completer<({api.Scene? scene, String? error})>();
    await screenplay_api.createScene(
      remoteId,
      actId,
      api.CreateSceneReq(
        screenplayId: remoteId,
        actId: actId,
        title: title,
        summary: summary,
        location: location,
        timeOfDay: timeOfDay,
        sort: sort,
        status: 0,
      ),
      ok: (scene) => completer.complete((scene: scene, error: null)),
      fail: (msg) => completer.complete((scene: null, error: msg)),
    );
    return completer.future;
  }

  Future<String?> _createFrame({
    required int remoteId,
    required int actId,
    required int sceneId,
    required String dialogue,
    required String actionNote,
    required String imageUrl,
    required int sort,
  }) async {
    final completer = Completer<String?>();
    await screenplay_api.createFrame(
      remoteId,
      actId,
      sceneId,
      api.CreateFrameReq(
        screenplayId: remoteId,
        actId: actId,
        sceneId: sceneId,
        title: '',
        dialogue: dialogue,
        actionNote: actionNote,
        durationSec: 0,
        sort: sort,
        thumbnailUrl: imageUrl,
        imageUrl: imageUrl,
        dataObjectId: 0,
        status: 0,
      ),
      ok: (_) => completer.complete(null),
      fail: (msg) => completer.complete(msg),
    );
    return completer.future;
  }

  Future<({String? error})> _updateScreenplay({
    required int remoteId,
    required String title,
    required String summary,
    required String coverUrl,
    required int visibility,
  }) async {
    final completer = Completer<({String? error})>();
    await screenplay_api.updateScreenplay(
      remoteId,
      api.UpdateScreenplayReq(
        id: remoteId,
        kind: 1,
        title: title,
        subtitle: '',
        summary: summary,
        coverUrl: coverUrl,
        coverObjectId: 0,
        publishStatus: 1,
        visibility: visibility,
        status: 0,
      ),
      ok: (_) => completer.complete((error: null)),
      fail: (msg) => completer.complete((error: msg)),
    );
    return completer.future;
  }
}
