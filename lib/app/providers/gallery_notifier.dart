import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gallery/data/image_gallery_repository.dart';
import '../../features/gallery/domain/gallery_image.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

@immutable
class GalleryListState {
  const GalleryListState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.total = 0,
  });

  final List<GalleryImage> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final num total;

  bool get hasMore => items.length < total.toInt();
}

/// Riverpod Notifier pilot — wraps legacy [ImageGalleryRepository].
class ImageGalleryNotifier extends Notifier<GalleryListState> {
  ImageGalleryRepository get _repo => ref.read(imageGalleryRepositoryProvider);

  @override
  GalleryListState build() {
    ref.watch(authSessionProvider);
    _repo.addListener(_syncFromRepo);
    ref.onDispose(() => _repo.removeListener(_syncFromRepo));
    return _stateFromRepo(_repo);
  }

  void _syncFromRepo() {
    state = _stateFromRepo(_repo);
  }

  GalleryListState _stateFromRepo(ImageGalleryRepository repo) {
    return GalleryListState(
      items: repo.items,
      loading: repo.loading,
      loadingMore: repo.loadingMore,
      error: repo.error,
      total: repo.total,
    );
  }

  Future<void> loadFirstPage({int pageSize = 20}) async {
    await _repo.loadFirstPage(pageSize: pageSize);
    _syncFromRepo();
  }

  Future<void> loadMore() async {
    await _repo.loadMore();
    _syncFromRepo();
  }

  void patchImage(GalleryImage image) {
    _repo.patchImage(image);
    _syncFromRepo();
  }
}

final imageGalleryNotifierProvider =
    NotifierProvider<ImageGalleryNotifier, GalleryListState>(
  ImageGalleryNotifier.new,
);
