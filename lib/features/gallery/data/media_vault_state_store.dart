import '../../../api/media-vault/api/media-vault-api.dart' as vault_api;
import '../../../api/media-vault/data/media-vault-api.dart';
import '../domain/media_vault_image.dart';
import 'media_vault_local_state.dart';

/// In-memory vault overlay: favorites, trash, albums, storage metrics.
class MediaVaultStateSnapshot {
  MediaVaultStateSnapshot({
    this.fromApi = false,
    Set<int>? favoriteGalleryIds,
    Set<int>? trashedGalleryIds,
    Map<int, String>? albumIdByGalleryImageId,
    List<MediaAlbum>? albums,
    this.storageUsedGb,
    this.storageTotalGb,
  })  : favoriteGalleryIds = favoriteGalleryIds ?? {},
        trashedGalleryIds = trashedGalleryIds ?? {},
        albumIdByGalleryImageId = albumIdByGalleryImageId ?? {},
        albums = albums ?? const [];

  final bool fromApi;
  final Set<int> favoriteGalleryIds;
  final Set<int> trashedGalleryIds;
  final Map<int, String> albumIdByGalleryImageId;
  final List<MediaAlbum> albums;
  final double? storageUsedGb;
  final double? storageTotalGb;

  static const vaultIdPrefix = 'api-';
  static const albumIdPrefix = 'album-';

  static String vaultIdForGallery(int galleryImageId) =>
      '$vaultIdPrefix$galleryImageId';

  static int? galleryIdFromVaultId(String vaultId) {
    if (!vaultId.startsWith(vaultIdPrefix)) return null;
    return int.tryParse(vaultId.substring(vaultIdPrefix.length));
  }

  static String albumIdFromRemote(int albumId) => '$albumIdPrefix$albumId';

  static int? remoteAlbumIdFromVaultId(String albumVaultId) {
    if (!albumVaultId.startsWith(albumIdPrefix)) return null;
    final raw = albumVaultId.substring(albumIdPrefix.length);
    if (raw.startsWith('local-')) return null;
    return int.tryParse(raw);
  }

  bool isTrashed(MediaVaultImage image) {
    final gid = image.galleryImageId;
    if (gid == null) return false;
    return trashedGalleryIds.contains(gid);
  }

  MediaVaultImage apply(MediaVaultImage image) {
    final gid = image.galleryImageId;
    if (gid == null) return image;
    if (trashedGalleryIds.contains(gid)) {
      return image.copyWith(isFavorite: false);
    }
    return image.copyWith(
      isFavorite: favoriteGalleryIds.contains(gid),
      albumId: albumIdByGalleryImageId[gid] ?? image.albumId,
    );
  }

  MediaVaultStateSnapshot copyWith({
    bool? fromApi,
    Set<int>? favoriteGalleryIds,
    Set<int>? trashedGalleryIds,
    Map<int, String>? albumIdByGalleryImageId,
    List<MediaAlbum>? albums,
    double? storageUsedGb,
    double? storageTotalGb,
  }) {
    return MediaVaultStateSnapshot(
      fromApi: fromApi ?? this.fromApi,
      favoriteGalleryIds: favoriteGalleryIds ?? this.favoriteGalleryIds,
      trashedGalleryIds: trashedGalleryIds ?? this.trashedGalleryIds,
      albumIdByGalleryImageId:
          albumIdByGalleryImageId ?? this.albumIdByGalleryImageId,
      albums: albums ?? this.albums,
      storageUsedGb: storageUsedGb ?? this.storageUsedGb,
      storageTotalGb: storageTotalGb ?? this.storageTotalGb,
    );
  }

  MediaVaultStateSnapshot copyWithFavorite(int galleryImageId, bool value) {
    final favorites = Set<int>.from(favoriteGalleryIds);
    final trash = Set<int>.from(trashedGalleryIds);
    if (value) {
      favorites.add(galleryImageId);
      trash.remove(galleryImageId);
    } else {
      favorites.remove(galleryImageId);
    }
    return copyWith(
      favoriteGalleryIds: favorites,
      trashedGalleryIds: trash,
    );
  }

