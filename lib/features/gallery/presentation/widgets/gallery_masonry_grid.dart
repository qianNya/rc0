import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/gallery_image.dart';
import 'gallery_image_tile.dart';

const _kMasonryAspectRatios = [0.72, 0.95, 1.15, 0.82, 1.05];

/// Distributes [itemCount] items across [columnCount] columns by shortest height.
List<List<int>> distributeToShortestColumns({
  required int itemCount,
  required int columnCount,
  List<double> aspectRatios = _kMasonryAspectRatios,
}) {
  if (itemCount <= 0 || columnCount <= 0) return const [];

  final columns = List.generate(columnCount, (_) => <int>[]);
  final heights = List.filled(columnCount, 0.0);

  for (var i = 0; i < itemCount; i++) {
    var shortest = 0;
    for (var c = 1; c < columnCount; c++) {
      if (heights[c] < heights[shortest]) shortest = c;
    }
    columns[shortest].add(i);
    final ratio = aspectRatios[i % aspectRatios.length];
    heights[shortest] += ratio > 0 ? 1 / ratio : 1;
  }

  return columns;
}

class GalleryMasonryGrid extends StatelessWidget {
  const GalleryMasonryGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.crossAxisCount = 3,
    this.spacing = AppDimensions.spacingSm,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
    ),
  });

  final List<GalleryImage> items;
  final void Function(int index) onTap;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final columns = distributeToShortestColumns(
      itemCount: items.length,
      columnCount: crossAxisCount,
    );

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var col = 0; col < columns.length; col++) ...[
            if (col > 0) SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < columns[col].length; i++) ...[
                    if (i > 0) SizedBox(height: spacing),
                    Builder(
                      builder: (context) {
                        final index = columns[col][i];
                        final ratio =
                            _kMasonryAspectRatios[index % _kMasonryAspectRatios.length];
                        return AspectRatio(
                          aspectRatio: ratio,
                          child: GalleryImageTile(
                            image: items[index],
                            onTap: () => onTap(index),
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
    );
  }
}
