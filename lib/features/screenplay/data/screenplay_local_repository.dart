import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/pose_item.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/domain/screenplay/screenplay_adapter.dart';
import '../../upload/domain/upload_image_file.dart';
import 'screenplay_draft.dart';

class ScreenplayLocalRepository extends ChangeNotifier {
  ScreenplayLocalRepository._();

  static final ScreenplayLocalRepository instance =
      ScreenplayLocalRepository._();

  static const _storageKey = 'rc0_screenplays';
  static const _legacyStorageKey = 'rc0_local_poses';

  SharedPreferences? _prefs;
  final List<Screenplay> _localScreenplays = [];

  List<Screenplay> get localScreenplays => List.unmodifiable(_localScreenplays);

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    _localScreenplays.clear();

    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final script = Screenplay.fromJson(item as Map<String, dynamic>);
        if (_hasValidFrames(script)) {
          _localScreenplays.add(script);
        }
      }
    } else {
      await _migrateLegacyPoses(prefs);
    }

    notifyListeners();
  }

  Future<void> _migrateLegacyPoses(SharedPreferences prefs) async {
    final legacyRaw = prefs.getString(_legacyStorageKey);
    if (legacyRaw == null || legacyRaw.isEmpty) return;

    final list = jsonDecode(legacyRaw) as List<dynamic>;
    for (final item in list) {
      final pose = PoseItem.fromJson(item as Map<String, dynamic>);
      if (pose.imagePaths.isEmpty && pose.coverImagePath == null) continue;
      final script = migrateFromPoseItem(pose);
      if (_hasValidFrames(script)) {
        _localScreenplays.add(script);
      }
    }

    if (_localScreenplays.isNotEmpty) {
      await _save();
      await prefs.remove(_legacyStorageKey);
    }
  }

  bool _hasValidFrames(Screenplay script) {
    return script.allFrames.any(
      (frame) =>
          frame.imagePath.isNotEmpty && File(frame.imagePath).existsSync(),
    );
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

    _localScreenplays.insert(0, screenplay);
    await _save();
    notifyListeners();
    return screenplay;
  }

  Future<Screenplay> update(String id, ScreenplayDraft draft) async {
    final index = _localScreenplays.indexWhere((s) => s.id == id);
    if (index < 0) {
      throw StateError('Screenplay not found: $id');
    }

    final existing = _localScreenplays[index];
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
    );

    _localScreenplays[index] = screenplay;
    await _save();
    notifyListeners();
    return screenplay;
  }

  Screenplay? findById(String id) {
    for (final script in _localScreenplays) {
      if (script.id == id) return script;
    }
    return null;
  }

  Future<bool> delete(String id) async {
    final index = _localScreenplays.indexWhere((s) => s.id == id);
    if (index < 0) return false;

    _localScreenplays.removeAt(index);
    await _save();

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final scriptDir = Directory('${appDir.path}/screenplays/$id');
      if (scriptDir.existsSync()) {
        await scriptDir.delete(recursive: true);
      }
    } catch (_) {
      // 存储记录已删除，文件清理失败不阻断流程
    }

    notifyListeners();
    return true;
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
    final jsonList = _localScreenplays.map((s) => s.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
