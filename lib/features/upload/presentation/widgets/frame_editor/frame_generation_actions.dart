import 'package:flutter/material.dart';
import '../../../../../shared/widgets/glass/glass.dart';


class FrameGenerationActions extends StatelessWidget {
  const FrameGenerationActions({
    super.key,
    this.onGenerateImage,
    this.onGenerateVideo,
    this.isLoading = false,
  });

  final VoidCallback? onGenerateImage;
  final VoidCallback? onGenerateVideo;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassButton(
                filled: true,
                expand: true,
            label: '生成图片',
            loading: isLoading,
            onPressed: onGenerateImage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassButton(
                filled: true,
                expand: true,
            label: '生成视频',
            onPressed: onGenerateVideo,
          ),
        ),
      ],
    );
  }
}
