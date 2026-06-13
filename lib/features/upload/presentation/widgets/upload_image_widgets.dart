import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/upload_image_file.dart';

class UploadDropZone extends StatelessWidget {
  const UploadDropZone({
    super.key,
    required this.compact,
    required this.onTap,
    required this.selectedCount,
    this.enabled = true,
  });

  final bool compact;
  final VoidCallback onTap;
  final int selectedCount;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: CustomPaint(
          painter: _DashedBorderPainter(enabled: enabled),
          child: SizedBox(
            width: double.infinity,
            height: compact ? 180 : 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: compact ? 36 : 48,
                  color: enabled ? AppColors.accent : AppColors.textTertiary,
                ),
                const SizedBox(height: 8),
                Text(
                  compact ? '点击从相册选择照片' : '点击选择图片文件',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  '支持 JPG、PNG、WEBP，已选 $selectedCount 张',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedImageGrid extends StatelessWidget {
  const SelectedImageGrid({
    super.key,
    required this.files,
    required this.onRemove,
    this.compact = false,
  });

  final List<UploadImageFile> files;
  final ValueChanged<int> onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: compact ? 3 : 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        return _ImageThumb(
          file: files[index],
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}

class SelectedImagePathList extends StatelessWidget {
  const SelectedImagePathList({super.key, required this.files});

  final List<UploadImageFile> files;

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('已选文件路径', style: AppTextStyles.label),
        const SizedBox(height: 8),
        ...files.map(
          (file) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(file.name, style: AppTextStyles.label.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                SelectableText(
                  file.displayPath,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                if (file.sizeLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(file.sizeLabel, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.file, required this.onRemove});

  final UploadImageFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          child: Image.file(
            File(file.path),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => ColoredBox(
              color: AppColors.placeholder,
              child: Icon(Icons.broken_image_outlined,
                  color: AppColors.textTertiary),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.enabled});

  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = enabled ? AppColors.border : AppColors.border.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        const Radius.circular(AppDimensions.radiusMd),
      ));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.enabled != enabled;
}
