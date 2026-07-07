import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/cine-equipment/api/cine-equipment-api.dart' as equip_api;
import '../../../api/cine-equipment/data/cine-equipment-api.dart';
import '../../../core/auth/auth_bridge.dart';
import '../domain/camera_body.dart';
import '../domain/cine_camera_setup.dart';
import '../domain/equipment_brand.dart';
import '../domain/equipment_category.dart';
import '../domain/lens.dart';
import 'equipment_catalog.dart';
import 'equipment_mapper.dart';
import 'equipment_setup_mapper.dart';

class EquipmentRepository extends ChangeNotifier {
  EquipmentRepository._();

  static final EquipmentRepository instance = EquipmentRepository._();

  static const _userSetupsKey = 'rc0_cine_camera_setups_v2';
  static const _favoriteBodyIdsKey = 'rc0_equipment_favorite_body_ids';
  static const _favoriteLensIdsKey = 'rc0_equipment_favorite_lens_ids';
  static const _favoriteSetupIdsKey = 'rc0_equipment_favorite_setup_ids';
  static const _catalogCacheKey = 'rc0_equipment_catalog_cache_v1';

  final List<CameraBody> _bodies = [];
  final List<Lens> _lenses = [];
  final List<EquipmentBrand> _brands = [];
  final List<CineCameraSetup> _builtinSetups = [];
  final List<CineCameraSetup> _userSetups = [];
  final Set<String> _favoriteBodyIds = {};
  final Set<String> _favoriteLensIds = {};
  final Set<String> _favoriteSetupIds = {};
  bool _loaded = false;
  String? _lastError;

  String? get lastError => _lastError;
  bool get isLoaded => _loaded;

  List<CameraBody> get builtInBodies =>
      List.unmodifiable(_bodies.where((b) => b.isBuiltIn));

  List<CameraBody> get allBodies => List.unmodifiable(_bodies);

  List<Lens> get builtInLenses =>
      List.unmodifiable(_lenses.where((l) => l.isBuiltIn));

  List<Lens> get allLenses => List.unmodifiable(_lenses);

  List<EquipmentBrand> get allBrands => List.unmodifiable(_brands);

  List<CineCameraSetup> get builtInSetups => List.unmodifiable(_builtinSetups);

  List<CineCameraSetup> get userSetups => List.unmodifiable(_userSetups);

  List<CineCameraSetup> get allSetups => [..._builtinSetups, ..._userSetups];

  List<EquipmentBrand> brandsFor({
    required EquipmentCategory category,
    required EquipmentItemKind itemKind,
  }) {
    return _brands
        .where((b) => b.category == category && b.itemKind == itemKind)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
  }

  List<CameraBody> bodiesForCategory(
    EquipmentCategory category, {
    String? brandId,
  }) {
    if (category == EquipmentCategory.favorites) {
      return _bodies
          .where((b) => _favoriteBodyIds.contains(b.id))
          .map((b) => b.copyWith(favorite: true))
          .toList();
    }
    return _bodies
        .where(
          (b) =>
              b.category == category &&
              (brandId == null ||
                  brandId.isEmpty ||
                  b.brandId == brandId),
        )
        .toList();
  }

  List<Lens> lensesForCategory(
    EquipmentCategory category, {
    String? brandId,
  }) {
    if (category == EquipmentCategory.favorites) {
      return _lenses
          .where((l) => _favoriteLensIds.contains(l.id))
          .map((l) => l.copyWith(favorite: true))
          .toList();
    }
    return _lenses
        .where(
          (l) =>
              l.category == category &&
              (brandId == null ||
                  brandId.isEmpty ||
                  l.brandId == brandId),
        )
        .toList();
  }

  List<CineCameraSetup> favoriteSetups() {
    return allSetups
        .where((s) => _favoriteSetupIds.contains(s.id))
        .map((s) => s.copyWith(favorite: true))
        .toList();
  }

  CameraBody? findBodyById(String id) {
    for (final body in _bodies) {
      if (body.id == id) return body;
    }
    return null;
  }

  Lens? findLensById(String id) {
    for (final lens in _lenses) {
      if (lens.id == id) return lens;
    }
    return null;
  }

  CineCameraSetup? findSetupById(String id) {
    for (final setup in allSetups) {
      if (setup.id == id) return setup;
    }
    return null;
  }

  CineCameraSetup? resolveSetup({
    String? setupId,
    Map<String, dynamic>? inlineSetup,
  }) {
    if (setupId != null && setupId.isNotEmpty) {
      final fromRepo = findSetupById(setupId);
      if (fromRepo != null) return fromRepo;
    }
    return EquipmentSetupMapper.setupFromJson(inlineSetup);
  }

