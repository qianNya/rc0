import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/services/network_image_cache_service.dart';
import '../../core/utils/image_url_utils.dart';

typedef Rc0ImageLoadingBuilder = Widget Function(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
);

/// Local file or network image with explicit WebP decoding support.
///
/// Network URLs are shown immediately; after load completes the bytes are
/// persisted under [NetworkImageCacheService] and subsequent builds prefer
/// the local file.
class Rc0Image extends StatefulWidget {
  const Rc0Image({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorWidget,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Rc0ImageLoadingBuilder? loadingBuilder;
  final Widget? errorWidget;

  @override
  State<Rc0Image> createState() => _Rc0ImageState();
}

class _Rc0ImageState extends State<Rc0Image> {
  final _cache = NetworkImageCacheService.instance;

  Uint8List? _memoryBytes;
  bool _loadingMemory = false;
  bool _memoryFailed = false;
  bool _loadScheduled = false;
  bool _cacheScheduled = false;
  String? _cachedLocalPath;

  @override
  void initState() {
    super.initState();
    _primeCache();
    _scheduleWebpPreload();
  }

  @override
  void didUpdateWidget(Rc0Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _memoryBytes = null;
      _loadingMemory = false;
      _memoryFailed = false;
      _loadScheduled = false;
      _cacheScheduled = false;
      _cachedLocalPath = null;
      _primeCache();
      _scheduleWebpPreload();
    }
  }

  String get _resolved => resolveNetworkImageUrl(widget.path) ?? widget.path;

  void _primeCache() {
    final resolved = _resolved;
    if (!isNetworkImagePath(resolved)) return;

    final syncHit = _cache.cachedPathSync(resolved);
    if (syncHit != null) {
      _cachedLocalPath = syncHit;
      return;
    }

    _cache.ensureReady().then((_) {
      if (!mounted) return;
      final hit = _cache.cachedPathSync(resolved);
      if (hit != null && hit != _cachedLocalPath) {
        setState(() => _cachedLocalPath = hit);
      }
    });
  }

  void _scheduleWebpPreload() {
    if (kIsWeb) return;
    if (!isWebpImagePath(_resolved)) return;
    if (!isNetworkImagePath(_resolved)) {
      if (!File(_resolved).existsSync()) return;
    }
    _scheduleMemoryLoad();
  }

  /// Defers loading until after the current build frame (safe from errorBuilder).
  void _scheduleMemoryLoad() {
    if (_loadScheduled || _loadingMemory || _memoryBytes != null) return;
    _loadScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (!mounted) return;
      _loadMemory();
    });
  }

  void _scheduleNetworkCache(String url) {
    if (_cacheScheduled) return;
    _cacheScheduled = true;
    _cache.downloadIfNeeded(url).then((path) {
      if (!mounted || path == null) return;
      if (_resolved != url) return;
      setState(() => _cachedLocalPath = path);
    });
  }

  Future<void> _loadMemory() async {
    if (_loadingMemory || _memoryBytes != null) return;
    setState(() {
      _loadingMemory = true;
      _memoryFailed = false;
    });

    try {
      final Uint8List bytes;
      final resolved = _resolved;
      if (isNetworkImagePath(resolved)) {
        final cached = _cache.cachedPathSync(resolved) ??
            await _cache.cachedPath(resolved);
        if (cached != null) {
          bytes = await File(cached).readAsBytes();
        } else {
          final client = HttpClient();
          try {
            final request = await client.getUrl(Uri.parse(resolved));
            final response = await request.close();
            if (response.statusCode != 200) {
              throw HttpException('HTTP ${response.statusCode}');
            }
            final builder = BytesBuilder(copy: false);
            await for (final chunk in response) {
              builder.add(chunk);
            }
            bytes = builder.takeBytes();
          } finally {
            client.close();
          }
          final saved = await _cache.writeFromBytes(resolved, bytes);
          if (saved != null && mounted) {
            _cachedLocalPath = saved;
          }
        }
      } else {
        bytes = await File(resolved).readAsBytes();
      }

      if (!mounted) return;
      setState(() {
        _memoryBytes = bytes;
        _loadingMemory = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingMemory = false;
        _memoryFailed = true;
      });
    }
  }

  Widget _error() => widget.errorWidget ?? const SizedBox.shrink();

  Widget _loadingPlaceholder([ImageChunkEvent? progress]) {
    return widget.loadingBuilder?.call(context, const SizedBox.shrink(), progress) ??
        Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress?.expectedTotalBytes != null
                  ? progress!.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
  }

  Widget _buildFileImage(String path) {
    if (kIsWeb) return _buildFallbackError();
    return Image.file(
      File(path),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, _, _) => _buildFallbackError(),
    );
  }

  Widget _buildMemoryImage() {
    final bytes = _memoryBytes;
    if (bytes == null) {
      if (_memoryFailed) return _error();
      return _loadingPlaceholder();
    }

    return Image.memory(
      bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, _, _) => _error(),
    );
  }

  Widget _buildFallbackError() {
    _scheduleMemoryLoad();
    if (_memoryFailed) return _error();
    return _loadingPlaceholder();
  }

  Widget _buildNetworkImage(String resolved) {
    return Image.network(
      resolved,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          _scheduleNetworkCache(resolved);
        }
        if (widget.loadingBuilder != null) {
          return widget.loadingBuilder!(context, child, progress);
        }
        if (progress == null) return child;
        return _loadingPlaceholder(progress);
      },
      errorBuilder: (_, _, _) => _buildFallbackError(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolved;

    if (isWebpImagePath(resolved)) {
      if (kIsWeb) {
        if (isNetworkImagePath(resolved) && isValidNetworkImageUrl(resolved)) {
          return _buildNetworkImage(resolved);
        }
        return _error();
      }
      final cached = _cachedLocalPath ?? _cache.cachedPathSync(resolved);
      if (cached != null) return _buildFileImage(cached);
      return _buildMemoryImage();
    }

    if (isNetworkImagePath(resolved)) {
      if (!isValidNetworkImageUrl(resolved)) return _error();
      if (!kIsWeb) {
        final cached = _cachedLocalPath ?? _cache.cachedPathSync(resolved);
        if (cached != null) return _buildFileImage(cached);
      }
      return _buildNetworkImage(resolved);
    }

    if (kIsWeb) return _error();
    return Image.file(
      File(resolved),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, _, _) => _buildFallbackError(),
    );
  }
}
