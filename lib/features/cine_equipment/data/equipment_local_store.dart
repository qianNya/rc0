import 'package:shared_preferences/shared_preferences.dart';

/// Local favorites and owned equipment item IDs.
class EquipmentLocalStore {
  EquipmentLocalStore._();

  static final EquipmentLocalStore instance = EquipmentLocalStore._();

  static const _favoriteBodyIdsKey = 'rc0_equipment_favorite_body_ids';
  static const _favoriteLensIdsKey = 'rc0_equipment_favorite_lens_ids';
  static const _favoriteSetupIdsKey = 'rc0_equipment_favorite_setup_ids';

  Future<Set<String>> favoriteBodyIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteBodyIdsKey)?.toSet() ?? {};
  }

  Future<Set<String>> favoriteLensIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteLensIdsKey)?.toSet() ?? {};
  }

  Future<Set<String>> favoriteSetupIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoriteSetupIdsKey)?.toSet() ?? {};
  }

  Future<void> setBodyFavorite(String id, bool favorite) async {
    await _toggle(_favoriteBodyIdsKey, id, favorite);
  }

  Future<void> setLensFavorite(String id, bool favorite) async {
    await _toggle(_favoriteLensIdsKey, id, favorite);
  }

  Future<void> setSetupFavorite(String id, bool favorite) async {
    await _toggle(_favoriteSetupIdsKey, id, favorite);
  }

  Future<void> _toggle(String key, String id, bool favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(key)?.toSet() ?? {};
    if (favorite) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await prefs.setStringList(key, ids.toList());
  }
}
