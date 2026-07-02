import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/lighting_scheme.dart';
import 'lighting_preset_catalog.dart';

class LightingRepository extends ChangeNotifier {
  LightingRepository._();

  static final LightingRepository instance = LightingRepository._();

  static const _userSchemesKey = 'rc0_lighting_schemes';
  static const _favoriteIdsKey = 'rc0_lighting_favorite_ids';

  final List<LightingScheme> _userSchemes = [];
  final Set<String> _favoriteIds = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<LightingScheme> get builtInSchemes => LightingPresetCatalog.all;

  List<LightingScheme> get userSchemes => List.unmodifiable(_userSchemes);

  List<LightingScheme> get favoriteSchemes {
    final result = <LightingScheme>[];
    for (final scheme in [...builtInSchemes, ..._userSchemes]) {
      if (_favoriteIds.contains(scheme.id)) {
        result.add(scheme.copyWith(favorite: true));
      }
    }
    return result;
  }

  List<LightingScheme> schemesForCategory(LightingPresetCategory category) {
    if (category == LightingPresetCategory.favorites) {
      return favoriteSchemes;
    }
    final builtIn = LightingPresetCatalog.forCategory(category);
  final user = _userSchemes.where((s) => s.category == category);
    return [...builtIn, ...user];
  }

  LightingScheme? findById(String id) {
    final builtIn = LightingPresetCatalog.findById(id);
    if (builtIn != null) return builtIn;
    for (final scheme in _userSchemes) {
      if (scheme.id == id) return scheme;
    }
    return null;
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userSchemesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _userSchemes
          ..clear()
          ..addAll(
            list
                .whereType<Map<String, dynamic>>()
                .map(LightingScheme.fromJson),
          );
      } catch (_) {
        _userSchemes.clear();
      }
    }
    final favRaw = prefs.getStringList(_favoriteIdsKey) ?? const [];
    _favoriteIds
      ..clear()
      ..addAll(favRaw);
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveUserScheme(LightingScheme scheme) async {
    final index = _userSchemes.indexWhere((s) => s.id == scheme.id);
    final copy = scheme.copyWith(isBuiltIn: false);
    if (index >= 0) {
      _userSchemes[index] = copy;
    } else {
      _userSchemes.insert(0, copy);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteUserScheme(String id) async {
    _userSchemes.removeWhere((s) => s.id == id);
    _favoriteIds.remove(id);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteIdsKey, _favoriteIds.toList());
    notifyListeners();
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_userSchemes.map((s) => s.toJson()).toList());
    await prefs.setString(_userSchemesKey, encoded);
    await prefs.setStringList(_favoriteIdsKey, _favoriteIds.toList());
  }
}
