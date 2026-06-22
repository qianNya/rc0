import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/pose_cover_image.dart';

typedef FrameThumbnailOverlayBuilder = Widget? Function(
  BuildContext context,
  int frameIndex,
  ScriptFrame frame,
);

typedef FrameGridLongPress = void Function(int frameIndex, ScriptFrame frame);

/// Grid of screenplay frames with shared full-screen gallery preview.
class FrameThumbnailGrid extends StatelessWidget {
  const FrameThumbnailGrid({
    super.key,
    required this.frames,
    required this.galleryPaths,
    required this.galleryCaptions,
    this.crossAxisCount = 3,
    this.showCaptions = true,
    this.borderRadius = AppDimensions.radiusSm,
    this.iconSize = 20,
    this.frameOverlayBuilder,
    this.onFrameLongPress,
  });

  final List<ScriptFrame> frames;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final int crossAxisCount;
  final bool showCaptions;
  final double borderRadius;
  final double iconSize;
  final FrameThumbnailOverlayBuilder? frameOverlayBuilder;
  final FrameGridLongPress? onFrameLongPress;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: showCaptions ? 1 : 1,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final globalIndex = galleryPaths.indexOf(frame.effectiveDisplayPath);
        final overlay = frameOverlayBuilder?.call(context, index, frame);

        Widget imageStack = Stack(
          fit: StackFit.expand,
          children: [
            PoseCoverImage(
              imagePath: frame.effectiveDisplayPath,
              expand: true,
              borderRadius: borderRadius,
              iconSize: iconSize,
              enablePreview: true,
              previewGallery: galleryPaths,
              previewIndex: globalIndex >= 0 ? globalIndex : index,
              previewCaptions: galleryCaptions,
              isUploaded: frame.isRemoteUploaded,
            ),
            ?overlay,
          ],
        );

        if (onFrameLongPress != null) {
          imageStack = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => onFrameLongPress!(index, frame),
            child: imageStack,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: imageStack),
            if (showCaptions && frame.caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  frame.caption,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> showScreenplayFramePreview(
  BuildContext context, {
  required Screenplay screenplay,
  int initialIndex = 0,
}) {
  final frames = screenplay.allFrames;
  return showImagePreview(
    context,
    imagePaths: frames.map((f) => f.effectiveDisplayPath).toList(),
    initialIndex: initialIndex,
    captions: frames.map((f) => f.caption).toList(),
    options: ImagePreviewOptions(sourceLabel: screenplay.title),
  );
}
