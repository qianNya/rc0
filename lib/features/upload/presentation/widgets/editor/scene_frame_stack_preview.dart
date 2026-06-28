import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../screenplay/data/screenplay_draft.dart';

/// Stacked frame thumbnails for scene outline rows (up to [maxVisible] layers).
class SceneFrameStackPreview extends StatelessWidget {
  const SceneFrameStackPreview({
    super.key,
    required this.frames,
    required this.onTap,
    this.thumbSize = 28,
    this.maxVisible = 5,
    this.stackOffset = 8,
  });

  final List<FrameDraft> frames;
  final VoidCallback onTap;
  final double thumbSize;
  final int maxVisible;
  final double stackOffset;

  int get _visibleCount =>
      frames.isEmpty ? 2 : frames.length.clamp(0, maxVisible);

  double get width =>
      thumbSize + (_visibleCount - 1) * stackOffset;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: thumbSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (frames.isEmpty)
              for (var i = 0; i < 2; i++)
                Positioned(
                  left: i * stackOffset,
                  child: _placeholderCard(isTop: i == 1),
                )
            else
              for (var i = 0; i < _visibleCount; i++)
                Positioned(
                  left: i * stackOffset,
                  child: _frameCard(
                    frame: frames[i],
                    isTop: i == _visibleCount - 1,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCard({required bool isTop}) {
    return _thumbShell(
      isTop: isTop,
      child: ColoredBox(
        color: AppColors.placeholder,
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: thumbSize * 0.42,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _frameCard({required FrameDraft frame, required bool isTop}) {
    return _thumbShell(
      isTop: isTop,
      child: PoseCoverImage(
        imagePath: frame.image.displayPath,
        expand: true,
        borderRadius: AppDimensions.radiusSm,
        iconSize: thumbSize * 0.35,
      ),
    );
  }

  Widget _thumbShell({required bool isTop, required Widget child}) {
    return Container(
      width: thumbSize,
      height: thumbSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: isTop ? Colors.white : AppColors.border,
          width: isTop ? 1.5 : 1,
        ),
        boxShadow: isTop
            ? const [
                BoxShadow(
                  color: AppColors.shadowStrong,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
