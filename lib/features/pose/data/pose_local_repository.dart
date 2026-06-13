import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/pose_item.dart';
import '../../upload/domain/upload_image_file.dart';

class PoseLocalRepository extends ChangeNotifier {
  PoseLocalRepository._();

  static final PoseLocalRepository instance = PoseLocalRepository._();

  static const _storageKey = 'rc0_local_poses';

  SharedPreferences? _prefs;
  final List<PoseItem> _localPoses = [];

  List<PoseItem> get localPoses => List.unmodifiable(_localPoses);

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_storageKey);
    _localPoses.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final pose = PoseItem.fromJson(item as Map<String, dynamic>);
        if (pose.imagePaths.isNotEmpty &&
            File(pose.imagePaths.first).existsSync()) {
          _localPoses.add(pose);
        }
      }
    }
    notifyListeners();
  }

  PoseItem? findById(String id) {
    for (final pose in _localPoses) {
      if (pose.id == id) return pose;
    }
    return null;
  }

  Future<PoseItem> publish({
    required String title,
    required String description,
    required List<String> tags,
    required List<UploadImageFile> images,
  }) async {
    final id = 'local-${DateTime.now().millisecondsSinceEpoch}';
    final savedPaths = await _persistImages(images, id);

    final pose = PoseItem(
      id: id,
      title: title.trim().isEmpty ? '未命名动作' : title.trim(),
      tags: tags,
      likes: 0,
      views: 0,
      favorites: 0,
      description: description.trim(),
      author: '我',
      authorBio: '本地发布',
      coverImagePath: savedPaths.isNotEmpty ? savedPaths.first : null,
      imagePaths: savedPaths,
      isLocal: true,
      createdAt: DateTime.now(),
    );

    _localPoses.insert(0, pose);
    await _save();
    notifyListeners();
    return pose;
  }

  Future<List<String>> _persistImages(
    List<UploadImageFile> files,
    String poseId,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final poseDir = Directory('${appDir.path}/poses/$poseId');
    if (!poseDir.existsSync()) {
      await poseDir.create(recursive: true);
    }

    final saved = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final source = File(file.path);
      if (!source.existsSync()) continue;

      final safeName = file.name.replaceAll(RegExp(r'[^\w.\-]'), '_');
      final dest = File('${poseDir.path}/$i-$safeName');
      await source.copy(dest.path);
      saved.add(dest.path);
    }
    return saved;
  }

  Future<void> _save() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final jsonList = _localPoses.map((p) => p.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
