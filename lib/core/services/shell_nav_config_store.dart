import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router/routes.dart';
import '../../shared/widgets/shell_nav_items.dart';

/// Stable id for a swappable bottom-nav entry.
abstract final class ShellNavOptionId {
  static const templates = 'templates';
  static const scene = 'scene';
  static const profile = 'profile';
  static const gallery = 'gallery';
  static const preset = 'preset';
  static const equipment = 'equipment';
  static const character = 'character';
  static const action = 'action';
  static const assets = 'assets';
  static const favorites = 'favorites';

  /// Legacy ids migrated to [templates].
  static const wiki = 'wiki';
  static const community = 'community';

  /// Legacy broken pin (pointed at assets branch); dropped on migrate.
  static const screenplay = 'screenplay';
}

/// Describes one bottom-nav destination (shell branch or stack route).
class ShellNavOption {
  const ShellNavOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.branchIndex,
    this.route,
    this.usePush = false,
    this.group = '其他',
  }) : assert(branchIndex != null || route != null);

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? branchIndex;
  final String? route;
  final bool usePush;
  final String group;

  ShellNavItem toNavItem() {
    return ShellNavItem(
      branchIndex: branchIndex,
      stackRoute: route,
      label: label,
      icon: icon,
      selectedIcon: selectedIcon,
    );
  }

  bool matchesLocation({required int branchIndex, required String path}) {
    if (this.branchIndex != null) {
      return this.branchIndex == branchIndex;
    }
    final route = this.route;
    if (route == null || route.isEmpty) return false;
    if (path == route || path.startsWith('$route/')) return true;
    if (route.contains('?') && path.startsWith(route.split('?').first)) {
      return true;
    }
    return false;
  }
}

/// All entries users can pin to the primary bottom-nav bar.
abstract final class ShellNavCatalog {
  static final options = <ShellNavOption>[
    ShellNavOption(
      id: ShellNavOptionId.templates,
      label: '模板',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront,
      branchIndex: 0,
      group: '主页',
    ),
    ShellNavOption(
      id: ShellNavOptionId.scene,
      label: '场景',
      icon: Icons.landscape_outlined,
      selectedIcon: Icons.landscape,
      branchIndex: 2,
      group: '主页',
    ),
    ShellNavOption(
      id: ShellNavOptionId.assets,
      label: '资产',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      branchIndex: 5,
      group: '主页',
    ),
    ShellNavOption(
      id: ShellNavOptionId.profile,
      label: '我的',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      branchIndex: 3,
      group: '主页',
    ),
    ShellNavOption(
      id: ShellNavOptionId.gallery,
      label: '图库',
      icon: Icons.photo_library_outlined,
      selectedIcon: Icons.photo_library,
      route: AppRoutes.gallery,
      usePush: true,
      group: '扩展',
    ),
    ShellNavOption(
      id: ShellNavOptionId.preset,
      label: '预设',
      icon: Icons.tune_outlined,
      selectedIcon: Icons.tune,
      route: AppRoutes.shootPresetPicker(mode: 'manage'),
      usePush: true,
      group: '扩展',
    ),
    ShellNavOption(
      id: ShellNavOptionId.equipment,
      label: '设备',
      icon: Icons.videocam_outlined,
      selectedIcon: Icons.videocam,
      route: AppRoutes.library,
      usePush: true,
      group: '扩展',
    ),
    ShellNavOption(
      id: ShellNavOptionId.character,
      label: '角色',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      route: AppRoutes.discoveryCharacterWiki,
      usePush: false,
      group: '扩展',
    ),
    ShellNavOption(
      id: ShellNavOptionId.action,
      label: '动作',
      icon: Icons.accessibility_new_outlined,
      selectedIcon: Icons.accessibility_new,
      branchIndex: 4,
      group: '扩展',
    ),
    ShellNavOption(
      id: ShellNavOptionId.favorites,
      label: '收藏',
      icon: Icons.bookmark_outline,
      selectedIcon: Icons.bookmark,
      route: AppRoutes.favorites,
      usePush: true,
      group: '扩展',
    ),
  ];

  static const defaultActiveIds = [
    ShellNavOptionId.templates,
    ShellNavOptionId.scene,
    ShellNavOptionId.assets,
    ShellNavOptionId.profile,
  ];

  static const groupOrder = ['主页', '扩展'];

  /// Maps legacy persisted ids onto the current catalog.
  static String migrateOptionId(String id) {
    switch (id) {
      case ShellNavOptionId.wiki:
      case ShellNavOptionId.community:
        return ShellNavOptionId.templates;
      case ShellNavOptionId.screenplay:
        return ShellNavOptionId.assets;
      default:
        return id;
    }
  }

  static ShellNavOption optionById(String id) {
    final migrated = migrateOptionId(id);
    return options.firstWhere(
      (o) => o.id == migrated,
      orElse: () => options.first,
    );
  }

  static Map<String, List<ShellNavOption>> groupedOptions() {
    final grouped = <String, List<ShellNavOption>>{};
    for (final option in options) {
      grouped.putIfAbsent(option.group, () => []).add(option);
    }
    return grouped;
  }
}

