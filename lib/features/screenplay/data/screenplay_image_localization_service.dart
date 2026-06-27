import 'dart:async';

import '../../../core/domain/screenplay/screenplay_image_resolver.dart';
import '../../../core/services/network_image_cache_service.dart';
import '../../../core/utils/image_url_utils.dart';
import 'screenplay_local_repository.dart';
import 'screenplay_tree_document.dart';

/// Writes globally cached network images into screenplay tree `local_*` paths
/// while the user browses a remote or partially-local screenplay.
class ScreenplayImageLocalizationService {
  ScreenplayImageLocalizationService._();

  static final ScreenplayImageLocalizationService instance =
      ScreenplayImageLocalizationService._();

  final _cache = NetworkImageCacheService.instance;
  final _local = ScreenplayLocalRepository.instance;

  String? _activeLocalId;
  Set<String> _trackedUrls = {};
  bool _listenerAttached = false;
  Timer? _backfillTimer;

  void initialize() {
    if (_listenerAttached) return;
    _cache.addCachedListener(_onImageCached);
    _listenerAttached = true;
  }

  Future<void> trackRemoteScreenplay(int remoteId) async {
    initialize();
    final doc = await _local.ensureRemoteBrowseDocument(remoteId);
    if (doc == null) return;
    await _activateDocument(doc);
  }

  Future<void> trackLocalScreenplay(String localId) async {
    initialize();
    final doc = _local.documentById(localId);
    if (doc == null || doc.meta.imagesLocalized) return;
    await _activateDocument(doc);
  }

  void stopTracking() {
    _backfillTimer?.cancel();
    _backfillTimer = null;
    _activeLocalId = null;
    _trackedUrls = {};
  }

  Future<void> _activateDocument(ScreenplayTreeDocument doc) async {
    _activeLocalId = doc.meta.localId;
    _trackedUrls = _collectRemoteUrls(doc.tree);
    _scheduleBackfill();
  }

  Set<String> _collectRemoteUrls(Map<String, dynamic> tree) {
    final urls = <String>{};
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final cover = ScreenplayImageResolver.coverRemoteUrl(screenplayMap);
    if (cover != null) urls.add(_normalizeUrl(cover));

    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (final actNode in acts) {
      final scenes =
          (actNode as Map<String, dynamic>)['scenes'] as List<dynamic>? ?? [];
      for (final sceneNode in scenes) {
        final frames =
            (sceneNode as Map<String, dynamic>)['frames'] as List<dynamic>? ??
                [];
        for (final frame in frames) {
          final remote =
              ScreenplayImageResolver.frameRemoteUrl(frame as Map<String, dynamic>);
          if (remote != null) urls.add(_normalizeUrl(remote));
        }
      }
    }
    return urls;
  }

  String _normalizeUrl(String url) => resolveNetworkImageUrl(url) ?? url;

  void _scheduleBackfill() {
    _backfillTimer?.cancel();
    _backfillTimer = Timer(const Duration(milliseconds: 200), () {
      unawaited(_backfillExistingCache());
    });
  }

  Future<void> _backfillExistingCache() async {
    final localId = _activeLocalId;
    if (localId == null) return;

    await _cache.ensureReady();
    for (final url in _trackedUrls) {
      final cached = _cache.cachedPathSync(url) ?? await _cache.cachedPath(url);
      if (cached != null) {
        await _local.persistCachedNetworkImage(
          localId: localId,
          remoteUrl: url,
          cachedFilePath: cached,
        );
      }
    }
  }

  void _onImageCached(String url, String localPath) {
    final localId = _activeLocalId;
    if (localId == null) return;

    final normalized = _normalizeUrl(url);
    if (!_trackedUrls.contains(normalized)) return;

    unawaited(
      _local.persistCachedNetworkImage(
        localId: localId,
        remoteUrl: normalized,
        cachedFilePath: localPath,
      ),
    );
  }
}
