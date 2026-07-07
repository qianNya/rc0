import 'package:flutter/foundation.dart';

import '../../../api/community/api/community-api.dart' as community_api;
import '../../../api/community/data/community-api.dart';
import '../../../core/network/api_callback.dart';
import '../../../core/auth/auth_bridge.dart';

class ScreenplayTag {
  const ScreenplayTag({
    required this.id,
    required this.name,
    required this.slug,
    required this.namespace,
  });

  final int id;
  final String name;
  final String slug;
  final String namespace;
}

/// Syncs screenplay tags with `GET/POST /tags` community API.
class ScreenplayTagsRepository extends ChangeNotifier {
  ScreenplayTagsRepository._();

  static final ScreenplayTagsRepository instance = ScreenplayTagsRepository._();

  final List<ScreenplayTag> _tags = [];
  bool _loading = false;
  String? _error;
  String _namespace = 'default';

  List<ScreenplayTag> get tags => List.unmodifiable(_tags);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> initialize() async {
    AuthBridge.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!AuthBridge.isLoggedIn) {
      _tags.clear();
      _error = null;
      notifyListeners();
    }
  }

  ScreenplayTag _fromDto(ScreenplayTagItem dto) {
    return ScreenplayTag(
      id: dto.id.toInt(),
      name: dto.name,
      slug: dto.slug,
      namespace: dto.namespace,
    );
  }

  Future<void> loadTags({String namespace = 'default'}) async {
    if (!AuthBridge.isLoggedIn) {
      _tags.clear();
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _namespace = namespace;
    notifyListeners();

    final (resp, error) = await apiCallback<ListScreenplayTagsResp>(
      ({ok, fail, eventually}) => community_api.listScreenplayTags(
        namespace: namespace,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    _loading = false;
    if (error != null) {
      _error = error;
    } else {
      _tags
        ..clear()
        ..addAll((resp?.list ?? []).map(_fromDto));
      _error = null;
    }
    notifyListeners();
  }

  List<String> get suggestedNames => _tags.map((t) => t.name).toList();

  int? tagIdForName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    for (final tag in _tags) {
      if (tag.name == trimmed || tag.slug == trimmed.toLowerCase()) {
        return tag.id;
      }
    }
    return null;
  }

  /// Creates a tag in the remote catalog (when logged in).
  Future<String?> createTagByName(String name) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }
    if (_tags.isEmpty) {
      await loadTags(namespace: _namespace);
    }
    final id = await _ensureTagId(name);
    if (id == null) return '创建标签失败';
    return null;
  }

  Future<int?> _ensureTagId(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final existing = _tags.where(
      (t) => t.name == trimmed || t.slug == trimmed.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first.id;

    final (created, error) = await apiCallback<ScreenplayTagItem>(
      ({ok, fail, eventually}) => community_api.createScreenplayTag(
        name: trimmed,
        namespace: _namespace,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null || created == null) return null;

    final tag = _fromDto(created);
    if (!_tags.any((t) => t.id == tag.id)) {
      _tags.add(tag);
      notifyListeners();
    }
    return tag.id;
  }

  /// Syncs screenplay tags with diff add/remove (creates tags if needed).
  Future<String?> applyTagsToScreenplay({
    required int screenplayId,
    required List<String> currentNames,
    required Set<String> desiredNames,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }

    if (_tags.isEmpty) {
      await loadTags(namespace: _namespace);
    }

    final current = currentNames.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    final desired = desiredNames.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();

    final toAdd = desired.difference(current);
    final toRemove = current.difference(desired);

    for (final name in toAdd) {
      final tagId = await _ensureTagId(name);
      if (tagId == null) continue;

      final (_, error) = await apiCallback<Map<String, dynamic>>(
        ({ok, fail, eventually}) => community_api.tagScreenplay(
          screenplayId,
          tagId: tagId,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
      if (error != null) return error;
    }

    for (final name in toRemove) {
      final tagId = tagIdForName(name);
      if (tagId == null) continue;

      final (_, error) = await apiCallback<Map<String, dynamic>>(
        ({ok, fail, eventually}) => community_api.untagScreenplay(
          screenplayId,
          tagId,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
      if (error != null) return error;
    }

    return null;
  }

  /// Adds all [desiredNames] to remote screenplay (creates tags if needed).
  Future<String?> syncTags(int screenplayId, Set<String> desiredNames) async {
    return applyTagsToScreenplay(
      screenplayId: screenplayId,
      currentNames: const [],
      desiredNames: desiredNames,
    );
  }
}
