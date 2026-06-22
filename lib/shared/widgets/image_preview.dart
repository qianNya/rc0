import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/services/image_favorite_store.dart';
import '../../core/utils/image_url_utils.dart';

export '../../core/utils/image_url_utils.dart' show isNetworkImagePath;
import '../services/image_save_service.dart';
import 'rc0_image.dart';

/// Whether [path] can be shown in full-screen preview (local file or network URL).
bool isPreviewableImagePath(String path) {
  if (path.isEmpty) return false;
  final resolved = resolveNetworkImageUrl(path) ?? path;
  if (isNetworkImagePath(resolved)) {
    return isValidNetworkImageUrl(resolved);
  }
  return File(resolved).existsSync();
}

List<String> filterPreviewablePaths(List<String> paths) {
  return paths.where(isPreviewableImagePath).toList(growable: false);
}

/// Maps [initialIndex] in [allPaths] to the index in previewable-only list.
int resolvePreviewIndex(List<String> allPaths, int initialIndex) {
  if (allPaths.isEmpty) return 0;

  final safe = initialIndex.clamp(0, allPaths.length - 1);
  final filtered = filterPreviewablePaths(allPaths);
  if (filtered.isEmpty) return 0;

  final target = allPaths[safe];
  final direct = filtered.indexOf(target);
  if (direct >= 0) return direct;

  var count = 0;
  for (var i = 0; i < safe; i++) {
    if (isPreviewableImagePath(allPaths[i])) count++;
  }
  return count.clamp(0, filtered.length - 1);
}

class ImagePreviewOptions {
  const ImagePreviewOptions({
    this.sourceLabel,
    this.favoriteKeys,
  });

  final String? sourceLabel;
  final List<String>? favoriteKeys;
}

({List<String> paths, List<String>? captions, List<String>? favoriteKeys})
    _filterPreviewGallery(
  List<String> imagePaths,
  List<String>? captions,
  List<String>? favoriteKeys,
) {
  final paths = <String>[];
  final filteredCaptions = captions != null ? <String>[] : null;
  final filteredKeys = favoriteKeys != null ? <String>[] : null;

  for (var i = 0; i < imagePaths.length; i++) {
    final path = imagePaths[i];
    if (!isPreviewableImagePath(path)) continue;
    paths.add(path);
    if (filteredCaptions != null && captions != null && i < captions.length) {
      filteredCaptions.add(captions[i]);
    }
    if (filteredKeys != null && favoriteKeys != null && i < favoriteKeys.length) {
      filteredKeys.add(favoriteKeys[i]);
    } else if (filteredKeys != null) {
      filteredKeys.add(path);
    }
  }

  return (
    paths: paths,
    captions: filteredCaptions,
    favoriteKeys: filteredKeys,
  );
}

/// 打开全屏图片预览：未放大时左右滑动切换，放大后拖动查看细节。
Future<void> showImagePreview(
  BuildContext context, {
  required List<String> imagePaths,
  int initialIndex = 0,
  List<String>? captions,
  ImagePreviewOptions? options,
}) {
  final filtered = _filterPreviewGallery(
    imagePaths,
    captions,
    options?.favoriteKeys,
  );
  if (filtered.paths.isEmpty) return Future.value();

  final safeIndex = resolvePreviewIndex(imagePaths, initialIndex)
      .clamp(0, filtered.paths.length - 1);

  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _ImagePreviewPage(
            imagePaths: filtered.paths,
            initialIndex: safeIndex,
            captions: filtered.captions,
            sourceLabel: options?.sourceLabel,
            favoriteKeys: filtered.favoriteKeys,
          ),
        );
      },
    ),
  );
}

enum _ViewMode { single, grid }

class _ImagePreviewPage extends StatefulWidget {
  const _ImagePreviewPage({
    required this.imagePaths,
    required this.initialIndex,
    this.captions,
    this.sourceLabel,
    this.favoriteKeys,
  });

  final List<String> imagePaths;
  final int initialIndex;
  final List<String>? captions;
  final String? sourceLabel;
  final List<String>? favoriteKeys;

