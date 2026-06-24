import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';

class StoryboardPlaybackBar extends StatelessWidget {
  const StoryboardPlaybackBar({
    super.key,
    required this.sceneLabel,
    required this.frameCount,
    required this.totalDurationSec,
    this.onPlay,
  });

  final String sceneLabel;
  final int frameCount;
  final int totalDurationSec;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sceneLabel,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$frameCount画 · 总时长：$totalDurationSec秒',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onPlay,
              icon: const Icon(Icons.play_circle_outline),
              color: AppColors.accent,
              iconSize: 36,
              tooltip: '播放',
            ),
          ],
        ),
      ),
    );
  }
}

void showPlaybackComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('播放功能即将上线')),
    );
}
