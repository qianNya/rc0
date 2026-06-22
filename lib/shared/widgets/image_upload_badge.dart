import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class ImageUploadBadge extends StatelessWidget {
  const ImageUploadBadge({
    super.key,
    required this.isUploaded,
    this.size = 14,
    this.padding = 3,
  });

  final bool isUploaded;
  final double size;
  final double padding;

  @override
  Widget build(BuildContext context) {
    if (!isUploaded) return const SizedBox.shrink();

    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.cloud_done,
          size: size,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