  @override
  State<_ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<_ImagePreviewPage> {
  late final PageController _pageController;
  late final ScrollController _thumbController;
  late final FocusNode _focusNode;
  late int _currentIndex;
  bool _pageScrollEnabled = true;
  _ViewMode _viewMode = _ViewMode.single;
  bool _actionLoading = false;

  final _saveService = ImageSaveService.instance;

  bool get _hasMultiple => widget.imagePaths.length > 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbController = ScrollController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _scrollThumbToCurrent(animate: false);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    _thumbController.dispose();
    super.dispose();
  }

  String get _currentPath => widget.imagePaths[_currentIndex];

  String get _currentFavoriteKey {
    final keys = widget.favoriteKeys;
    if (keys != null && _currentIndex < keys.length) {
      return keys[_currentIndex];
    }
    return _currentPath;
  }

  String? get _currentCaption {
    final captions = widget.captions;
    if (captions == null || _currentIndex >= captions.length) return null;
    final text = captions[_currentIndex].trim();
    return text.isEmpty ? null : text;
  }

  ImageFavoriteStore? get _favoriteStore => ImageFavoriteStore.instance;

  bool get _isFavorited =>
      _favoriteStore?.isFavorite(_currentFavoriteKey) ?? false;

  void _onZoomScaleChanged(double scale) {
    final enablePageScroll = scale <= 1.05;
    if (enablePageScroll != _pageScrollEnabled) {
      setState(() => _pageScrollEnabled = enablePageScroll);
    }
  }

