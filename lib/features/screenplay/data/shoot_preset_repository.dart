import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/cine-preset/api/cine-preset-api.dart' as cine_api;
import '../../../api/cine-preset/data/cine-preset-api.dart';
import '../../../core/data/preset_catalog.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/shoot_params.dart';
import '../domain/shoot_preset.dart';
import 'shoot_preset_mapper.dart';

class ShootPresetRepository extends ChangeNotifier {
  ShootPresetRepository._();

  static final ShootPresetRepository instance = ShootPresetRepository._();

  static const _cacheKey = 'shoot_presets_cache_v1';
  static const _recentKey = 'shoot_presets_recent_v1';
  static const _maxRecent = 10;

  final List<ShootPreset> _builtin = List<ShootPreset>.from(
    PresetCatalog.builtInShootPresets,
  );
  final List<ShootPreset> _user = [];
  final List<ShootPreset> _community = [];
  final List<String> _recentIds = [];
  bool _loaded = false;
  String? _lastError;

  String? get lastError => _lastError;
  bool get isLoaded => _loaded;

  List<ShootPreset> get allPresets => [..._builtin, ..._user, ..._community];

  List<ShootPreset> get builtinPresets => List.unmodifiable(_builtin);

  List<ShootPreset> get userPresets => List.unmodifiable(_user);

  List<ShootPreset> get communityPresets => List.unmodifiable(_community);

  List<ShootPreset> get recentPresets {
    final seen = <String>{};
    final result = <ShootPreset>[];
    for (final id in _recentIds) {
      if (!seen.add(id)) continue;
      final preset = findById(id);
      if (preset != null) result.add(preset);
    }
    return result;
  }

  ShootPreset? findById(String id) {
    for (final p in allPresets) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> load() async {
    await Future.wait([_loadCache(), _loadRecent()]);
    if (AuthRepository.instance.isLoggedIn) {
      await refreshFromApi();
    } else if (_builtin.isEmpty) {
      _builtin.addAll(PresetCatalog.builtInShootPresets);
    }
    _ensureCommunityFallback();
    _loaded = true;
    notifyListeners();
  }

  Future<void> refreshFromApi() async {
    _lastError = null;
    final builtin = <ShootPreset>[];
    final user = <ShootPreset>[];
    final community = <ShootPreset>[];

    await cine_api.listCinePresets(
      scope: 0,
      ok: (items) => builtin.addAll(items.map(shootPresetFromApi)),
      fail: (msg) => _lastError = msg,
    );

    await cine_api.listCinePresets(
      scope: 1,
      ok: (items) => community.addAll(items.map(shootPresetFromApi)),
      fail: (msg) => _lastError ??= msg,
    );

    if (AuthRepository.instance.isLoggedIn) {
      await cine_api.listMyCinePresets(
        ok: (items) => user.addAll(items.map(shootPresetFromApi)),
        fail: (msg) => _lastError ??= msg,
      );
    }

    if (builtin.isNotEmpty) {
      _builtin
        ..clear()
        ..addAll(_mergeCatalogMetadata(builtin, PresetCatalog.builtInShootPresets));
    } else if (_builtin.isEmpty) {
      _builtin.addAll(PresetCatalog.builtInShootPresets);
    }

    _user
      ..clear()
      ..addAll(user);

    if (community.isNotEmpty) {
      _community
        ..clear()
        ..addAll(
          _mergeCatalogMetadata(community, PresetCatalog.communityShootPresets),
        );
    } else {
      _ensureCommunityFallback();
    }

    await _saveCache();
    notifyListeners();
  }

  void _ensureCommunityFallback() {
    if (_community.isNotEmpty) return;
    _community
      ..clear()
      ..addAll(PresetCatalog.communityShootPresets);
  }

  List<ShootPreset> _mergeCatalogMetadata(
    List<ShootPreset> fromApi,
    List<ShootPreset> catalog,
  ) {
    final byLabel = {for (final p in catalog) p.label: p};
    return fromApi
        .map((p) {
          final seed = byLabel[p.label];
          if (seed == null) return p;
          return p.copyWith(
            likeCount: p.likeCount ?? seed.likeCount,
            usageCount: p.usageCount ?? seed.usageCount,
            downloadCount: p.downloadCount ?? seed.downloadCount,
            favoriteCount: p.favoriteCount ?? seed.favoriteCount,
            rating: p.rating ?? seed.rating,
            authorName: p.authorName ?? seed.authorName,
            categoryId: p.categoryId ?? seed.categoryId,
            coverImageUrl: p.coverImageUrl ?? seed.coverImageUrl,
          );
        })
        .toList(growable: false);
  }

  Future<void> recordUsage(ShootPreset preset) async {
    _recentIds.remove(preset.id);
    _recentIds.insert(0, preset.id);
    while (_recentIds.length > _maxRecent) {
      _recentIds.removeLast();
    }
    await _saveRecent();
    notifyListeners();
  }

  Future<({ShootPreset? preset, String? error})> duplicate(
    ShootPreset source,
  ) async {
    final label = source.label.contains('副本')
        ? source.label
        : '${source.label} 副本';
    return create(
      label: label,
      params: source.params,
      subtitle: source.displaySubtitle,
    );
  }

  Future<({ShootPreset? preset, String? error})> create({
    required String label,
    required ShootParams params,
    String? subtitle,
  }) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return _createLocal(label: label, params: params, subtitle: subtitle);
    }