  Future<void> load() async {
    if (_loaded) return;
    _seedFromCatalog();
    await _loadLocalSetups();
    await _loadLocalFavorites();
    _loaded = true;
    notifyListeners();

    if (AuthBridge.hasAuthToken) {
      unawaited(refreshFromApi());
    }
  }

  Future<void> refreshFromApi() async {
    _lastError = null;
    final brands = <EquipmentBrand>[];
    final bodies = <CameraBody>[];
    final lenses = <Lens>[];
    final builtinSetups = <CineCameraSetup>[];
    final userSetups = <CineCameraSetup>[];

    await equip_api.listCineEquipmentBrands(
      ok: (items) => brands.addAll(items.map(brandFromApi)),
      fail: (msg) => _lastError = msg,
    );

    await equip_api.listCineCameraBodies(
      ok: (items) => bodies.addAll(items.map(bodyFromApi)),
      fail: (msg) => _lastError ??= msg,
    );

    await equip_api.listCineLenses(
      ok: (items) => lenses.addAll(items.map(lensFromApi)),
      fail: (msg) => _lastError ??= msg,
    );

    await equip_api.listCineCameraSetups(
      scope: 0,
      ok: (items) => builtinSetups.addAll(items.map(setupFromApi)),
      fail: (msg) => _lastError ??= msg,
    );

    if (AuthBridge.isLoggedIn) {
      await equip_api.listMyCineCameraSetups(
        ok: (items) => userSetups.addAll(items.map(setupFromApi)),
        fail: (msg) => _lastError ??= msg,
      );

      await equip_api.listCineEquipmentFavorites(
        ok: (items) => _applyRemoteFavorites(items),
        fail: (msg) => _lastError ??= msg,
      );
    }

    if (bodies.isNotEmpty) {
      _bodies
        ..clear()
        ..addAll(bodies);
    } else if (_bodies.isEmpty) {
      _seedFromCatalog();
    }

    if (lenses.isNotEmpty) {
      _lenses
        ..clear()
        ..addAll(lenses);
    } else if (_lenses.isEmpty) {
      _seedFromCatalog();
    }

    if (brands.isNotEmpty) {
      _brands
        ..clear()
        ..addAll(brands);
    } else {
      _rebuildBrandsFromCatalog();
    }

    if (builtinSetups.isNotEmpty) {
      _builtinSetups
        ..clear()
        ..addAll(builtinSetups);
    } else if (_builtinSetups.isEmpty) {
      _builtinSetups.addAll(EquipmentCatalog.builtInSetups);
    }

    if (userSetups.isNotEmpty || AuthBridge.isLoggedIn) {
      _userSetups
        ..clear()
        ..addAll(userSetups);
      await _persistSetups();
    }

    await _persistCatalogCache();
    notifyListeners();
  }

  void _seedFromCatalog() {
    _bodies
      ..clear()
      ..addAll(EquipmentCatalog.allBodies);
    _lenses
      ..clear()
      ..addAll(EquipmentCatalog.allLenses);
    _builtinSetups
      ..clear()
      ..addAll(EquipmentCatalog.builtInSetups);
    _rebuildBrandsFromCatalog();
  }

  void _rebuildBrandsFromCatalog() {
    _brands
      ..clear()
      ..addAll(EquipmentCatalog.allBrands);
  }

  void _applyRemoteFavorites(List<CineEquipmentFavoriteItem> items) {
    _favoriteBodyIds.clear();
    _favoriteLensIds.clear();
    _favoriteSetupIds.clear();
    for (final item in items) {
      switch (item.itemKind) {
        case 'body':
          _favoriteBodyIds.add(item.itemRef);
        case 'lens':
          _favoriteLensIds.add(item.itemRef);
        case 'setup':
          _favoriteSetupIds.add(item.itemRef);
      }
    }
    unawaited(_persistFavorites());
  }