  void _goToPage(int index, {bool fromGrid = false}) {
    if (index < 0 || index >= widget.imagePaths.length) return;
    if (index == _currentIndex && !fromGrid) return;

    if (_viewMode == _ViewMode.grid) {
      setState(() {
        _viewMode = _ViewMode.single;
        _currentIndex = index;
        _pageScrollEnabled = true;
      });
      _pageController.jumpToPage(index);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollThumbToCurrent();
      });
      return;
    }

    if (!_hasMultiple) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _goPrevious() => _goToPage(_currentIndex - 1);

  void _goNext() => _goToPage(_currentIndex + 1);

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == _ViewMode.single
          ? _ViewMode.grid
          : _ViewMode.single;
    });
  }

  void _scrollThumbToCurrent({bool animate = true}) {
    if (!_thumbController.hasClients || !_hasMultiple) return;
    const itemWidth = 56.0;
    const spacing = 8.0;
    final offset = _currentIndex * (itemWidth + spacing);
    final maxScroll = _thumbController.position.maxScrollExtent;
    final target = offset.clamp(0.0, maxScroll);

    if (animate) {
      _thumbController.animateTo(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    } else {
      _thumbController.jumpTo(target);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onDownload() async {
    if (_actionLoading) return;
    setState(() => _actionLoading = true);

    final result = await _saveService.saveImageToDownloads(_currentPath);

    if (!mounted) return;
    setState(() => _actionLoading = false);

    if (result.success) {
      _showSnack('已保存至 ${result.path}');
    } else {
      _showSnack(result.error ?? '保存失败');
    }
  }

  Future<void> _onShare() async {
    if (_actionLoading) return;
    setState(() => _actionLoading = true);

    final localPath = await _saveService.resolveLocalImagePath(_currentPath);

    if (!mounted) return;
    setState(() => _actionLoading = false);

    if (localPath == null) {
      _showSnack('无法分享该图片');
      return;
    }

    final caption = _currentCaption;
    await Share.shareXFiles(
      [XFile(localPath)],
      text: caption,
    );
  }

  Future<void> _onToggleFavorite() async {
    final store = _favoriteStore;
    if (store == null) {
      _showSnack('收藏服务不可用');
      return;
    }

    final added = await store.toggle(
      id: _currentFavoriteKey,
      imagePath: _currentPath,
      caption: _currentCaption,
      sourceLabel: widget.sourceLabel,
    );
    if (!mounted) return;
    setState(() {});
    _showSnack(added ? '已加入收藏' : '已取消收藏');
  }

  void _onMore() {
    final caption = _currentCaption;
    final isNetwork = isNetworkImagePath(_currentPath);
    final isFav = _isFavorited;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (context) {
        return Material(
          color: AppColors.surface,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (caption != null)
                  ListTile(
                    leading: const Icon(Icons.notes_outlined),
                    title: const Text('查看说明'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog<void>(
                        context: this.context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('画格说明'),
                          content: Text(caption),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('关闭'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (isNetwork)
                  ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('复制链接'),
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: _currentPath));
                      _showSnack('链接已复制');
                    },
                  ),
                if (!isNetwork)
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: const Text('复制本地路径'),
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: _currentPath));
                      _showSnack('路径已复制');
                    },
                  ),
                if (isFav)
                  ListTile(
                    leading: const Icon(
                      Icons.favorite,
                      color: AppColors.accent,
                    ),
                    title: const Text('取消收藏'),
                    onTap: () async {
                      final store = _favoriteStore;
                      if (store == null) return;
                      Navigator.pop(context);
                      await store.remove(_currentFavoriteKey);
                      if (!mounted) return;
                      setState(() {});
                      _showSnack('已取消收藏');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        if (_viewMode == _ViewMode.single) _goPrevious();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowRight:
        if (_viewMode == _ViewMode.single) _goNext();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        if (_viewMode == _ViewMode.grid) {
          setState(() => _viewMode = _ViewMode.single);
        } else {
          Navigator.of(context).pop();
        }
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.only(
              top: viewPadding.top,
              bottom: viewPadding.bottom,
            ),
            child: Column(
              children: [
                _PreviewTopBar(
                  currentIndex: _currentIndex,
                  total: widget.imagePaths.length,
                  isGridMode: _viewMode == _ViewMode.grid,
                  onClose: () => Navigator.of(context).pop(),
                  onToggleGrid: _hasMultiple ? _toggleViewMode : null,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _viewMode == _ViewMode.grid
                        ? _PreviewGridOverlay(
                            key: const ValueKey('grid'),
                            imagePaths: widget.imagePaths,
                            captions: widget.captions,
                            onTap: (index) => _goToPage(index, fromGrid: true),
                          )
                        : _PreviewMainArea(
                            key: const ValueKey('single'),
                            pageController: _pageController,
                            imagePaths: widget.imagePaths,
                            currentIndex: _currentIndex,
                            pageScrollEnabled: _pageScrollEnabled,
                            hasMultiple: _hasMultiple,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                                _pageScrollEnabled = true;
                              });
                              _scrollThumbToCurrent();
                            },
                            onScaleChanged: _onZoomScaleChanged,
                            onPrevious: _goPrevious,
                            onNext: _goNext,
                          ),
                  ),
                ),
                if (_viewMode == _ViewMode.single && _hasMultiple)
                  _PreviewThumbnailStrip(
                    controller: _thumbController,
                    imagePaths: widget.imagePaths,
                    currentIndex: _currentIndex,
                    onTap: _goToPage,
                  ),
                if (_viewMode == _ViewMode.single)
                  _PreviewBottomBar(
                    isFavorited: _isFavorited,
                    loading: _actionLoading,
                    onDownload: _onDownload,
                    onFavorite: _onToggleFavorite,
                    onShare: _onShare,
                    onMore: _onMore,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewTopBar extends StatelessWidget {
  const _PreviewTopBar({
    required this.currentIndex,
    required this.total,
    required this.isGridMode,
    required this.onClose,
    this.onToggleGrid,
  });

  final int currentIndex;
  final int total;
  final bool isGridMode;
  final VoidCallback onClose;
  final VoidCallback? onToggleGrid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: '关闭（Esc）',
          ),
          Expanded(
            child: Text(
              '${currentIndex + 1} / $total',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onToggleGrid != null)
            IconButton(
              onPressed: onToggleGrid,
              icon: Icon(
                isGridMode ? Icons.photo_library_outlined : Icons.grid_view,
                color: Colors.white,
              ),
              tooltip: isGridMode ? '单张预览' : '网格总览',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PreviewMainArea extends StatelessWidget {
  const _PreviewMainArea({
    super.key,
    required this.pageController,
    required this.imagePaths,
    required this.currentIndex,
    required this.pageScrollEnabled,
    required this.hasMultiple,
    required this.onPageChanged,
    required this.onScaleChanged,
    required this.onPrevious,
    required this.onNext,
  });

  final PageController pageController;
  final List<String> imagePaths;
  final int currentIndex;
  final bool pageScrollEnabled;
  final bool hasMultiple;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<double> onScaleChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: PageView.builder(
            controller: pageController,
            physics: pageScrollEnabled
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: imagePaths.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: _ZoomableImage(
                    key: ValueKey(imagePaths[index]),
                    path: imagePaths[index],
                    onScaleChanged: onScaleChanged,
                  ),
                ),
              );
            },
          ),
        ),
        if (hasMultiple) ...[
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _PreviewNavButton(
                icon: Icons.chevron_left,
                tooltip: '上一张（←）',
                enabled: currentIndex > 0,
                onPressed: onPrevious,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _PreviewNavButton(
                icon: Icons.chevron_right,
                tooltip: '下一张（→）',
                enabled: currentIndex < imagePaths.length - 1,
                onPressed: onNext,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PreviewThumbnailStrip extends StatelessWidget {
  const _PreviewThumbnailStrip({
    required this.controller,
    required this.imagePaths,
    required this.currentIndex,
    required this.onTap,
  });

  final ScrollController controller;
  final List<String> imagePaths;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _thumbSize = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: imagePaths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final path = imagePaths[index];
          final selected = index == currentIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              width: _thumbSize,
              height: _thumbSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                border: Border.all(
                  color: selected ? AppColors.accent : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm - 2),
                child: _ThumbImage(path: path),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThumbImage extends StatelessWidget {
  const _ThumbImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveNetworkImageUrl(path) ?? path;
    if (isNetworkImagePath(resolved) && !isValidNetworkImageUrl(resolved)) {
      return const ColoredBox(
        color: AppColors.placeholder,
        child: Icon(Icons.broken_image_outlined, size: 20),
      );
    }

    return Rc0Image(
      path: resolved,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: const ColoredBox(
        color: AppColors.placeholder,
        child: Icon(Icons.broken_image_outlined, size: 20),
      ),
    );
  }
}

class _PreviewGridOverlay extends StatelessWidget {
  const _PreviewGridOverlay({
    super.key,
    required this.imagePaths,
    required this.captions,
    required this.onTap,
  });

  final List<String> imagePaths;
  final List<String>? captions;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: imagePaths.length,
      itemBuilder: (context, index) {
        final caption = captions != null && index < captions!.length
            ? captions![index]
            : '';

        return GestureDetector(
          onTap: () => onTap(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  child: _ThumbImage(path: imagePaths[index]),
                ),
              ),
              if (caption.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    caption,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PreviewBottomBar extends StatelessWidget {
  const _PreviewBottomBar({
    required this.isFavorited,
    required this.loading,
    required this.onDownload,
    required this.onFavorite,
    required this.onShare,
    required this.onMore,
  });

  final bool isFavorited;
  final bool loading;
  final VoidCallback onDownload;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          _BottomAction(
            icon: Icons.download_outlined,
            label: '下载',
            onTap: loading ? null : onDownload,
          ),
          _BottomAction(
            icon: isFavorited ? Icons.favorite : Icons.favorite_border,
            label: '收藏',
            iconColor: isFavorited ? AppColors.accent : Colors.white,
            onTap: loading ? null : onFavorite,
          ),
          _BottomAction(
            icon: Icons.send_outlined,
            label: '分享',
            onTap: loading ? null : onShare,
          ),
          _BottomAction(
            icon: Icons.open_in_new,
            label: '更多',
            onTap: onMore,
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null ? Colors.white38 : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
  });

  final String path;
  final ValueChanged<double> onScaleChanged;

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

  Widget _buildImage() {
    final resolved = resolveNetworkImageUrl(widget.path) ?? widget.path;
    if (isNetworkImagePath(resolved) && !isValidNetworkImageUrl(resolved)) {
      return const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 48,
      );
    }

    return Rc0Image(
      path: resolved,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorWidget: const Icon(
        Icons.broken_image_outlined,
        color: Colors.white54,
        size: 48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: 4,
      panEnabled: _scale > 1.05,
      scaleEnabled: true,
      clipBehavior: Clip.none,
      child: Center(child: _buildImage()),
    );
  }
}
