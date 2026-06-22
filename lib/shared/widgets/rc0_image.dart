import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/utils/image_url_utils.dart';

typedef Rc0ImageLoadingBuilder = Widget Function(
  BuildContext context,
  Widget child,
  ImageChunkEvent? loadingProgress,
);

/// Local file or network image with explicit WebP decoding support.
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
  Uint8List? _memoryBytes;
  bool _loadingMemory = false;
  bool _memoryFailed = false;
  bool _loadScheduled = false;

  @override
  void initState() {
    super.initState();
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
      _scheduleWebpPreload();
    }
  }

  String get _resolved => resolveNetworkImageUrl(widget.path) ?? widget.path;

  void _scheduleWebpPreload() {
    if (!isWebpImagePath(_resolved)) return;
    if (!isNetworkImagePath(_resolved) && !File(_resolved).existsSync()) return;
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

  @override
  Widget build(BuildContext context) {
    final resolved = _resolved;

    if (isWebpImagePath(resolved)) {
      return _buildMemoryImage();
    }

    if (isNetworkImagePath(resolved)) {
      if (!isValidNetworkImageUrl(resolved)) return _error();
      return Image.network(
        resolved,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        loadingBuilder: widget.loadingBuilder,
        errorBuilder: (_, _, _) => _buildFallbackError(),
      );
    }

    return Image.file(
      File(resolved),
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, _, _) => _buildFallbackError(),
    );
  }
}