    String? error;
    ShootPreset? created;
    await cine_api.createCinePreset(
      body: CinePresetWriteBody(
        name: label,
        description: subtitle ?? ShootPreset.subtitleFromParams(params),
        params: shootParamsToApiJson(params),
      ),
      ok: (item) => created = shootPresetFromApi(item),
      fail: (msg) => error = msg,
    );
    if (created != null) {
      _user.insert(0, created!);
      await _saveCache();
      notifyListeners();
      return (preset: created, error: null);
    }
    return (preset: null, error: error ?? '创建失败');
  }

  Future<({ShootPreset? preset, String? error})> update(
    String id, {
    String? label,
    ShootParams? params,
    String? subtitle,
  }) async {
    final existing = findById(id);
    if (existing == null) return (preset: null, error: '预设不存在');
    if (existing.isBuiltIn) return (preset: null, error: '官方预设不可编辑');

    if (existing.remoteId != null && AuthRepository.instance.isLoggedIn) {
      String? error;
      ShootPreset? updated;
      await cine_api.updateCinePreset(
        existing.remoteId!,
        body: CinePresetUpdateBody(
          name: label,
          description: subtitle,
          params: params != null ? shootParamsToApiJson(params) : null,
        ),
        ok: (item) => updated = shootPresetFromApi(item),
        fail: (msg) => error = msg,
      );
      if (updated != null) {
        _replaceUser(updated!);
        await _saveCache();
        notifyListeners();
        return (preset: updated, error: null);
      }
      return (preset: null, error: error ?? '更新失败');
    }

    final next = existing.copyWith(
      label: label,
      params: params,
      subtitle: subtitle,
      updatedAt: DateTime.now(),
    );
    _replaceUser(next);
    await _saveCache();
    notifyListeners();
    return (preset: next, error: null);
  }

  Future<String?> delete(String id) async {
    final existing = findById(id);
    if (existing == null) return '预设不存在';
    if (existing.isBuiltIn) return '官方预设不可删除';

    if (existing.remoteId != null && AuthRepository.instance.isLoggedIn) {
      String? error;
      await cine_api.deleteCinePreset(
        existing.remoteId!,
        fail: (msg) => error = msg,
      );
      if (error != null) return error;
    }

    _user.removeWhere((p) => p.id == id);
    _recentIds.remove(id);
    await Future.wait([_saveCache(), _saveRecent()]);
    notifyListeners();
    return null;
  }

  Future<({ShootPreset? preset, String? error})> _createLocal({
    required String label,
    required ShootParams params,
    String? subtitle,
  }) async {
    final preset = ShootPreset(
      id: 'preset-local-${DateTime.now().microsecondsSinceEpoch}',
      label: label,
      subtitle: subtitle,
      params: params,
      isBuiltIn: false,
      scope: ShootPresetScope.personal,
      createdAt: DateTime.now(),
    );
    _user.insert(0, preset);
    await _saveCache();
    notifyListeners();
    return (preset: preset, error: null);
  }

  void _replaceUser(ShootPreset preset) {
    final index = _user.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      _user[index] = preset;
    }
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final builtinRaw = decoded['builtin'] as List<dynamic>? ?? [];
      final userRaw = decoded['user'] as List<dynamic>? ?? [];
      final communityRaw = decoded['community'] as List<dynamic>? ?? [];
      if (builtinRaw.isNotEmpty) {
        _builtin
          ..clear()
          ..addAll(
            builtinRaw
                .whereType<Map<String, dynamic>>()
                .map(ShootPreset.fromJson),
          );
      }
      _user
        ..clear()
        ..addAll(
          userRaw.whereType<Map<String, dynamic>>().map(ShootPreset.fromJson),
        );
      if (communityRaw.isNotEmpty) {
        _community
          ..clear()
          ..addAll(
            communityRaw
                .whereType<Map<String, dynamic>>()
                .map(ShootPreset.fromJson),
          );
      }
    } catch (_) {
      // ignore corrupt cache
    }
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode({
        'builtin': _builtin.map((p) => p.toJson()).toList(),
        'user': _user.map((p) => p.toJson()).toList(),
        'community': _community.map((p) => p.toJson()).toList(),
      }),
    );
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_recentKey);
    if (raw == null) return;
    _recentIds
      ..clear()
      ..addAll(raw);
  }

  Future<void> _saveRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, List<String>.from(_recentIds));
  }
}