/// Persists the customizable primary bottom-nav bar (1–[maxTabs] entries).
class ShellNavConfigStore extends ChangeNotifier {
  ShellNavConfigStore._();

  static final ShellNavConfigStore instance = ShellNavConfigStore._();

  static const _prefKeyActive = 'rc0_shell_nav_active';
  static const _legacyPrefPrefix = 'rc0_shell_nav_slot_';
  static const minTabs = 1;
  static const maxTabs = 5;

  final List<String> _activeIds =
      List<String>.from(ShellNavCatalog.defaultActiveIds);
  bool _initialized = false;

  bool get isInitialized => _initialized;
  int get slotCount => _activeIds.length;
  bool get canAddMore => _activeIds.length < maxTabs;
  bool get canRemove => _activeIds.length > minTabs;

  List<String> get activeOptionIds => List.unmodifiable(_activeIds);

  List<ShellNavOption> get slotOptions => List.unmodifiable(
        _activeIds.map(ShellNavCatalog.optionById),
      );

  List<ShellNavItem> get navItems =>
      slotOptions.map((o) => o.toNavItem()).toList(growable: false);

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefKeyActive);
    if (stored != null && stored.isNotEmpty) {
      _activeIds
        ..clear()
        ..addAll(_parseIdList(stored));
    } else {
      _activeIds
        ..clear()
        ..addAll(_loadLegacySlots(prefs));
    }
    _ensureValidActiveList();
    _initialized = true;
    notifyListeners();
    // Persist migrated ids so legacy wiki/community do not linger.
    await _persist();
  }

  bool isActive(String optionId) {
    final migrated = ShellNavCatalog.migrateOptionId(optionId);
    return _activeIds.contains(migrated);
  }

  ShellNavOption optionForSlot(int index) {
    if (index < 0 || index >= _activeIds.length) {
      return ShellNavCatalog.optionById(_activeIds.first);
    }
    return ShellNavCatalog.optionById(_activeIds[index]);
  }

  /// Toggle an option in the active tab list. Returns false when blocked by limits.
  bool toggleOption(String optionId) {
    final migrated = ShellNavCatalog.migrateOptionId(optionId);
    if (!_isValidOptionId(migrated)) return false;

    if (_activeIds.contains(migrated)) {
      if (!canRemove) return false;
      _activeIds.remove(migrated);
    } else {
      if (!canAddMore) return false;
      _activeIds.add(migrated);
    }
    notifyListeners();
    return true;
  }

  /// Replace the full ordered selection (deduped, clamped to min/max).
  Future<void> setActiveOptions(List<String> optionIds) async {
    final next = <String>[];
    for (final id in optionIds) {
      final migrated = ShellNavCatalog.migrateOptionId(id);
      if (_isValidOptionId(migrated) && !next.contains(migrated)) {
        next.add(migrated);
      }
    }
    if (next.length < minTabs) return;
    if (next.length > maxTabs) {
      next.removeRange(maxTabs, next.length);
    }
    if (_listsEqual(next, _activeIds)) return;
    _activeIds
      ..clear()
      ..addAll(next);
    notifyListeners();
    await _persist();
  }

  Future<void> resetToDefault() async {
    await setActiveOptions(ShellNavCatalog.defaultActiveIds);
  }

  Future<void> persist() => _persist();

  int selectedSlotIndex({
    required int currentBranch,
    required String path,
  }) {
    for (var i = 0; i < _activeIds.length; i++) {
      final option = ShellNavCatalog.optionById(_activeIds[i]);
      if (option.matchesLocation(
        branchIndex: currentBranch,
        path: path,
      )) {
        return i;
      }
    }
    return -1;
  }

  List<String> _loadLegacySlots(SharedPreferences prefs) {
    final migrated = <String>[];
    for (var i = 0; i < 3; i++) {
      final id = prefs.getString('$_legacyPrefPrefix$i');
      if (id == null) continue;
      final mapped = ShellNavCatalog.migrateOptionId(id);
      if (_isValidOptionId(mapped) && !migrated.contains(mapped)) {
        migrated.add(mapped);
      }
    }
    return migrated.isNotEmpty
        ? migrated
        : List<String>.from(ShellNavCatalog.defaultActiveIds);
  }

  List<String> _parseIdList(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(ShellNavCatalog.migrateOptionId)
        .where(_isValidOptionId)
        .fold<List<String>>([], (list, id) {
      if (!list.contains(id)) list.add(id);
      return list;
    });
  }

  void _ensureValidActiveList() {
    final cleaned = <String>[];
    for (final id in _activeIds) {
      final mapped = ShellNavCatalog.migrateOptionId(id);
      if (_isValidOptionId(mapped) && !cleaned.contains(mapped)) {
        cleaned.add(mapped);
      }
    }
    _activeIds
      ..clear()
      ..addAll(
        cleaned.isEmpty
            ? ShellNavCatalog.defaultActiveIds
            : cleaned,
      );
    if (_activeIds.length > maxTabs) {
      _activeIds.removeRange(maxTabs, _activeIds.length);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyActive, _activeIds.join(','));
  }

  bool _isValidOptionId(String id) {
    return ShellNavCatalog.options.any((o) => o.id == id);
  }

  static bool listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _listsEqual(List<String> a, List<String> b) => listsEqual(a, b);
}
