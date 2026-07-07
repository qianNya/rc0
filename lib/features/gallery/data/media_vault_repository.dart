import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/gallery_image.dart';
import '../domain/media_vault_image.dart';
import '../domain/media_vault_types.dart';
import 'image_gallery_repository.dart';
import 'image_tags_repository.dart';
import 'media_vault_sample_data.dart';
import 'media_vault_state_store.dart';

/// Unified media vault repository — user API when logged in, sample when guest.
class MediaVaultRepository extends ChangeNotifier {
  MediaVaultRepository._();

  static final MediaVaultRepository instance = MediaVaultRepository._();

  static const _defaultQuotaGb = 1024.0;

  final _gallery = ImageGalleryRepository.instance;
  final _tagsRepo = ImageTagsRepository.instance;
  final _auth = AuthRepository.instance;
  final _stateStore = MediaVaultStateStore.instance;

  List<MediaVaultImage> _images = [];
  List<MediaAlbum> _albums = [];
  List<MediaTagEntry> _tagEntries = [];
  bool _loading = false;
  String? _error;
  double _storageUsedGb = 0;
  double _storageTotalGb = _defaultQuotaGb;

  List<MediaVaultImage> get images => List.unmodifiable(_images);
  List<MediaAlbum> get albums => List.unmodifiable(_albums);
  List<MediaTagEntry> get tags => List.unmodifiable(_tagEntries);
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _auth.isLoggedIn;
  bool get usesRemoteVaultApi =>
      isLoggedIn && MediaVaultStateStore.useRemoteApi && _stateStore.snapshot.fromApi;
  double get storageUsedGb => _storageUsedGb;
  double get storageTotalGb => _storageTotalGb;
  double get storageFraction =>
      _storageTotalGb > 0 ? _storageUsedGb / _storageTotalGb : 0;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (_auth.isLoggedIn) {
        await Future.wait([
          _gallery.loadFirstPage(pageSize: 40),
          _tagsRepo.loadTags(),
          _stateStore.load(isLoggedIn: true),
        ]);
        _applySnapshot(_stateStore.snapshot);
      } else {
        _images = const [];
        _albums = MediaVaultSampleData.buildAlbums();
        _tagEntries = MediaVaultSampleData.buildTags();
        _storageUsedGb = 0;
        _storageTotalGb = _defaultQuotaGb;
      }
    } catch (_) {
      _error = '加载图库失败';
      _images = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _images = [];
    await load();
  }

  MediaVaultImage? imageById(String id) {
    for (final img in _images) {
      if (img.id == id) return img;
    }
    for (final img in _trashedImages()) {
      if (img.id == id) return img;
    }
    return null;
  }

  GalleryImage? galleryImageFor(MediaVaultImage image) {
    final gid = image.galleryImageId;
    if (gid == null) return null;
    for (final g in _gallery.items) {
      if (g.id == gid) return g;
    }
    return null;
  }

  List<GalleryImage> galleryImagesFor(Iterable<MediaVaultImage> vaultImages) {
    return vaultImages
        .map(galleryImageFor)
        .whereType<GalleryImage>()
        .toList(growable: false);
  }

  int galleryIndexFor(List<GalleryImage> items, MediaVaultImage image) {
    final gid = image.galleryImageId;
    if (gid == null) return 0;
    final idx = items.indexWhere((g) => g.id == gid);
    return idx >= 0 ? idx : 0;
  }

  List<MediaVaultImage> filtered({
    MediaVaultSection section = MediaVaultSection.library,
    MediaVaultCategory category = MediaVaultCategory.all,
    String query = '',
    String? tagFilter,
    String? albumId,
  }) {
    var list = _images;

    list = switch (section) {
      MediaVaultSection.favorites =>
        list.where((e) => e.isFavorite).toList(growable: false),
      MediaVaultSection.trash => _trashedImages(),
      _ => list,
    };

    if (category != MediaVaultCategory.all) {
      list = list.where((e) => e.category == category).toList(growable: false);
    }

    if (albumId != null) {
      list = list.where((e) => e.albumId == albumId).toList(growable: false);
    }

    if (tagFilter != null && tagFilter.isNotEmpty) {
      final t = tagFilter.toLowerCase();
      list = list
          .where(
            (e) => e.tags.any((tag) => tag.toLowerCase().contains(t)),
          )
          .toList(growable: false);
    }

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((e) {
            final haystack =
                '${e.title} ${e.tags.join(' ')} ${e.category.label}'
                    .toLowerCase();
            return haystack.contains(q);
          })
          .toList(growable: false);
    }

    return list;
  }

  Future<String?> createAlbum(String title) async {
    final error = await _stateStore.createAlbum(title);
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> deleteAlbum(String albumId) async {
    final error = await _stateStore.deleteAlbum(albumId);
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> addImageToAlbum({
    required String albumId,
    required String imageId,
  }) async {
    final error = await _stateStore.addImageToAlbum(
      albumVaultId: albumId,
      imageVaultId: imageId,
    );
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> toggleFavorite(String id) async {
    final error = await _stateStore.toggleFavorite(id);
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> moveToTrash(String id) async {
    final error = await _stateStore.setTrash(id, inTrash: true);
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> restoreFromTrash(String id) async {
    final error = await _stateStore.setTrash(id, inTrash: false);
    if (error != null) return error;
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  Future<String?> permanentlyDelete(String id) async {
    final galleryId = MediaVaultStateSnapshot.galleryIdFromVaultId(id);
    final error = await _stateStore.purgeImage(id);
    if (error != null) return error;
    if (galleryId != null) {
      _gallery.removeItem(galleryId);
    }
    _applySnapshot(_stateStore.snapshot);
    notifyListeners();
    return null;
  }

  void _applySnapshot(MediaVaultStateSnapshot snapshot) {
    _albums = snapshot.albums;
    _images = _gallery.items
        .map(_fromGalleryImage)
        .map(snapshot.apply)
        .where((img) => !snapshot.isTrashed(img))
        .toList(growable: false);
    _tagEntries = _tagsFromRepository();
    _storageUsedGb =
        snapshot.storageUsedGb ?? _computeStorageUsedGbFromGallery();
    _storageTotalGb = snapshot.storageTotalGb ?? _defaultQuotaGb;
  }

  List<MediaVaultImage> _trashedImages() {
    if (!_auth.isLoggedIn) return const [];
    final snapshot = _stateStore.snapshot;
    return _gallery.items
        .map(_fromGalleryImage)
        .where(snapshot.isTrashed)
        .map(snapshot.apply)
        .toList(growable: false);
  }

  double _computeStorageUsedGbFromGallery() {
    final bytes = _gallery.items.fold<int>(
      0,
      (sum, item) => sum + (item.fileSize ?? 0),
    );
    return bytes / (1024 * 1024 * 1024);
  }

  List<MediaTagEntry> _tagsFromRepository() {
    return _tagsRepo.tags
        .map(
          (t) => MediaTagEntry(
            name: t.name.startsWith('#') ? t.name : '#${t.name}',
            count: t.imageCount,
          ),
        )
        .toList(growable: false);
  }

  MediaVaultImage _fromGalleryImage(GalleryImage g) {
    final format = g.formatLabel != '—' ? g.formatLabel : null;
    return MediaVaultImage(
      id: MediaVaultStateSnapshot.vaultIdForGallery(g.id),
      galleryImageId: g.id,
      title: g.title.isNotEmpty ? g.title : '未命名图片',
      category: MediaVaultCategory.photography,
      imageUrl: g.imageUrl,
      thumbnailUrl: g.thumbnailUrl,
      tags: g.tags.map((t) => t.startsWith('#') ? t : '#$t').toList(),
      createdAt: DateTime.tryParse(g.createAt),
      format: format,
      width: g.width,
      height: g.height,
      fileSizeMb: g.fileSize != null && g.fileSize! > 0
          ? g.fileSize! / (1024 * 1024)
          : null,
    );
  }
}
