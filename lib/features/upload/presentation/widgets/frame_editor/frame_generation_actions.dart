import 'package:flutter/material.dart';

import '../../../../../shared/widgets/primary_button.dart';

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
          child: PrimaryButton(
            label: '生成图片',
            isLoading: isLoading,
            onPressed: onGenerateImage,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: '生成视频',
            onPressed: onGenerateVideo,
          ),
        ),
      ],
    );
  }
}
