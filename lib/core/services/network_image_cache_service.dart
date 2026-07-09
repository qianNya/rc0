import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import '../utils/image_url_utils.dart';

typedef NetworkImageCachedListener = void Function(String url, String localPath);

/// Persists network images to app storage after load for offline reuse.
class NetworkImageCacheService {
  NetworkImageCacheService._();

  static final NetworkImageCacheService instance = NetworkImageCacheService._();

  final Map<String, Future<String?>> _inFlight = {};
  final List<NetworkImageCachedListener> _listeners = [];
  String? _cacheRoot;

  void addCachedListener(NetworkImageCachedListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeCachedListener(NetworkImageCachedListener listener) {
    _listeners.remove(listener);
  }

  void _notifyCached(String url, String localPath) {
    for (final listener in List<NetworkImageCachedListener>.from(_listeners)) {
      listener(url, localPath);
    }
  }

  Future<String> _cacheRootPath() async {
    if (kIsWeb) {
      throw UnsupportedError('Network image disk cache is unavailable on web');
    }
    if (_cacheRoot != null) return _cacheRoot!;
    final tempDir = await getTemporaryDirectory();
    final dir = Directory('${tempDir.path}/rc0_image_cache');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    _cacheRoot = dir.path;
    return _cacheRoot!;
  }

  String cacheFileName(String url) {
    final ext = imageFileExtensionFromPath(url);
    return '${url.hashCode.abs()}$ext';
  }

  Future<File> _cacheFile(String url) async {
    final root = await _cacheRootPath();
    return File('$root/${cacheFileName(url)}');
  }

  /// Warms the cache directory so [cachedPathSync] can resolve paths.
  Future<void> ensureReady() async {
    if (kIsWeb) return;
    await _cacheRootPath();
  }

  /// Returns a cached local path when the file already exists.
  String? cachedPathSync(String url) {
    if (kIsWeb) return null;
    final resolved = resolveNetworkImageUrl(url) ?? url;
    if (!isNetworkImagePath(resolved)) return null;
    final root = _cacheRoot;
    if (root == null) return null;
    final file = File('$root/${cacheFileName(resolved)}');
    if (file.existsSync()) return file.path;
    return null;
  }

  /// Returns a cached local path when the file already exists.
  Future<String?> cachedPath(String url) async {
    if (kIsWeb) return null;
    final resolved = resolveNetworkImageUrl(url) ?? url;
    if (!isNetworkImagePath(resolved)) return null;
    final file = await _cacheFile(resolved);
    if (await file.exists()) return file.path;
    return null;
  }

  /// Downloads [url] once and returns the local file path.
  Future<String?> downloadIfNeeded(String url) {
    if (kIsWeb) return Future.value(null);
    final resolved = resolveNetworkImageUrl(url) ?? url;
    if (!isNetworkImagePath(resolved) || !isValidNetworkImageUrl(resolved)) {
      return Future.value(null);
    }

    return _inFlight.putIfAbsent(resolved, () async {
      try {
        final file = await _cacheFile(resolved);
        if (await file.exists()) {
          final path = file.path;
          _notifyCached(resolved, path);
          return path;
        }

        final client = HttpClient();
        try {
          final request = await client.getUrl(Uri.parse(resolved));
          final response = await request.close();
          if (response.statusCode != 200) return null;
          await response.pipe(file.openWrite());
          final path = file.path;
          _notifyCached(resolved, path);
          return path;
        } finally {
          client.close();
        }
      } catch (_) {
        return null;
      } finally {
        _inFlight.remove(resolved);
      }
    });
  }

  /// Writes decoded bytes (e.g. WebP) into the URL cache entry.
  Future<String?> writeFromBytes(String url, Uint8List bytes) async {
    if (kIsWeb) return null;
    final resolved = resolveNetworkImageUrl(url) ?? url;
    if (!isNetworkImagePath(resolved)) return null;
    try {
      final file = await _cacheFile(resolved);
      if (await file.exists()) {
        final path = file.path;
        _notifyCached(resolved, path);
        return path;
      }
      await file.writeAsBytes(bytes, flush: true);
      final path = file.path;
      _notifyCached(resolved, path);
      return path;
    } catch (_) {
      return null;
    }
  }
}
