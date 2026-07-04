import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/production-assets/api/production-assets-api.dart' as asset_api;
import '../../../api/production-assets/data/production-assets-api.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/asset_category_ref.dart';
import '../domain/user_asset_category.dart';
import '../domain/user_asset_item.dart';
import 'asset_catalog.dart';
import 'asset_mapper.dart';

class AssetRepository extends ChangeNotifier {
  AssetRepository._();

  static final AssetRepository instance = AssetRepository._();

  static const _categoriesKey = 'rc0_user_asset_categories_v1';
  static const _itemsKey = 'rc0_user_asset_items_v1';

  final List<UserAssetCategory> _userCategories = [];
  final List<UserAssetItem> _items = [];
  bool _loaded = false;
  String? _lastError;

  bool get isLoaded => _loaded;
  String? get lastError => _lastError;

  List<WikiAssetDomain> get builtinDomains => AssetCatalog.builtinDomains;

  List<UserAssetCategory> get userCategories {
    final list = List<UserAssetCategory>.from(_userCategories);
    list.sort((a, b) => a.sort.compareTo(b.sort));
    return list;
  }

  List<AssetCategoryRef> get allCategoryRefs => [
        ...AssetCatalog.allBuiltinCategoryRefs(),
        ..._userCategories.map(
          (c) => AssetCategoryRef(id: c.id, label: c.label),
        ),
      ];

  Future<void> load() async {
    if (_loaded) return;
    await _loadLocal();
    _loaded = true;
    notifyListeners();

    if (AuthRepository.instance.hasAuthToken) {
      unawaited(refreshFromApi());
    }
  }

  Future<void> refreshFromApi() async {
    if (!AuthRepository.instance.isLoggedIn) return;
    _lastError = null;

    final categories = <UserAssetCategory>[];
    final items = <UserAssetItem>[];

    await asset_api.listProductionAssetCategories(
      ok: (list) => categories.addAll(list.map(categoryFromApi)),
      fail: (msg) => _lastError = msg,
    );

    await asset_api.listProductionAssetItems(
      ok: (list) => items.addAll(list.map(itemFromApi)),
      fail: (msg) => _lastError ??= msg,
    );

    if (categories.isNotEmpty || AuthRepository.instance.isLoggedIn) {
      _userCategories
        ..clear()
        ..addAll(categories);
    }

    if (items.isNotEmpty || AuthRepository.instance.isLoggedIn) {
      _mergeRemoteItems(items);
    }

    await Future.wait([_persistCategories(), _persistItems()]);
    notifyListeners();
  }

  void _mergeRemoteItems(List<UserAssetItem> remoteItems) {
    final remoteIds = remoteItems.map((i) => i.remoteId).whereType<int>().toSet();
    _items.removeWhere(
      (item) => item.remoteId != null && !remoteIds.contains(item.remoteId),
    );
    for (final remote in remoteItems) {
      final index = _items.indexWhere((i) => i.remoteId == remote.remoteId);
      if (index >= 0) {
        _items[index] = remote;
      } else {
        _items.insert(0, remote);
      }
    }
  }

  /// Clears in-memory state so tests can re-[load] with mock prefs.
  @visibleForTesting
  Future<void> resetForTest() async {
    _loaded = false;
    _userCategories.clear();
    _items.clear();
    _lastError = null;
  }

  List<UserAssetItem> itemsForCategory(String categoryId) {
    return _items
        .where((item) => item.categoryId == categoryId)
        .toList()
      ..sort((a, b) {
        final aTime = a.updatedAt ?? a.createdAt ?? DateTime(0);
        final bTime = b.updatedAt ?? b.createdAt ?? DateTime(0);
        return bTime.compareTo(aTime);
      });
  }

  UserAssetCategory? findUserCategory(String id) {
    for (final category in _userCategories) {
      if (category.id == id) return category;
    }
    return null;
  }

