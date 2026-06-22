import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

typedef FrameStripLongPress = void Function(int frameIndex, ScriptFrame frame);

class FrameThumbnailStrip extends StatelessWidget {
  const FrameThumbnailStrip({
    super.key,
    required this.frames,
    required this.galleryPaths,
    required this.galleryCaptions,
    this.itemSize = 48,
    this.placeholderCount = 3,
    this.maxWidth,
    this.maxVisible,
    this.previewOptions,
    this.onExpandTap,
    this.onFrameLongPress,
  });

  final List<ScriptFrame> frames;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final double itemSize;
  final int placeholderCount;
  final double? maxWidth;
  final int? maxVisible;
  final ImagePreviewOptions? previewOptions;
  final VoidCallback? onExpandTap;
  final FrameStripLongPress? onFrameLongPress;

  @override
  Widget build(BuildContext context) {
    final strip = frames.isEmpty ? _buildPlaceholders() : _buildThumbnails();

    if (maxWidth != null) {
      return SizedBox(width: maxWidth, child: strip);
    }
    return strip;
  }

  Widget _buildPlaceholders() {
    return SizedBox(
      height: itemSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: placeholderCount,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, _) => _placeholderBox(),
      ),
    );
  }

  Widget _buildThumbnails() {
    final limit = maxVisible;
    final visibleCount =
        limit != null && frames.length > limit ? limit : frames.length;
    final overflow = limit != null && frames.length > limit
        ? frames.length - limit
        : 0;

    return SizedBox(
      height: itemSize,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: visibleCount,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) => _buildThumb(index),
            ),
          ),
          if (overflow > 0) ...[
            const SizedBox(width: 4),
            _OverflowBadge(
              count: overflow,
              onTap: onExpandTap,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumb(int index) {
    final frame = frames[index];
    final globalIndex = galleryPaths.indexOf(frame.effectiveDisplayPath);

    Widget thumb = SizedBox(
      width: itemSize,
      height: itemSize,
      child: PoseCoverImage(
        imagePath: frame.effectiveDisplayPath,
        expand: true,
        borderRadius: AppDimensions.radiusSm,
        iconSize: itemSize * 0.35,
        enablePreview: true,
        previewGallery: galleryPaths,
        previewIndex: globalIndex >= 0 ? globalIndex : index,
        previewCaptions: galleryCaptions,
        previewOptions: previewOptions,
        isUploaded: frame.isRemoteUploaded,
      ),
    );

    if (onFrameLongPress != null) {
      thumb = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => onFrameLongPress!(index, frame),
        child: thumb,
      );
    }

    return thumb;
  }

  Widget _placeholderBox() {
    return Container(
      width: itemSize,
      height: itemSize,
      decoration: BoxDecoration(
        color: AppColors.placeholder,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }
}

class _OverflowBadge extends StatelessWidget {
  const _OverflowBadge({required this.count, this.onTap});

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '+$count',
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
