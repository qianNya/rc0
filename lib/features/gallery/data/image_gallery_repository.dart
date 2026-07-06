import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/image/data/image-api.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';
import '../../screenplay/data/data_upload_repository.dart';
import '../domain/gallery_image.dart';

class ImageGalleryRepository extends ChangeNotifier {
  ImageGalleryRepository._();

  static final ImageGalleryRepository instance = ImageGalleryRepository._();

  final List<GalleryImage> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;

  List<GalleryImage> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  bool get hasMore => _items.length < _total.toInt();

  void patchImage(GalleryImage image) {
    final index = _items.indexWhere((e) => e.id == image.id);
    if (index >= 0) {
      _items[index] = image;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    AuthRepository.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!AuthRepository.instance.isLoggedIn) {
      _items.clear();
      _error = null;
      _page = 1;
      _total = 0;
      notifyListeners();
    }
  }

  GalleryImage _fromDto(GalleryImageItem dto) {
    return GalleryImage(
      id: dto.id.toInt(),
      title: dto.title,
      description: dto.description,
      imageUrl: dto.imageUrl,
      thumbnailUrl: dto.thumbnailUrl,
      createAt: dto.createAt,
      tags: dto.tags,
      tagIds: dto.tagIds,
      primaryFile: dto.primaryFile,
    );
  }

  Future<void> loadFirstPage({int pageSize = 20}) async {
    if (!AuthRepository.instance.isLoggedIn) {
      _items.clear();
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    notifyListeners();

    final result = await _fetchPage(page: 1, pageSize: pageSize);
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items
        ..clear()
        ..addAll(result.items);
      _total = result.total;
      _page = 1;
      _error = null;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !hasMore) return;
    if (!AuthRepository.instance.isLoggedIn) return;

    _loadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _fetchPage(page: nextPage, pageSize: _pageSize);
    _loadingMore = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items.addAll(result.items);
      _total = result.total;
      _page = nextPage;
    }
    notifyListeners();
  }

  Future<({List<GalleryImage> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final (resp, error) = await apiCallback<ListImagesResp>(
      ({ok, fail, eventually}) => image_api.listImages(
        page: page,
        pageSize: pageSize,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <GalleryImage>[], total: 0, error: error);
    }

    final items = (resp?.list ?? []).map(_fromDto).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }

  Future<({GalleryImage? image, String? error})> fetchDetail(int id) async {
    final (resp, error) = await apiCallback<ImageDetailResp>(
      ({ok, fail, eventually}) => image_api.getImageDetail(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (image: null, error: error);
    }
    if (resp == null) {
      return (image: null, error: '图片不存在');
    }

    return (
      image: GalleryImage(
        id: resp.id.toInt(),
        title: resp.title,
        description: resp.description,
        imageUrl: resp.imageUrl,
        thumbnailUrl: resp.thumbnailUrl,
        createAt: resp.createAt,
        tags: resp.tags,
        tagIds: resp.tagIds,
        primaryFile: pickPrimaryImageFile(resp.files),
      ),
      error: null,
    );
  }

  Future<({String? downloadUrl, String? error})> fetchDownloadUrl(
    int imageId,
  ) async {
    final (resp, error) = await apiCallback<ImageDownloadResp>(
      ({ok, fail, eventually}) => image_api.getImageDownloadUrl(
        imageId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (downloadUrl: null, error: error);
    }
    final url = resp?.downloadUrl ?? '';
    if (url.isEmpty) {
      return (downloadUrl: null, error: '下载链接无效');
    }
    return (downloadUrl: url, error: null);
  }

  Future<({GalleryImage? image, String? error})> uploadStandalone(
    File file,
  ) async {
    if (!AuthRepository.instance.isLoggedIn) {
      return (image: null, error: '请先登录');
    }

    final uploaded = await DataUploadRepository.instance.uploadImage(file);
    if (uploaded.error != null || uploaded.object == null) {
      return (image: null, error: uploaded.error ?? '上传失败');
    }

    final imageId = uploaded.object!.imageId;
    final detail = await fetchDetail(imageId);
    if (detail.image != null) {
      _items.insert(0, detail.image!);
      _total = _total + 1;
      notifyListeners();
      return (image: detail.image, error: null);
    }

    final fallback = GalleryImage(
      id: imageId,
      title: file.path.split(Platform.pathSeparator).last,
      description: '',
      imageUrl: '',
      thumbnailUrl: '',
      createAt: '',
    );
    _items.insert(0, fallback);
    _total = _total + 1;
    notifyListeners();
    return (image: fallback, error: null);
  }
}