  MediaVaultStateSnapshot copyWithTrash(int galleryImageId, bool inTrash) {
    final favorites = Set<int>.from(favoriteGalleryIds);
    final trash = Set<int>.from(trashedGalleryIds);
    if (inTrash) {
      trash.add(galleryImageId);
      favorites.remove(galleryImageId);
    } else {
      trash.remove(galleryImageId);
    }
    return copyWith(
      favoriteGalleryIds: favorites,
      trashedGalleryIds: trash,
    );
  }

  MediaVaultStateSnapshot copyWithAlbumMembership({
    required int galleryImageId,
    required String albumVaultId,
  }) {
    final previous = albumIdByGalleryImageId[galleryImageId];
    if (previous == albumVaultId) return this;

    final albumByImage = Map<int, String>.from(albumIdByGalleryImageId);
    albumByImage[galleryImageId] = albumVaultId;

    final updatedAlbums = albums.map((album) {
      var count = album.imageCount;
      if (album.id == previous) count = (count - 1).clamp(0, 1 << 30);
      if (album.id == albumVaultId) count += 1;
      return MediaAlbum(
        id: album.id,
        name: album.name,
        imageCount: count,
        coverColors: album.coverColors,
        coverIcon: album.coverIcon,
      );
    }).toList(growable: false);

    return copyWith(
      albumIdByGalleryImageId: albumByImage,
      albums: updatedAlbums,
    );
  }

  MediaVaultStateSnapshot copyWithoutAlbum(String albumVaultId) {
    final albumByImage = Map<int, String>.from(albumIdByGalleryImageId)
      ..removeWhere((_, albumId) => albumId == albumVaultId);
    final updatedAlbums = albums
        .where((album) => album.id != albumVaultId)
        .toList(growable: false);
    return copyWith(
      albumIdByGalleryImageId: albumByImage,
      albums: updatedAlbums,
    );
  }

  MediaVaultStateSnapshot copyWithoutImage(int galleryImageId) {
    final favorites = Set<int>.from(favoriteGalleryIds)..remove(galleryImageId);
    final trash = Set<int>.from(trashedGalleryIds)..remove(galleryImageId);
    final albumByImage = Map<int, String>.from(albumIdByGalleryImageId)
      ..remove(galleryImageId);
    final updatedAlbums = albums.map((album) {
      final previous = albumIdByGalleryImageId[galleryImageId];
      if (previous != album.id) return album;
      return MediaAlbum(
        id: album.id,
        name: album.name,
        imageCount: (album.imageCount - 1).clamp(0, 1 << 30),
        coverColors: album.coverColors,
        coverIcon: album.coverIcon,
      );
    }).toList(growable: false);
    return copyWith(
      favoriteGalleryIds: favorites,
      trashedGalleryIds: trash,
      albumIdByGalleryImageId: albumByImage,
      albums: updatedAlbums,
    );
  }
}

/// Loads vault overlay from `/media-vault` with local fallback.
class MediaVaultStateStore {
  MediaVaultStateStore._();

  static final MediaVaultStateStore instance = MediaVaultStateStore._();

  static bool useRemoteApi = true;

  MediaVaultStateSnapshot _snapshot = MediaVaultStateSnapshot();
  String? _lastRemoteError;

  MediaVaultStateSnapshot get snapshot => _snapshot;
  String? get lastRemoteError => _lastRemoteError;

  Future<MediaVaultStateSnapshot> load({required bool isLoggedIn}) async {
    if (!isLoggedIn) {
      _snapshot = MediaVaultStateSnapshot();
      _lastRemoteError = null;
      return _snapshot;
    }

    if (useRemoteApi) {
      final remote = await _tryLoadRemote();
      if (remote != null) {
        _snapshot = remote;
        _lastRemoteError = null;
        return _snapshot;
      }
    }

    _snapshot = await _loadFromLocal();
    return _snapshot;
  }

