import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local fallback for gear cabinet layout when `/cine-equipment/layout` is unavailable.
class GearCabinetLayoutLocal {
  GearCabinetLayoutLocal._();

  static final GearCabinetLayoutLocal instance = GearCabinetLayoutLocal._();

  static const _prefsKey = 'rc0_gear_cabinet_layout_v1';

  Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return json;
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(payload));
  }
}
