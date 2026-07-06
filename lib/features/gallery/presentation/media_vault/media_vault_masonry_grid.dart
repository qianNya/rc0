import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../domain/media_vault_image.dart';
import '../widgets/gallery_masonry_grid.dart';
import 'media_vault_colors.dart';
import 'media_vault_image_card.dart';

double _masonryTileAspectRatio(MediaVaultImage image) =>
    image.displayAspectRatio;

/// Masonry grid — pinch to change column count, native image aspect ratios.
class MediaVaultMasonryGrid extends StatefulWidget {
  const MediaVaultMasonryGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.selectedId,
    this.columnCount = 3,
    this.onColumnCountChanged,
    this.onLoadMore,
    this.loadingMore = false,
  });

  final List<MediaVaultImage> items;
  final ValueChanged<MediaVaultImage> onTap;
  final String? selectedId;
  final int columnCount;
  final ValueChanged<int>? onColumnCountChanged;
  final VoidCallback? onLoadMore;
  final bool loadingMore;

  @override
  State<MediaVaultMasonryGrid> createState() => _MediaVaultMasonryGridState();
}

class _MediaVaultMasonryGridState extends State<MediaVaultMasonryGrid> {
  static const _pinchOutThreshold = 1.12;
  static const _pinchInThreshold = 0.88;

  bool _pinchHandled = false;

  List<double> get _aspectRatios => widget.items
      .map(_masonryTileAspectRatio)
      .toList(growable: false);

  void _onScaleStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;
    _pinchHandled = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2 || _pinchHandled) return;

    final columns = widget.columnCount.clamp(2, 6);

    if (details.scale >= _pinchOutThreshold && columns > 2) {
      widget.onColumnCountChanged?.call(columns - 1);
      _pinchHandled = true;
    } else if (details.scale <= _pinchInThreshold && columns < 6) {
      widget.onColumnCountChanged?.call(columns + 1);
      _pinchHandled = true;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      return;
    }

    final columns = widget.columnCount.clamp(2, 6);
    if (event.scrollDelta.dy < 0 && columns > 2) {
      widget.onColumnCountChanged?.call(columns - 1);
    } else if (event.scrollDelta.dy > 0 && columns < 6) {
      widget.onColumnCountChanged?.call(columns + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(
        child: Text(
          '暂无图片',
          style: TextStyle(color: MediaVaultColors.textSecondary),
        ),
      );
    }

    final columnsCount = widget.columnCount.clamp(2, 6);
    final ratios = _aspectRatios;
    final columns = distributeToShortestColumns(
      itemCount: widget.items.length,
      columnCount: columnsCount,
      aspectRatios: ratios,
    );

    return Listener(
      onPointerSignal: _onPointerSignal,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollEndNotification &&
                n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              widget.onLoadMore?.call();
            }
            return false;
          },
          child: CustomScrollView(
            key: ValueKey(columnsCount),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  AppDimensions.spacingSm,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingLg,
                ),
                sliver: SliverToBoxAdapter(
                  child: FeedGridScope(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: Row(
                        key: ValueKey('cols-$columnsCount'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var col = 0; col < columns.length; col++) ...[
                            if (col > 0)
                              const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              child: Column(
                                children: [
                                  for (var i = 0;
                                      i < columns[col].length;
                                      i++) ...[
                                    if (i > 0)
                                      const SizedBox(
                                        height: AppDimensions.spacingSm,
                                      ),
                                    Builder(
                                      builder: (context) {
                                        final index = columns[col][i];
                                        final item = widget.items[index];
                                        return AspectRatio(
                                          aspectRatio: item.displayAspectRatio,
                                          child: MediaVaultImageCard(
                                            image: item,
                                            selected:
                                                item.id == widget.selectedId,
                                            onTap: () => widget.onTap(item),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MediaVaultColors.accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
