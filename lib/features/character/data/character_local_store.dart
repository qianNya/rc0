import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local sidecar data for characters until backend fields are available.
class CharacterLocalStore {
  CharacterLocalStore._();

  static final CharacterLocalStore instance = CharacterLocalStore._();

  static const _keyPrefix = 'rc0_character_local_';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<String>> referenceImageUrls(int characterId) async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString('${_keyPrefix}ref_$characterId');
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList(growable: false);
  }

  Future<void> setReferenceImageUrls(
    int characterId,
    List<String> urls,
  ) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      '${_keyPrefix}ref_$characterId',
      jsonEncode(urls),
    );
  }

  Future<List<int>> linkedScreenplayIds(int characterId) async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getString('${_keyPrefix}scripts_$characterId');
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .map((e) => e is num ? e.toInt() : int.tryParse('$e'))
        .whereType<int>()
        .toList(growable: false);
  }

  Future<void> setLinkedScreenplayIds(
    int characterId,
    List<int> ids,
  ) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      '${_keyPrefix}scripts_$characterId',
      jsonEncode(ids),
    );
  }

  Future<String?> localCoverPath(int characterId) async {
    final prefs = await _ensurePrefs();
    return prefs.getString('${_keyPrefix}cover_$characterId');
  }

  Future<void> setLocalCoverPath(int characterId, String? path) async {
    final prefs = await _ensurePrefs();
    final key = '${_keyPrefix}cover_$characterId';
    if (path == null || path.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, path);
    }
  }

  Future<Set<int>> favoriteIds() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getStringList('${_keyPrefix}favorites') ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<bool> isFavorite(int characterId) async {
    final ids = await favoriteIds();
    return ids.contains(characterId);
  }

  Future<void> setFavorite(int characterId, bool favorite) async {
    final prefs = await _ensurePrefs();
    final ids = await favoriteIds();
    if (favorite) {
      ids.add(characterId);
    } else {
      ids.remove(characterId);
    }
    await prefs.setStringList(
      '${_keyPrefix}favorites',
      ids.map((id) => '$id').toList(),
    );
  }

  Future<Set<int>> ownedCharacterIds() async {
    final prefs = await _ensurePrefs();
    final raw = prefs.getStringList('${_keyPrefix}owned') ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> markOwned(int characterId) async {
    final prefs = await _ensurePrefs();
    final ids = await ownedCharacterIds();
    ids.add(characterId);
    await prefs.setStringList(
      '${_keyPrefix}owned',
      ids.map((id) => '$id').toList(),
    );
  }
}