  Future<String?> createAlbum(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '专辑名称不能为空';

    if (useRemoteApi) {
      MediaVaultAlbumItem? created;
      String? error;
      await vault_api.createMediaVaultAlbum(
        body: MediaVaultCreateAlbumBody(title: trimmed),
        ok: (item) => created = item,
        fail: (msg) => error = msg,
      );
      if (created != null) {
        final album = MediaAlbum(
          id: MediaVaultStateSnapshot.albumIdFromRemote(created!.id),
          name: created!.title,
          imageCount: created!.imageCount,
        );
        _snapshot = _snapshot.copyWith(
          albums: [..._snapshot.albums, album],
          fromApi: true,
        );
        return null;
      }
      if (error != null) _lastRemoteError = error;
    }

    final localAlbum = await MediaVaultLocalState.instance.createAlbum(trimmed);
    _snapshot = _snapshot.copyWith(
      albums: [..._snapshot.albums, localAlbum],
    );
    return null;
  }

  Future<String?> deleteAlbum(String albumVaultId) async {
    final remoteId = MediaVaultStateSnapshot.remoteAlbumIdFromVaultId(albumVaultId);
    if (useRemoteApi && remoteId != null) {
      String? error;
      await vault_api.deleteMediaVaultAlbum(
        albumId: remoteId,
        fail: (msg) => error = msg,
      );
      if (error != null) {
        _lastRemoteError = error;
        return error;
      }
      _snapshot = _snapshot.copyWithoutAlbum(albumVaultId).copyWith(fromApi: true);
      return null;
    }

    await MediaVaultLocalState.instance.deleteAlbum(albumVaultId);
    _snapshot = _snapshot.copyWithoutAlbum(albumVaultId);
    return null;
  }

  Future<String?> addImageToAlbum({
    required String albumVaultId,
    required String imageVaultId,
  }) async {
    final galleryId = MediaVaultStateSnapshot.galleryIdFromVaultId(imageVaultId);
    if (galleryId == null) return '无效图片';

    _snapshot = _snapshot.copyWithAlbumMembership(
      galleryImageId: galleryId,
      albumVaultId: albumVaultId,
    );
    await MediaVaultLocalState.instance.addImageToAlbum(
      albumId: albumVaultId,
      imageId: imageVaultId,
    );

    final remoteAlbumId =
        MediaVaultStateSnapshot.remoteAlbumIdFromVaultId(albumVaultId);
    if (useRemoteApi && remoteAlbumId != null) {
      String? error;
      await vault_api.addMediaVaultAlbumImage(
        albumId: remoteAlbumId,
        imageId: galleryId,
        fail: (msg) => error = msg,
      );
      if (error != null) {
        _lastRemoteError = error;
        return error;
      }
      _snapshot = _snapshot.copyWith(fromApi: true);
    }
    return null;
  }

  Future<String?> toggleFavorite(String vaultImageId) async {
    final galleryId = MediaVaultStateSnapshot.galleryIdFromVaultId(vaultImageId);
    if (galleryId == null) return '无效图片';

    final next = !_snapshot.favoriteGalleryIds.contains(galleryId);
    _snapshot = _snapshot.copyWithFavorite(galleryId, next);
    await MediaVaultLocalState.instance.setFavorite(vaultImageId, next);

    if (!useRemoteApi) return null;

    String? error;
    await vault_api.patchMediaVaultImageState(
      imageId: galleryId,
      body: MediaVaultPatchImageStateBody(isFavorite: next),
      fail: (msg) => error = msg,
    );
    if (error != null) {
      _lastRemoteError = error;
      return error;
    }
    _snapshot = _snapshot.copyWith(fromApi: true);
    return null;
  }

  Future<String?> setTrash(String vaultImageId, {required bool inTrash}) async {
    final galleryId = MediaVaultStateSnapshot.galleryIdFromVaultId(vaultImageId);
    if (galleryId == null) return '无效图片';

    _snapshot = _snapshot.copyWithTrash(galleryId, inTrash);
    if (inTrash) {
      await MediaVaultLocalState.instance.moveToTrash(vaultImageId);
    } else {
      await MediaVaultLocalState.instance.restoreFromTrash(vaultImageId);
    }

    if (!useRemoteApi) return null;

    String? error;
    await vault_api.patchMediaVaultImageState(
      imageId: galleryId,
      body: MediaVaultPatchImageStateBody(inTrash: inTrash),
      fail: (msg) => error = msg,
    );
    if (error != null) {
      _lastRemoteError = error;
      return error;
    }
    _snapshot = _snapshot.copyWith(fromApi: true);
    return null;
  }

