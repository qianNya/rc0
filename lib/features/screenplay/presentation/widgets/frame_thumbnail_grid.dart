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

typedef FrameThumbnailFooterBuilder = Widget Function(
  BuildContext context,
  int frameIndex,
  ScriptFrame frame,
);

typedef FrameGridLongPress = void Function(int frameIndex, ScriptFrame frame);
typedef FrameGridTap = void Function(int frameIndex, ScriptFrame frame);

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
    this.frameFooterBuilder,
    this.onFrameTap,
    this.onFrameLongPress,
    this.previewOptions,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
    this.padding = EdgeInsets.zero,
  });

  final List<ScriptFrame> frames;
  final List<String> galleryPaths;
  final List<String> galleryCaptions;
  final int crossAxisCount;
  final bool showCaptions;
  final double borderRadius;
  final double iconSize;
  final FrameThumbnailOverlayBuilder? frameOverlayBuilder;
  final FrameThumbnailFooterBuilder? frameFooterBuilder;
  final FrameGridTap? onFrameTap;
  final FrameGridLongPress? onFrameLongPress;
  final ImagePreviewOptions? previewOptions;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  static const _captionLineHeight = 18.0;
  static const _footerAspectRatio = 0.82;

  double get _childAspectRatio {
    if (frameFooterBuilder != null) return _footerAspectRatio;
    if (!showCaptions) return 1;
    // Reserve space for caption line below the square thumbnail.
    return 0.82;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: frameFooterBuilder != null ? 6 : 8,
        crossAxisSpacing: frameFooterBuilder != null ? 6 : 8,
        childAspectRatio: _childAspectRatio,
      ),
      itemCount: frames.length,
      itemBuilder: (context, index) {
        final frame = frames[index];
        final globalIndex = galleryPaths.indexOf(frame.effectiveDisplayPath);
        final useOverlay =
            frameFooterBuilder == null && frameOverlayBuilder != null;
        final overlay = useOverlay
            ? frameOverlayBuilder!.call(context, index, frame)
            : null;
        final openEditor = onFrameTap != null;

        Widget thumbnail = Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            PoseCoverImage(
              imagePath: frame.effectiveDisplayPath,
              expand: true,
              borderRadius: borderRadius,
              iconSize: iconSize,
              enablePreview: !openEditor,
              previewGallery: galleryPaths,
              previewIndex: globalIndex >= 0 ? globalIndex : index,
              previewCaptions: galleryCaptions,
              previewOptions: previewOptions,
              isUploaded: frame.isRemoteUploaded,
            ),
            ?overlay,
          ],
        );

        final imageTile = ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: thumbnail,
        );

        Widget cell;
        if (frameFooterBuilder != null) {
          cell = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: imageTile),
              frameFooterBuilder!(context, index, frame),
            ],
          );
        } else if (!showCaptions) {
          cell = imageTile;
        } else {
          final caption = frame.caption.trim();
          cell = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: imageTile),
              if (caption.isNotEmpty)
                SizedBox(
                  height: _captionLineHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      caption,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          );
        }

        if (openEditor) {
          cell = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onFrameTap!(index, frame),
            child: cell,
          );
        } else if (onFrameLongPress != null) {
          cell = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () => onFrameLongPress!(index, frame),
            child: cell,
          );
        }

        return cell;
      },
    );
  }
}

Future<void> showScreenplayFramePreview(
  BuildContext context, {
  required Screenplay screenplay,
  int initialIndex = 0,
  ImagePreviewOptions? options,
}) {
  final frames = screenplay.allFrames;
  return showImagePreview(
    context,
    imagePaths: frames.map((f) => f.effectiveDisplayPath).toList(),
    initialIndex: initialIndex,
    captions: frames.map((f) => f.caption).toList(),
    options: options ??
        ImagePreviewOptions(sourceLabel: screenplay.title),
  );
}
