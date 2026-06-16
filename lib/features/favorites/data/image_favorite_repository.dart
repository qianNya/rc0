import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'favorite_image_item.dart';

class ImageFavoriteRepository extends ChangeNotifier {
  ImageFavoriteRepository._();

  static final ImageFavoriteRepository instance = ImageFavoriteRepository._();

  static const _storageKey = 'rc0_favorite_images';

  SharedPreferences? _prefs;
  final List<FavoriteImageItem> _items = [];

  List<FavoriteImageItem> get items => List.unmodifiable(_items);

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await load();
  }

  Future<void> load() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    _items.clear();

    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        if (entry is Map<String, dynamic>) {
          _items.add(FavoriteImageItem.fromJson(entry));
        }
      }
      _items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    } catch (_) {
      _items.clear();
    }
  }

  bool isFavorite(String id) => _items.any((item) => item.id == id);

  Future<bool> toggle({
    required String id,
    required String imagePath,
    String? caption,
    String? sourceLabel,
  }) async {
    if (isFavorite(id)) {
      await remove(id);
      return false;
    }

    _items.insert(
      0,
      FavoriteImageItem(
        id: id,
        imagePath: imagePath,
        caption: caption,
        sourceLabel: sourceLabel,
        savedAt: DateTime.now(),
      ),
    );
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> remove(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
