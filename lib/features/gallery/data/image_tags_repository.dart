import 'package:flutter/foundation.dart';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/image/data/image-api.dart';
import '../../../core/network/api_callback.dart';
import '../../../core/auth/auth_bridge.dart';
import '../domain/image_tag.dart';
import 'image_gallery_repository.dart';

class ImageTagsRepository extends ChangeNotifier {
  ImageTagsRepository._();

  static final ImageTagsRepository instance = ImageTagsRepository._();

  final List<ImageTag> _tags = [];
  bool _loading = false;
  String? _error;
  String _namespace = 'general';

  List<ImageTag> get tags => List.unmodifiable(_tags);
  bool get loading => _loading;
  String? get error => _error;
  String get namespace => _namespace;

  Future<void> initialize() async {
    AuthBridge.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!AuthBridge.isLoggedIn) {
      _tags.clear();
      _error = null;
      notifyListeners();
    }
  }

  ImageTag _fromDto(ImageTagItem dto) {
    return ImageTag(
      id: dto.id.toInt(),
      name: dto.name,
      slug: dto.slug,
      namespace: dto.namespace,
      imageCount: dto.imageCount.toInt(),
    );
  }

  List<String> get suggestedNames => _tags.map((t) => t.name).toList();

  Future<void> loadTags({String namespace = 'general'}) async {
    if (!AuthBridge.isLoggedIn) {
      _tags.clear();
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _namespace = namespace;
    notifyListeners();

    final (resp, error) = await apiCallback<ListImageTagsResp>(
      ({ok, fail, eventually}) => image_api.listImageTags(
        namespace: namespace,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    _loading = false;
    if (error != null) {
      _error = error;
    } else {
      _tags
        ..clear()
        ..addAll((resp?.list ?? []).map(_fromDto));
      _error = null;
    }
    notifyListeners();
  }

  Future<int?> _ensureTagId(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final existing = _tags.where(
      (t) => t.name == trimmed || t.slug == trimmed.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first.id;

    final (created, error) = await apiCallback<ImageTagItem>(
      ({ok, fail, eventually}) => image_api.createImageTag(
        name: trimmed,
        namespace: _namespace,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null || created == null) return null;

    final tag = _fromDto(created);
    if (!_tags.any((t) => t.id == tag.id)) {
      _tags.add(tag);
      notifyListeners();
    }
    return tag.id;
  }

  /// Applies tag name diff to a server image and patches local gallery cache.
  Future<String?> applyTagsToImage({
    required int imageId,
    required List<int> currentTagIds,
    required Set<String> desiredNames,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }

    if (_tags.isEmpty) {
      await loadTags(namespace: _namespace);
    }

    final desiredIds = <int>{};
    for (final name in desiredNames) {
      final id = await _ensureTagId(name);
      if (id != null) desiredIds.add(id);
    }

    final current = currentTagIds.toSet();
    final toAdd = desiredIds.difference(current);
    final toRemove = current.difference(desiredIds);

    for (final tagId in toAdd) {
      final (_, error) = await apiCallback<Map<String, dynamic>>(
        ({ok, fail, eventually}) => image_api.tagImage(
          imageId,
          tagId: tagId,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
      if (error != null) return error;
    }

    for (final tagId in toRemove) {
      final (_, error) = await apiCallback<Map<String, dynamic>>(
        ({ok, fail, eventually}) => image_api.untagImage(
          imageId,
          tagId,
          ok: ok,
          fail: fail,
          eventually: eventually,
        ),
      );
      if (error != null) return error;
    }

    final detail = await ImageGalleryRepository.instance.fetchDetail(imageId);
    if (detail.image != null) {
      ImageGalleryRepository.instance.patchImage(detail.image!);
    }

    return null;
  }
}
