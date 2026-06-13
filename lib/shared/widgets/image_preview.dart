import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 打开全屏图片预览：未放大时左右滑动切换，放大后拖动查看细节。
Future<void> showImagePreview(
  BuildContext context, {
  required List<String> imagePaths,
  int initialIndex = 0,
  List<String>? captions,
}) {
  final paths = imagePaths
      .where((path) => path.isNotEmpty && File(path).existsSync())
      .toList(growable: false);
  if (paths.isEmpty) return Future.value();

  final safeIndex = initialIndex.clamp(0, paths.length - 1);

  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _ImagePreviewPage(
            imagePaths: paths,
            initialIndex: safeIndex,
            captions: captions,
          ),
        );
      },
    ),
  );
}

class _ImagePreviewPage extends StatefulWidget {
  const _ImagePreviewPage({
    required this.imagePaths,
    required this.initialIndex,
    this.captions,
  });

  final List<String> imagePaths;
  final int initialIndex;
  final List<String>? captions;

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  late int _currentIndex;
  bool _pageScrollEnabled = true;

  bool get _hasMultiple => widget.imagePaths.length > 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _focusNode = FocusNode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _focusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String? get _currentCaption {
    final captions = widget.captions;
    if (captions == null || _currentIndex >= captions.length) return null;
    final text = captions[_currentIndex].trim();
    return text.isEmpty ? null : text;
  }

  void _onZoomScaleChanged(double scale) {
    final enablePageScroll = scale <= 1.05;
    if (enablePageScroll != _pageScrollEnabled) {
      setState(() => _pageScrollEnabled = enablePageScroll);
    }
  }

  void _goToPage(int index) {
    if (!_hasMultiple) return;
    if (index < 0 || index >= widget.imagePaths.length) return;
    if (index == _currentIndex) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _goPrevious() => _goToPage(_currentIndex - 1);

  void _goNext() => _goToPage(_currentIndex + 1);

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _goPrevious();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        _goNext();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = _currentCaption;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: _pageScrollEnabled
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _pageScrollEnabled = true;
                });
              },
              itemBuilder: (context, index) {
                return _ZoomableImage(
                  key: ValueKey(widget.imagePaths[index]),
                  path: widget.imagePaths[index],
                  onScaleChanged: _onZoomScaleChanged,
                  onTapClose: () => Navigator.of(context).pop(),
                );
              },
            ),
            if (_hasMultiple) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _PreviewNavButton(
                    icon: Icons.chevron_left,
                    tooltip: '上一张（←）',
                    enabled: _currentIndex > 0,
                    onPressed: _goPrevious,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _PreviewNavButton(
                    icon: Icons.chevron_right,
                    tooltip: '下一张（→）',
                    enabled: _currentIndex < widget.imagePaths.length - 1,
                    onPressed: _goNext,
                  ),
                ),
              ),
            ],
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: '关闭（Esc）',
                    ),
                    const Spacer(),
                    if (_hasMultiple)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imagePaths.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (caption != null)
              Positioned(
                left: 56,
                right: 56,
                bottom: MediaQuery.paddingOf(context).bottom + 16,
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewNavButton extends StatelessWidget {
  const _PreviewNavButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, color: Colors.white, size: 28),
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({
    super.key,
    required this.path,
    required this.onScaleChanged,
    this.onTapClose,
  });

  final String path;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback? onTapClose;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final TransformationController _controller = TransformationController();
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTransform);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onScaleChanged(_scale);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTransform);
    _controller.dispose();
    super.dispose();
  }

  void _handleTransform() {
    final nextScale = _controller.value.getMaxScaleOnAxis();
    if ((nextScale - _scale).abs() < 0.001) return;
    _scale = nextScale;
    widget.onScaleChanged(_scale);
  }

  @override
  Widget build(BuildContext context) {
    final viewer = InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: 4,
      panEnabled: _scale > 1.05,
      scaleEnabled: true,
      clipBehavior: Clip.none,
      child: Center(
        child: Image.file(
          File(widget.path),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 48,
          ),
        ),
      ),
    );

    if (_scale <= 1.05 && widget.onTapClose != null) {
      return GestureDetector(
        onTap: widget.onTapClose,
        behavior: HitTestBehavior.opaque,
        child: viewer,
      );
    }

    return viewer;
  }
}
