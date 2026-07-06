import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/gallery_image.dart';
import '../domain/media_vault_image.dart';
import '../domain/media_vault_types.dart';
import 'image_gallery_repository.dart';
import 'image_tags_repository.dart';
import 'media_vault_sample_data.dart';

/// Unified media vault repository — user API when logged in, sample when guest.
class MediaVaultRepository extends ChangeNotifier {
  MediaVaultRepository._();

  static final MediaVaultRepository instance = MediaVaultRepository._();

  final _gallery = ImageGalleryRepository.instance;
  final _tagsRepo = ImageTagsRepository.instance;
  final _auth = AuthRepository.instance;

  List<MediaVaultImage> _images = [];
  List<MediaAlbum> _albums = [];
  List<MediaTagEntry> _tagEntries = [];
  bool _loading = false;
  String? _error;
  final double _storageUsedGb = 328.7;
  final double _storageTotalGb = 1024;

  List<MediaVaultImage> get images => List.unmodifiable(_images);
  List<MediaAlbum> get albums => List.unmodifiable(_albums);
  List<MediaTagEntry> get tags => List.unmodifiable(_tagEntries);
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _auth.isLoggedIn;
  double get storageUsedGb => _storageUsedGb;
  double get storageTotalGb => _storageTotalGb;
  double get storageFraction => _storageUsedGb / _storageTotalGb;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (_auth.isLoggedIn) {
        await Future.wait([
          _gallery.loadFirstPage(pageSize: 40),
          _tagsRepo.loadTags(),
        ]);
        _images = _gallery.items.map(_fromGalleryImage).toList(growable: false);
        _albums = MediaVaultSampleData.buildAlbums();
        _tagEntries = _tagsFromRepository();
      } else {
        _images = const [];
        _albums = MediaVaultSampleData.buildAlbums();
        _tagEntries = MediaVaultSampleData.buildTags();
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
      MediaVaultSection.trash => const [],
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

  void toggleFavorite(String id) {
    final index = _images.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _images[index] =
        _images[index].copyWith(isFavorite: !_images[index].isFavorite);
    notifyListeners();
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
      id: 'api-${g.id}',
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