  Future<void> saveUserSetup(CineCameraSetup setup) async {
    if (AuthBridge.isLoggedIn && setup.remoteId == null) {
      String? error;
      CineCameraSetup? created;
      await equip_api.createCineCameraSetup(
        body: setupToWriteBody(setup),
        ok: (item) => created = setupFromApi(item),
        fail: (msg) => error = msg,
      );
      if (created != null) {
        _userSetups.insert(0, created!.copyWith(isBuiltIn: false));
        await _persistSetups();
        notifyListeners();
        return;
      }
      _lastError = error;
    }

    final index = _userSetups.indexWhere((s) => s.id == setup.id);
    final copy = setup.copyWith(isBuiltIn: false);
    if (index >= 0) {
      if (copy.remoteId != null && AuthBridge.isLoggedIn) {
        String? error;
        CineCameraSetup? updated;
        await equip_api.updateCineCameraSetup(
          copy.remoteId!,
          body: setupToUpdateBody(copy),
          ok: (item) => updated = setupFromApi(item),
          fail: (msg) => error = msg,
        );
        if (updated != null) {
          _userSetups[index] = updated!.copyWith(isBuiltIn: false);
          await _persistSetups();
          notifyListeners();
          return;
        }
        _lastError = error;
      }
      _userSetups[index] = copy;
    } else {
      final local = copy.id.isNotEmpty
          ? copy
          : copy.copyWith(id: nextUserSetupId());
      _userSetups.insert(0, local);
    }
    await _persistSetups();
    notifyListeners();
  }

  Future<String?> deleteUserSetup(String id) async {
    final existing = findSetupById(id);
    if (existing == null) return '?????';
    if (existing.isBuiltIn) return '????????';

    if (existing.remoteId != null && AuthBridge.isLoggedIn) {
      String? error;
      await equip_api.deleteCineCameraSetup(
        existing.remoteId!,
        fail: (msg) => error = msg,
      );
      if (error != null) return error;
    }

    _userSetups.removeWhere((s) => s.id == id);
    _favoriteSetupIds.remove(id);
    await Future.wait([_persistSetups(), _persistFavorites()]);
    notifyListeners();
    return null;
  }

  Future<void> toggleFavorite(EquipmentItemKind kind, String id) async {
    final wasFavorite = isFavorite(kind, id);
    switch (kind) {
      case EquipmentItemKind.body:
        if (wasFavorite) {
          _favoriteBodyIds.remove(id);
        } else {
          _favoriteBodyIds.add(id);
        }
      case EquipmentItemKind.lens:
        if (wasFavorite) {
          _favoriteLensIds.remove(id);
        } else {
          _favoriteLensIds.add(id);
        }
      case EquipmentItemKind.setup:
        if (wasFavorite) {
          _favoriteSetupIds.remove(id);
        } else {
          _favoriteSetupIds.add(id);
        }
    }
    await _persistFavorites();
    notifyListeners();

    if (AuthBridge.isLoggedIn) {
      await equip_api.toggleCineEquipmentFavorite(
        body: CineEquipmentFavoriteToggleBody(
          itemKind: equipmentItemKindApi(kind),
          itemRef: id,
        ),
        fail: (msg) => _lastError = msg,
      );
    }
  }

  bool isFavorite(EquipmentItemKind kind, String id) {
    switch (kind) {
      case EquipmentItemKind.body:
        return _favoriteBodyIds.contains(id);
      case EquipmentItemKind.lens:
        return _favoriteLensIds.contains(id);
      case EquipmentItemKind.setup:
        return _favoriteSetupIds.contains(id);
    }
  }

  String nextUserSetupId() =>
      'user-setup-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _loadLocalSetups() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userSetupsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _userSetups
        ..clear()
        ..addAll(
          list.whereType<Map<String, dynamic>>().map((json) {
            final setup = CineCameraSetup.fromJson(json);
            return setup.copyWith(
              id: json['id'] is String
                  ? json['id'] as String
                  : setup.id,
            );
          }),
        );
    } catch (_) {
      _userSetups.clear();
    }
  }

  Future<void> _loadLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteBodyIds
      ..clear()
      ..addAll(prefs.getStringList(_favoriteBodyIdsKey) ?? const []);
    _favoriteLensIds
      ..clear()
      ..addAll(prefs.getStringList(_favoriteLensIdsKey) ?? const []);
    _favoriteSetupIds
      ..clear()
      ..addAll(prefs.getStringList(_favoriteSetupIdsKey) ?? const []);
  }

  Future<void> _persistSetups() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _userSetups
          .map(
            (s) => {
              ...s.toJson(),
              if (s.remoteId != null) 'remote_id': s.remoteId,
            },
          )
          .toList(),
    );
    await prefs.setString(_userSetupsKey, encoded);
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteBodyIdsKey, _favoriteBodyIds.toList());
    await prefs.setStringList(_favoriteLensIdsKey, _favoriteLensIds.toList());
    await prefs.setStringList(_favoriteSetupIdsKey, _favoriteSetupIds.toList());
  }

  Future<void> _persistCatalogCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _catalogCacheKey,
      jsonEncode({
        'bodies': _bodies.map((b) => b.toJson()).toList(),
        'lenses': _lenses.map((l) => l.toJson()).toList(),
        'brands': _brands.map((b) => b.toJson()).toList(),
      }),
    );
  }
}