  Future<String?> purgeImage(String vaultImageId) async {
    final galleryId = MediaVaultStateSnapshot.galleryIdFromVaultId(vaultImageId);
    if (galleryId == null) return '无效图片';

    _snapshot = _snapshot.copyWithoutImage(galleryId);
    await MediaVaultLocalState.instance.permanentlyDelete(vaultImageId);

    if (!useRemoteApi) return null;

    String? error;
    await vault_api.deleteMediaVaultImage(
      imageId: galleryId,
      fail: (msg) => error = msg,
    );
    if (error != null) {
      _lastRemoteError = error;
      return error;
    }
    _snapshot = _snapshot.copyWith(fromApi: true);
    return null;
  }

  Future<MediaVaultStateSnapshot?> _tryLoadRemote() async {
    List<MediaVaultAlbumItem>? albums;
    List<MediaVaultImageStateItem>? states;
    List<MediaVaultAlbumMembershipItem>? memberships;
    MediaVaultMetricsItem? metrics;
    String? error;

    await Future.wait([
      vault_api.listMediaVaultAlbums(
        ok: (items) => albums = items,
        fail: (msg) => error ??= msg,
      ),
      vault_api.listMediaVaultImageStates(
        ok: (items) => states = items,
        fail: (msg) => error ??= msg,
      ),
      vault_api.listMediaVaultAlbumMemberships(
        ok: (items) => memberships = items,
        fail: (msg) => error ??= msg,
      ),
      vault_api.getMediaVaultMetrics(
        ok: (item) => metrics = item,
        fail: (msg) => error ??= msg,
      ),
    ]);

    if (error != null) {
      _lastRemoteError = error;
      return null;
    }

    final favorites = <int>{};
    final trash = <int>{};
    for (final state in states ?? const <MediaVaultImageStateItem>[]) {
      if (state.isFavorite) favorites.add(state.imageId);
      if (state.inTrash) trash.add(state.imageId);
    }

    final albumByImage = <int, String>{};
    for (final link in memberships ?? const <MediaVaultAlbumMembershipItem>[]) {
      albumByImage[link.imageId] =
          MediaVaultStateSnapshot.albumIdFromRemote(link.albumId);
    }

    final mediaAlbums = (albums ?? const <MediaVaultAlbumItem>[])
        .map(
          (a) => MediaAlbum(
            id: MediaVaultStateSnapshot.albumIdFromRemote(a.id),
            name: a.title,
            imageCount: a.imageCount,
          ),
        )
        .toList(growable: false);

    double? usedGb;
    double? totalGb;
    if (metrics != null) {
      usedGb = metrics!.usedBytes / (1024 * 1024 * 1024);
      totalGb = metrics!.quotaBytes / (1024 * 1024 * 1024);
    }

    return MediaVaultStateSnapshot(
      fromApi: true,
      favoriteGalleryIds: favorites,
      trashedGalleryIds: trash,
      albumIdByGalleryImageId: albumByImage,
      albums: mediaAlbums,
      storageUsedGb: usedGb,
      storageTotalGb: totalGb,
    );
  }

  Future<MediaVaultStateSnapshot> _loadFromLocal() async {
    final local = MediaVaultLocalState.instance;
    await local.ensureLoaded();

    final favorites = <int>{};
    final trash = <int>{};
    for (final vaultId in local.favoriteIds) {
      final gid = MediaVaultStateSnapshot.galleryIdFromVaultId(vaultId);
      if (gid != null) favorites.add(gid);
    }
    for (final vaultId in local.trashedIds) {
      final gid = MediaVaultStateSnapshot.galleryIdFromVaultId(vaultId);
      if (gid != null) trash.add(gid);
    }

    return MediaVaultStateSnapshot(
      favoriteGalleryIds: favorites,
      trashedGalleryIds: trash,
      albumIdByGalleryImageId: local.albumIdByGalleryImageId(),
      albums: local.toMediaAlbums(),
    );
  }
}
