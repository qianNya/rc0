import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/media_vault_image.dart';

/// Local persistence for Media Vault album/favorite/trash until `/media-vault` API ships.
class MediaVaultLocalState {
  MediaVaultLocalState._();

  static final MediaVaultLocalState instance = MediaVaultLocalState._();

  static const _prefsKey = 'rc0_media_vault_state_v1';

  final Set<String> _favoriteIds = {};
  final Set<String> _trashedIds = {};
  final List<_StoredAlbum> _albums = [];
  bool _loaded = false;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  Set<String> get trashedIds => Set.unmodifiable(_trashedIds);

  Map<int, String> albumIdByGalleryImageId() {
    final result = <int, String>{};
    for (final album in _albums) {
      for (final vaultId in album.imageIds) {
        final gid = _galleryIdFromVaultId(vaultId);
        if (gid != null) result[gid] = album.id;
      }
    }
    return result;
  }

  static int? _galleryIdFromVaultId(String vaultId) {
    const prefix = 'api-';
    if (!vaultId.startsWith(prefix)) return null;
    return int.tryParse(vaultId.substring(prefix.length));
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _favoriteIds
          ..clear()
          ..addAll(
            (json['favorites'] as List<dynamic>? ?? const [])
                .map((e) => e.toString()),
          );
        _trashedIds
          ..clear()
          ..addAll(
            (json['trash'] as List<dynamic>? ?? const [])
                .map((e) => e.toString()),
          );
        _albums
          ..clear()
          ..addAll(
            (json['albums'] as List<dynamic>? ?? const [])
                .map((e) => _StoredAlbum.fromJson(e as Map<String, dynamic>)),
          );
      } catch (_) {
        _favoriteIds.clear();
        _trashedIds.clear();
        _albums.clear();
      }
    }
    _loaded = true;
  }

  List<MediaAlbum> toMediaAlbums() {
    return _albums
        .map(
          (a) => MediaAlbum(
            id: a.id,
            name: a.name,
            imageCount: a.imageIds.length,
          ),
        )
        .toList(growable: false);
  }

  String? albumIdForImage(String imageId) {
    for (final album in _albums) {
      if (album.imageIds.contains(imageId)) return album.id;
    }
    return null;
  }

  MediaVaultImage applyTo(MediaVaultImage image) {
    final inTrash = _trashedIds.contains(image.id);
    if (inTrash) {
      return image;
    }
    return image.copyWith(
      isFavorite: _favoriteIds.contains(image.id),
      albumId: albumIdForImage(image.id) ?? image.albumId,
    );
  }

  Future<void> setFavorite(String imageId, bool value) async {
    await ensureLoaded();
    if (value) {
      _favoriteIds.add(imageId);
      _trashedIds.remove(imageId);
    } else {
      _favoriteIds.remove(imageId);
    }
    await _persist();
  }

  Future<void> toggleFavorite(String imageId) async {
    await ensureLoaded();
    await setFavorite(imageId, !_favoriteIds.contains(imageId));
  }

  Future<void> moveToTrash(String imageId) async {
    await ensureLoaded();
    _trashedIds.add(imageId);
    _favoriteIds.remove(imageId);
    await _persist();
  }

  Future<void> restoreFromTrash(String imageId) async {
    await ensureLoaded();
    _trashedIds.remove(imageId);
    await _persist();
  }

  Future<void> permanentlyDelete(String imageId) async {
    await ensureLoaded();
    _trashedIds.remove(imageId);
    _favoriteIds.remove(imageId);
    final updated = <_StoredAlbum>[];
    for (final album in _albums) {
      final ids = album.imageIds.where((id) => id != imageId).toList();
      updated.add(
        _StoredAlbum(id: album.id, name: album.name, imageIds: ids),
      );
    }
    _albums
      ..clear()
      ..addAll(updated);
    await _persist();
  }

  Future<MediaAlbum> createAlbum(String name) async {
    await ensureLoaded();
    final id = 'album-local-${DateTime.now().millisecondsSinceEpoch}';
    _albums.add(_StoredAlbum(id: id, name: name, imageIds: []));
    await _persist();
    return MediaAlbum(id: id, name: name, imageCount: 0);
  }

  Future<void> deleteAlbum(String albumId) async {
    await ensureLoaded();
    _albums.removeWhere((album) => album.id == albumId);
    await _persist();
  }

  Future<void> addImageToAlbum({
    required String albumId,
    required String imageId,
  }) async {
    await ensureLoaded();
    final updated = <_StoredAlbum>[];
    for (final album in _albums) {
      final ids = album.imageIds.where((id) => id != imageId).toList();
      if (album.id == albumId && !ids.contains(imageId)) {
        ids.add(imageId);
      }
      updated.add(
        _StoredAlbum(id: album.id, name: album.name, imageIds: ids),
      );
    }
    _albums
      ..clear()
      ..addAll(updated);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'favorites': _favoriteIds.toList(),
      'trash': _trashedIds.toList(),
      'albums': _albums.map((a) => a.toJson()).toList(),
    });
    await prefs.setString(_prefsKey, payload);
  }
}

class _StoredAlbum {
  const _StoredAlbum({
    required this.id,
    required this.name,
    required this.imageIds,
  });

  final String id;
  final String name;
  final List<String> imageIds;

  factory _StoredAlbum.fromJson(Map<String, dynamic> json) {
    return _StoredAlbum(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageIds: (json['image_ids'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_ids': imageIds,
      };
}
