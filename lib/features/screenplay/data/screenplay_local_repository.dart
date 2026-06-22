import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/pose_item.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/domain/screenplay/screenplay_adapter.dart';
import '../../../core/domain/screenplay/screenplay_image_resolver.dart';
import '../../../core/domain/screenplay/script_frame_display.dart';
import '../../../core/utils/image_url_utils.dart';
import '../../upload/domain/upload_image_file.dart';
import 'screenplay_draft.dart';
import 'screenplay_remote_delete_service.dart';
import 'screenplay_remote_repository.dart';
import 'screenplay_tree_document.dart';

class ScreenplayLocalRepository extends ChangeNotifier {
  ScreenplayLocalRepository._();

  static final ScreenplayLocalRepository instance =
      ScreenplayLocalRepository._();

  static const _storageKey = 'rc0_screenplay_trees';
  static const _legacyStorageKey = 'rc0_screenplays';
  static const _legacyPosesKey = 'rc0_local_poses';

  SharedPreferences? _prefs;
  final List<ScreenplayTreeDocument> _documents = [];

  List<Screenplay> get localScreenplays =>
      List.unmodifiable(_documents.map((d) => d.toScreenplay()));

  ScreenplayTreeDocument? documentById(String localId) {
    for (final doc in _documents) {
      if (doc.meta.localId == localId) return doc;
    }
    return null;
  }

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    _documents.clear();

    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final doc = _parseStoredItem(map);
        if (doc != null && _hasValidFrames(doc.toScreenplay())) {
          final migrated = migrateDualPaths(doc);
          _documents.add(migrated);
        }
      }
      if (_documents.isNotEmpty) {
        await _save();
      }
    } else {
      await _migrateFromLegacy(prefs);
    }

    notifyListeners();
  }

  ScreenplayTreeDocument? _parseStoredItem(Map<String, dynamic> map) {
    if (isTreeShapedDocument(map)) {
      return ScreenplayTreeDocument.fromJson(map);
    }
    if (isLegacyFlatScreenplay(map)) {
      final screenplay = Screenplay.fromJson(map);
      return ScreenplayTreeDocument.fromScreenplay(screenplay);
    }
    return null;
  }

  Future<void> _migrateFromLegacy(SharedPreferences prefs) async {
    final legacyRaw = prefs.getString(_legacyStorageKey);
    if (legacyRaw != null && legacyRaw.isNotEmpty) {
      final list = jsonDecode(legacyRaw) as List<dynamic>;
      for (final item in list) {
        final doc = _parseStoredItem(item as Map<String, dynamic>);
        if (doc != null && _hasValidFrames(doc.toScreenplay())) {
          _documents.add(doc);
        }
      }
    } else {
      await _migrateLegacyPoses(prefs);
    }

    if (_documents.isNotEmpty) {
      await _save();
      await prefs.remove(_legacyStorageKey);
    }
  }

  Future<void> _migrateLegacyPoses(SharedPreferences prefs) async {
    final legacyRaw = prefs.getString(_legacyPosesKey);
    if (legacyRaw == null || legacyRaw.isEmpty) return;

    final list = jsonDecode(legacyRaw) as List<dynamic>;
    for (final item in list) {
      final pose = PoseItem.fromJson(item as Map<String, dynamic>);
      if (pose.imagePaths.isEmpty && pose.coverImagePath == null) continue;
      final script = migrateFromPoseItem(pose);
      if (_hasValidFrames(script)) {
        _documents.add(ScreenplayTreeDocument.fromScreenplay(script));
      }
    }

    if (_documents.isNotEmpty) {
      await _save();
      await prefs.remove(_legacyPosesKey);
    }
  }

  bool _hasValidFrames(Screenplay script) {
    if (script.allFrames.isEmpty && script.coverUrl != null) {
      return script.coverUrl!.isNotEmpty;
    }
    return script.allFrames.any((frame) {
      final p = frame.effectiveDisplayPath;
      if (p.isEmpty) return false;
      if (ScreenplayImageResolver.isNetworkUrl(p)) return true;
      return File(p).existsSync();
    });
  }

  ScreenplayTreeDocument migrateDualPaths(ScreenplayTreeDocument doc) {
    final tree = deepCopyJson(doc.tree);
    var changed = false;

    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final coverUrl = screenplayMap['cover_url'] as String? ?? '';
    final coverLocal = screenplayMap['local_cover_path'] as String?;
    if (coverUrl.isNotEmpty && !ScreenplayImageResolver.isNetworkUrl(coverUrl)) {
      if (coverLocal == null || coverLocal.isEmpty) {
        screenplayMap['local_cover_path'] = coverUrl;
      }
      screenplayMap['cover_url'] = '';
      changed = true;
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
          final thumbUrl = frameMap['thumbnail_url'] as String? ?? '';
          final localPath = frameMap['local_image_path'] as String?;
          if (imageUrl.isNotEmpty &&
              !ScreenplayImageResolver.isNetworkUrl(imageUrl)) {
            if (localPath == null || localPath.isEmpty) {
              frameMap['local_image_path'] = imageUrl;
              frameMap['local_thumbnail_path'] = imageUrl;
            }
            frameMap['image_url'] = '';
            if (!ScreenplayImageResolver.isNetworkUrl(thumbUrl)) {
              frameMap['thumbnail_url'] = '';
            }
            changed = true;
          }
        }
      }
    }

    if (!changed) return doc;
    return ScreenplayTreeDocument(tree: tree, meta: doc.meta);
  }

  Future<Screenplay> publish(ScreenplayDraft draft) async {
    final images = collectDraftImages(draft);
    final scriptId = 'script-${DateTime.now().millisecondsSinceEpoch}';
    final persisted = await _persistImages(images, scriptId);

    final screenplay = buildScreenplayFromDraft(
      draft,
      persistedPaths: persisted,
      scriptId: scriptId,
    );

    _documents.insert(0, ScreenplayTreeDocument.fromScreenplay(screenplay));
    await _save();
    notifyListeners();
    return screenplay;
  }

  Future<Screenplay> update(String id, ScreenplayDraft draft) async {
    final index = _documentIndex(id);
    if (index < 0) {
      throw StateError('Screenplay not found: $id');
    }

    final existing = _documents[index].toScreenplay();
    final images = collectDraftImages(draft);
    final persisted = await _persistImages(images, id);

    final screenplay = buildScreenplayFromDraft(
      draft,
      persistedPaths: persisted,
      scriptId: id,
      createdAt: existing.createdAt,
    ).copyWith(
      author: existing.author,
      authorBio: existing.authorBio,
      likes: existing.likes,
      views: existing.views,
      favorites: existing.favorites,
      forkedFromId: existing.forkedFromId,
      forkedFromLocalId: existing.forkedFromLocalId,
      imagesLocalized: existing.imagesLocalized,
      remoteScreenplayId: existing.remoteScreenplayId,
      visibility: existing.visibility,
      treeJsonObjectKey: existing.treeJsonObjectKey,
      publishedAt: existing.publishedAt,
    );

    _documents[index] = ScreenplayTreeDocument.fromScreenplay(
      screenplay,
      existingMeta: _documents[index].meta,
    );
    await _save();
    notifyListeners();
    return screenplay;
  }

  /// Fork remote screenplay or another local fork copy.
  Future<({Screenplay? screenplay, String? error})> fork(Screenplay source) async {
    if (source.isLocal) {
      return _forkFromLocal(source.id);
    }
    final remoteId = int.tryParse(source.id);
    if (remoteId == null) {
      return (screenplay: null, error: '无效的剧本 id');
    }
    return forkFromRemote(remoteId);
  }

  Future<({Screenplay? screenplay, String? error})> forkFromRemote(
    int remoteId,
  ) async {
    final result = await ScreenplayRemoteRepository.instance.fetchRawTree(
      remoteId,
    );
    if (result.error != null || result.tree == null) {
      return (screenplay: null, error: result.error ?? '获取剧本失败');
    }

    return _insertForkedTree(
      tree: result.tree!,
      forkedFromId: remoteId,
      forkedFromLocalId: null,
      sourceTags: const [],
    );
  }

  Future<({Screenplay? screenplay, String? error})> _forkFromLocal(
    String localId,
  ) async {
    final sourceDoc = documentById(localId);
    if (sourceDoc == null) {
      return (screenplay: null, error: '本地副本不存在');
    }

    final source = sourceDoc.toScreenplay();
    final tree = deepCopyJson(sourceDoc.tree);

    return _insertForkedTree(
      tree: tree,
      forkedFromId: source.forkedFromId ??
          int.tryParse(
            (tree['screenplay'] as Map<String, dynamic>?)?['id']?.toString() ??
                '',
          ),
      forkedFromLocalId: localId,
      sourceTags: source.tags,
    );
  }

  Future<({Screenplay? screenplay, String? error})> _insertForkedTree({
    required Map<String, dynamic> tree,
    required int? forkedFromId,
    required String? forkedFromLocalId,
    required List<String> sourceTags,
  }) async {
    final localId = 'script-${DateTime.now().millisecondsSinceEpoch}';
    final numericId = DateTime.now().millisecondsSinceEpoch % 1000000000;

    final screenplayMap = Map<String, dynamic>.from(
      tree['screenplay'] as Map<String, dynamic>,
    );
    screenplayMap['id'] = numericId;
    tree['screenplay'] = screenplayMap;

    final title = screenplayMap['title'] as String? ?? '未命名剧本';
    if (forkedFromLocalId != null) {
      screenplayMap['title'] = '$title（副本）';
    }

    final meta = ScreenplayLocalMeta(
      localId: localId,
      isLocal: true,
      tags: sourceTags,
      author: '我',
      authorBio: 'Fork 副本',
      forkedFromId: forkedFromId,
      forkedFromLocalId: forkedFromLocalId,
      imagesLocalized: false,
      createdAt: DateTime.now(),
    );

    final doc = ScreenplayTreeDocument(tree: tree, meta: meta);
    _documents.insert(0, doc);
    await _save();
    notifyListeners();
    return (screenplay: doc.toScreenplay(), error: null);
  }

  /// Download remote images in a fork copy to local storage.
  Future<({Screenplay? screenplay, String? error})> downloadLocalCopy(
    String localId,
  ) async {
    final index = _documentIndex(localId);
    if (index < 0) {
      return (screenplay: null, error: '剧本不存在');
    }

    final doc = _documents[index];
    if (doc.meta.imagesLocalized) {
      return (screenplay: doc.toScreenplay(), error: null);
    }

    try {
      final tree = deepCopyJson(doc.tree);
      final appDir = await getApplicationDocumentsDirectory();
      final frameDir = Directory('${appDir.path}/screenplays/$localId/frames');
      if (!frameDir.existsSync()) {
        await frameDir.create(recursive: true);
      }

      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      final coverUrl = screenplayMap['cover_url'] as String? ?? '';
      if (ScreenplayImageResolver.isNetworkUrl(coverUrl)) {
        screenplayMap['local_cover_path'] = await _downloadUrl(
          coverUrl,
          frameDir,
          'cover',
        );
      }

      final acts = tree['acts'] as List<dynamic>? ?? [];
      var frameIndex = 0;
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
            if (ScreenplayImageResolver.isNetworkUrl(imageUrl)) {
              final localPath = await _downloadUrl(
                imageUrl,
                frameDir,
                'frame-$frameIndex',
              );
              frameMap['local_image_path'] = localPath;
              frameMap['local_thumbnail_path'] = localPath;
            }
            frameIndex++;
          }
        }
      }

      final updated = ScreenplayTreeDocument(
        tree: tree,
        meta: doc.meta.copyWith(imagesLocalized: true),
      );
      _documents[index] = updated;
      await _save();
      notifyListeners();
      return (screenplay: updated.toScreenplay(), error: null);
    } catch (e) {
      return (screenplay: null, error: e.toString());
    }
  }

  Future<String> _downloadUrl(
    String url,
    Directory frameDir,
    String prefix,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw HttpException('下载失败: ${response.statusCode}');
      }
      final ext = imageFileExtensionFromPath(url);
      final dest = File('${frameDir.path}/$prefix$ext');
      await response.pipe(dest.openWrite());
      return dest.path;
    } finally {
      client.close();
    }
  }

  bool isValidForImport(Screenplay script) => _hasValidFrames(script);

  Future<({ScreenplayTreeDocument? document, String? error})> applyPublishedTree({
    required String localId,
    required Map<String, dynamic> tree,
    required int remoteId,
    int? visibility,
    DateTime? publishedAt,
  }) async {
    final index = _documentIndex(localId);
    if (index < 0) {
      return (document: null, error: '剧本不存在');
    }

    final doc = _documents[index];
    final migrated = migrateDualPaths(
      ScreenplayTreeDocument(
        tree: deepCopyJson(tree),
        meta: doc.meta.copyWith(
          remoteScreenplayId: remoteId,
          visibility: visibility ?? doc.meta.visibility,
          publishedAt: publishedAt ?? DateTime.now(),
        ),
      ),
    );
    return updateDocument(migrated);
  }

  Future<({Screenplay? screenplay, String? error})> importFromRemoteTree(
    int remoteId, {
    bool downloadImages = false,
  }) async {
    final forkResult = await forkFromRemote(remoteId);
    if (forkResult.error != null || forkResult.screenplay == null) {
      return forkResult;
    }

    if (!downloadImages) return forkResult;
    return downloadLocalCopy(forkResult.screenplay!.id);
  }

  Future<({ScreenplayTreeDocument? document, String? error})> updateDocument(
    ScreenplayTreeDocument document,
  ) async {
    final index = _documentIndex(document.meta.localId);
    if (index < 0) {
      return (document: null, error: '剧本不存在');
    }
    if (!_hasValidFrames(document.toScreenplay())) {
      return (document: null, error: '剧本没有有效的画格');
    }
    _documents[index] = document;
    await _save();
    notifyListeners();
    return (document: document, error: null);
  }

  Future<({ScreenplayTreeDocument? document, String? error})> importDocument(
    ScreenplayTreeDocument document,
  ) async {
    if (!_hasValidFrames(document.toScreenplay())) {
      return (document: null, error: '剧本没有有效的画格');
    }
    _documents.insert(0, document);
    await _save();
    notifyListeners();
    return (document: document, error: null);
  }

  Screenplay? findById(String id) {
    for (final doc in _documents) {
      if (doc.meta.localId == id) return doc.toScreenplay();
    }
    return null;
  }

  ScreenplayTreeDocument? documentByRemoteId(int remoteId) {
    for (final doc in _documents) {
      if (doc.meta.remoteScreenplayId == remoteId) return doc;
    }
    return null;
  }

  Screenplay? findByRemoteId(int remoteId) {
    return documentByRemoteId(remoteId)?.toScreenplay();
  }

  int _documentIndex(String localId) {
    return _documents.indexWhere((d) => d.meta.localId == localId);
  }

  Future<bool> delete(String id) async {
    final result = await deleteScreenplay(id);
    return result.success;
  }

  Future<({bool success, String? error})> deleteScreenplay(String localId) async {
    final index = _documentIndex(localId);
    if (index < 0) {
      return (success: false, error: '剧本不存在');
    }

    final doc = _documents[index];
    final remoteId = doc.meta.remoteScreenplayId;
    if (remoteId != null && doc.meta.forkedFromLocalId == null) {
      final remoteError =
          await ScreenplayRemoteDeleteService.instance.deleteScreenplay(remoteId);
      if (remoteError != null) {
        return (success: false, error: remoteError);
      }
    }

    _documents.removeAt(index);
    await _save();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final scriptDir = Directory('${appDir.path}/screenplays/$localId');
      if (scriptDir.existsSync()) {
        await scriptDir.delete(recursive: true);
      }
    } catch (_) {}

    notifyListeners();
    return (success: true, error: null);
  }

  Future<({bool success, String? error})> deleteAct(
    String localId,
    int actIndex,
  ) async {
    final index = _documentIndex(localId);
    if (index < 0) return (success: false, error: '剧本不存在');

    final doc = _documents[index];
    final tree = deepCopyJson(doc.tree);
    final acts = tree['acts'] as List<dynamic>? ?? [];
    if (actIndex < 0 || actIndex >= acts.length) {
      return (success: false, error: '幕不存在');
    }
    if (acts.length <= 1) {
      return (success: false, error: '至少保留一幕');
    }

    final actNode = acts[actIndex] as Map<String, dynamic>;
    final actId = _numericId(actNode['act'] as Map<String, dynamic>);
    final remoteId = doc.meta.remoteScreenplayId;
    if (remoteId != null && doc.meta.forkedFromLocalId == null) {
      final remoteError = await ScreenplayRemoteDeleteService.instance.deleteAct(
        remoteId,
        actId,
      );
      if (remoteError != null) {
        return (success: false, error: remoteError);
      }
    }

    acts.removeAt(actIndex);
    _recalculateTreeCounts(tree);
    return _persistTreeAt(index, doc, tree);
  }

  Future<({bool success, String? error})> deleteScene(
    String localId,
    int actIndex,
    int sceneIndex,
  ) async {
    final index = _documentIndex(localId);
    if (index < 0) return (success: false, error: '剧本不存在');

    final doc = _documents[index];
    final tree = deepCopyJson(doc.tree);
    final acts = tree['acts'] as List<dynamic>? ?? [];
    if (actIndex < 0 || actIndex >= acts.length) {
      return (success: false, error: '幕不存在');
    }

    final actNode = acts[actIndex] as Map<String, dynamic>;
    final scenes = actNode['scenes'] as List<dynamic>? ?? [];
    if (sceneIndex < 0 || sceneIndex >= scenes.length) {
      return (success: false, error: '场不存在');
    }
    if (scenes.length <= 1) {
      return (success: false, error: '至少保留一场');
    }

    final actId = _numericId(actNode['act'] as Map<String, dynamic>);
    final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
    final sceneId = _numericId(sceneNode['scene'] as Map<String, dynamic>);
    final remoteId = doc.meta.remoteScreenplayId;
    if (remoteId != null && doc.meta.forkedFromLocalId == null) {
      final remoteError =
          await ScreenplayRemoteDeleteService.instance.deleteScene(
        remoteId,
        actId,
        sceneId,
      );
      if (remoteError != null) {
        return (success: false, error: remoteError);
      }
    }

    scenes.removeAt(sceneIndex);
    _recalculateTreeCounts(tree);
    return _persistTreeAt(index, doc, tree);
  }

  Future<({bool success, String? error})> deleteFrame(
    String localId,
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    final index = _documentIndex(localId);
    if (index < 0) return (success: false, error: '剧本不存在');

    final doc = _documents[index];
    final tree = deepCopyJson(doc.tree);
    final acts = tree['acts'] as List<dynamic>? ?? [];
    if (actIndex < 0 || actIndex >= acts.length) {
      return (success: false, error: '幕不存在');
    }

    final actNode = acts[actIndex] as Map<String, dynamic>;
    final scenes = actNode['scenes'] as List<dynamic>? ?? [];
    if (sceneIndex < 0 || sceneIndex >= scenes.length) {
      return (success: false, error: '场不存在');
    }

    final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
    final frames = sceneNode['frames'] as List<dynamic>? ?? [];
    if (frameIndex < 0 || frameIndex >= frames.length) {
      return (success: false, error: '画格不存在');
    }
    if (frames.length <= 1) {
      return (success: false, error: '至少保留一画');
    }

    final actId = _numericId(actNode['act'] as Map<String, dynamic>);
    final sceneId = _numericId(sceneNode['scene'] as Map<String, dynamic>);
    final frameId = _numericId(frames[frameIndex] as Map<String, dynamic>);
    final remoteId = doc.meta.remoteScreenplayId;
    if (remoteId != null && doc.meta.forkedFromLocalId == null) {
      final remoteError =
          await ScreenplayRemoteDeleteService.instance.deleteFrame(
        remoteId,
        actId,
        sceneId,
        frameId,
      );
      if (remoteError != null) {
        return (success: false, error: remoteError);
      }
    }

    frames.removeAt(frameIndex);
    for (var i = 0; i < frames.length; i++) {
      (frames[i] as Map<String, dynamic>)['sort'] = i + 1;
    }
    _recalculateTreeCounts(tree);
    return _persistTreeAt(index, doc, tree);
  }

  int _numericId(Map<String, dynamic> node) {
    return (node['id'] as num).toInt();
  }

  void _recalculateTreeCounts(Map<String, dynamic> tree) {
    final acts = tree['acts'] as List<dynamic>? ?? [];
    var totalScenes = 0;
    var totalFrames = 0;

    for (final actNode in acts) {
      final actMap = (actNode as Map<String, dynamic>)['act'] as Map<String, dynamic>;
      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      var actFrames = 0;

      for (final sceneNode in scenes) {
        final sceneMap =
            (sceneNode as Map<String, dynamic>)['scene'] as Map<String, dynamic>;
        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        sceneMap['frame_count'] = frames.length;
        actFrames += frames.length;
        totalFrames += frames.length;
        totalScenes++;
      }

      actMap['scene_count'] = scenes.length;
      actMap['frame_count'] = actFrames;
    }

    final screenplay = tree['screenplay'] as Map<String, dynamic>;
    screenplay['act_count'] = acts.length;
    screenplay['scene_count'] = totalScenes;
    screenplay['frame_count'] = totalFrames;
  }

  Future<({bool success, String? error})> _persistTreeAt(
    int index,
    ScreenplayTreeDocument doc,
    Map<String, dynamic> tree,
  ) async {
    final updated = ScreenplayTreeDocument(tree: tree, meta: doc.meta);
    if (!_hasValidFrames(updated.toScreenplay())) {
      return (success: false, error: '删除后剧本没有有效的画格');
    }

    _documents[index] = updated;
    await _save();
    notifyListeners();
    return (success: true, error: null);
  }

  Future<Map<UploadImageFile, String>> _persistImages(
    List<UploadImageFile> files,
    String scriptId,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final frameDir = Directory('${appDir.path}/screenplays/$scriptId/frames');
    if (!frameDir.existsSync()) {
      await frameDir.create(recursive: true);
    }

    final map = <UploadImageFile, String>{};
    final framesDir = frameDir.path;
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final source = File(file.path);
      if (!source.existsSync()) continue;

      if (_isPersistedFrame(file.path, scriptId, framesDir)) {
        map[file] = file.path;
        continue;
      }

      final safeName = file.name.replaceAll(RegExp(r'[^\w.\-]'), '_');
      final frameId = 'frame-$i';
      final dest = File('${frameDir.path}/$frameId-$safeName');
      await source.copy(dest.path);
      map[file] = dest.path;
    }
    return map;
  }

  bool _isPersistedFrame(String path, String scriptId, String framesDir) {
    final normalized = path.replaceAll('\\', '/');
    return normalized.contains('/screenplays/$scriptId/frames/') ||
        path.startsWith(framesDir);
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final jsonList = _documents.map((d) => d.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