  UserAssetItem? findItem(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  AssetCategoryRef? resolveCategoryRef(String categoryId) {
    final builtin = AssetCatalog.domainForCategoryId(categoryId);
    if (builtin != null) return builtin.categoryRef;
    final user = findUserCategory(categoryId);
    if (user != null) {
      return AssetCategoryRef(id: user.id, label: user.label);
    }
    return null;
  }

  Future<UserAssetCategory> createUserCategory({required String label}) async {
    final trimmed = label.trim();

    if (AuthRepository.instance.isLoggedIn) {
      UserAssetCategory? created;
      String? error;
      await asset_api.createProductionAssetCategory(
        body: ProductionAssetCategoryWriteBody(
          label: trimmed,
          sort: _userCategories.length,
        ),
        ok: (item) => created = categoryFromApi(item),
        fail: (msg) => error = msg,
      );
      if (created != null) {
        _userCategories.add(created!);
        await _persistCategories();
        notifyListeners();
        return created!;
      }
      _lastError = error;
    }

    final category = UserAssetCategory(
      id: _nextCategoryId(),
      label: trimmed,
      sort: _userCategories.length,
      createdAt: DateTime.now(),
    );
    _userCategories.add(category);
    await _persistCategories();
    notifyListeners();
    return category;
  }

  Future<String?> updateUserCategory({
    required String id,
    required String label,
  }) async {
    final index = _userCategories.indexWhere((c) => c.id == id);
    if (index < 0) return '分类不存在';

    final existing = _userCategories[index];
    final updated = existing.copyWith(label: label.trim());

    if (existing.remoteId != null && AuthRepository.instance.isLoggedIn) {
      UserAssetCategory? remote;
      String? error;
      await asset_api.updateProductionAssetCategory(
        existing.remoteId!,
        body: categoryToUpdateBody(updated),
        ok: (item) => remote = categoryFromApi(item),
        fail: (msg) => error = msg,
      );
      if (remote != null) {
        _userCategories[index] = remote!;
        await _persistCategories();
        notifyListeners();
        return null;
      }
      _lastError = error;
      return error;
    }

    _userCategories[index] = updated;
    await _persistCategories();
    notifyListeners();
    return null;
  }

  Future<String?> deleteUserCategory(String id) async {
    final index = _userCategories.indexWhere((c) => c.id == id);
    if (index < 0) return '分类不存在';
    final existing = _userCategories[index];

    if (existing.remoteId != null && AuthRepository.instance.isLoggedIn) {
      String? error;
      await asset_api.deleteProductionAssetCategory(
        existing.remoteId!,
        fail: (msg) => error = msg,
      );
      if (error != null) {
        _lastError = error;
        return error;
      }
    }

    _userCategories.removeAt(index);
    _items.removeWhere((item) => item.categoryId == id);
    await Future.wait([_persistCategories(), _persistItems()]);
    notifyListeners();
    return null;
  }

  Future<UserAssetItem> createItem({
    required String categoryId,
    required String name,
    String brand = '',
    String model = '',
    String notes = '',
  }) async {
    final now = DateTime.now();
    final draft = UserAssetItem(
      id: _nextItemId(),
      categoryId: categoryId,
      name: name.trim(),
      brand: brand.trim(),
      model: model.trim(),
      notes: notes.trim(),
      createdAt: now,
      updatedAt: now,
    );

    if (AuthRepository.instance.isLoggedIn) {
      final userCategory = findUserCategoryByLocalId(_userCategories, categoryId);
      UserAssetItem? created;
      String? error;
      await asset_api.createProductionAssetItem(
        body: itemToWriteBody(draft, userCategory),
        ok: (item) => created = itemFromApi(item),
        fail: (msg) => error = msg,
      );
      if (created != null) {
        _items.insert(0, created!);
        await _persistItems();
        notifyListeners();
        return created!;
      }
      _lastError = error;
    }

    _items.insert(0, draft);
    await _persistItems();
    notifyListeners();
    return draft;
  }

  Future<String?> updateItem(UserAssetItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index < 0) return '资产不存在';

    final updated = item.copyWith(updatedAt: DateTime.now());

    if (item.remoteId != null && AuthRepository.instance.isLoggedIn) {
      final userCategory =
          findUserCategoryByLocalId(_userCategories, updated.categoryId);
      UserAssetItem? remote;
      String? error;
      await asset_api.updateProductionAssetItem(
        item.remoteId!,
        body: itemToUpdateBody(updated, userCategory),
        ok: (dto) => remote = itemFromApi(dto),
        fail: (msg) => error = msg,
      );
      if (remote != null) {
        _items[index] = remote!;
        await _persistItems();
        notifyListeners();
        return null;
      }
      _lastError = error;
      return error;
    }

    _items[index] = updated;
    await _persistItems();
    notifyListeners();
    return null;
  }

  Future<String?> deleteItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return '资产不存在';
    final existing = _items[index];

    if (existing.remoteId != null && AuthRepository.instance.isLoggedIn) {
      String? error;
      await asset_api.deleteProductionAssetItem(
        existing.remoteId!,
        fail: (msg) => error = msg,
      );
      if (error != null) {
        _lastError = error;
        return error;
      }
    }

    _items.removeAt(index);
    await _persistItems();
    notifyListeners();
    return null;
  }

  String _nextCategoryId() =>
      'user-cat-${DateTime.now().microsecondsSinceEpoch}';

  String _nextItemId() => 'user-asset-${DateTime.now().microsecondsSinceEpoch}';

  Future<void> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _userCategories
      ..clear()
      ..addAll(_decodeCategories(prefs.getString(_categoriesKey)));
    _items
      ..clear()
      ..addAll(_decodeItems(prefs.getString(_itemsKey)));
  }

  List<UserAssetCategory> _decodeCategories(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(UserAssetCategory.fromJson)
          .where((c) => c.id.isNotEmpty && c.label.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<UserAssetItem> _decodeItems(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(UserAssetItem.fromJson)
          .where((i) => i.id.isNotEmpty && i.categoryId.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _categoriesKey,
      jsonEncode(_userCategories.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> _persistItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _itemsKey,
      jsonEncode(_items.map((i) => i.toJson()).toList()),
    );
  }
}
