import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SceneLocalStore {
  SceneLocalStore._();

  static final SceneLocalStore instance = SceneLocalStore._();

  static const _keyPrefix = 'rc0_scene_local_';
  static const _entriesKey = 'rc0_scene_user_entries';
  static const _useCountKey = 'rc0_scene_use_counts';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Set<String>> favoriteIds() async {
    final prefs = await _ensurePrefs();
    return prefs.getStringList('${_keyPrefix}favorites')?.toSet() ?? {};
  }

  Future<bool> isFavorite(String sceneId) async {
    final ids = await favoriteIds();
    return ids.contains(sceneId);
  }

  Future<void> setFavorite(String sceneId, bool favorite) async {
    final prefs = await _ensurePrefs();
    final ids = await favoriteIds();
    if (favorite) {
      ids.add(sceneId);
    } else {
      ids.remove(sceneId);
    }
    await prefs.setStringList('${_keyPrefix}favorites', ids.toList());
  }

  Future<Set<String>> ownedIds() async {
    final prefs = await _ensurePrefs();
    return prefs.getStringList('${_keyPrefix}owned')?.toSet() ?? {};
  }

  Future<void> markOwned(String sceneId) async {
    final prefs = await _ensurePrefs();
    final ids = await ownedIds();
    ids.add(sceneId);
    await prefs.setStringList('${_keyPrefix}owned', ids.toList());
  }

  Future<String?> localCoverPath(String sceneId) async {
    final prefs = await _ensurePrefs();
    return prefs.getString('${_keyPrefix}cover_$sceneId');
  }

  Future<void> setLocalCoverPath(String sceneId, String? path) async {
    final prefs = await _ensurePrefs();
    final key = '${_keyPrefix}cover_$sceneId';
    if (path == null || path.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, path);
    }
  }

  Future<List<String>> referenceImageUrls(String sceneId) async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString('${_keyPrefix}ref_$sceneId');
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList(growable: false);
  }

  Future<void> setReferenceImageUrls(String sceneId, List<String> urls) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      '${_keyPrefix}ref_$sceneId',
      jsonEncode(urls),
    );
  }

  Future<int> extraUseCount(String sceneId) async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(_useCountKey);
    if (raw == null || raw.isEmpty) return 0;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return 0;
    return (decoded[sceneId] as num?)?.toInt() ?? 0;
  }

  Future<void> incrementUseCount(String sceneId) async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString(_useCountKey);
    final map = <String, int>{};
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        decoded.forEach((key, value) {
          if (key is String && value is num) map[key] = value.toInt();
        });
      }
    }
    map[sceneId] = (map[sceneId] ?? 0) + 1;
    await prefs.setString(_useCountKey, jsonEncode(map));
  }

  Future<String?> loadUserEntriesJson() async {
    final prefs = await _ensurePrefs();
    return prefs.getString(_entriesKey);
  }

  Future<void> saveUserEntriesJson(String json) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(_entriesKey, json);
  }
}
