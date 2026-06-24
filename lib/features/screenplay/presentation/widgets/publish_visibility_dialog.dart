import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import 'screenplay_visibility_sheet.dart';

/// Dialog for choosing screenplay visibility before publish.
class PublishVisibilityDialog extends StatefulWidget {
  const PublishVisibilityDialog({super.key});

  static Future<int?> show(BuildContext context) {
    return showDialog<int>(
      context: context,
      builder: (_) => const PublishVisibilityDialog(),
    );
  }

  @override
  State<PublishVisibilityDialog> createState() =>
      _PublishVisibilityDialogState();
}

class _PublishVisibilityDialogState extends State<PublishVisibilityDialog> {
  int _visibility = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发布剧本'),
      content: ScreenplayVisibilityOptions(
        value: _visibility,
        onChanged: (v) => setState(() => _visibility = v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_visibility),
          child: const Text('开始发布'),
        ),
      ],
    );
  }
}

class PublishProgressSheet extends StatelessWidget {
  const PublishProgressSheet({
    super.key,
    required this.stage,
    required this.done,
    required this.total,
  });

  final String stage;
  final int done;
  final int total;

  static Future<void> show(
    BuildContext context, {
    required String stage,
    required int done,
    required int total,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PublishProgressSheet(
        stage: stage,
        done: done,
        total: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? done / total : 0.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('正在发布', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Text(
            total > 0 ? '$stage $done/$total' : stage,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: total > 0 ? progress : null),
          const SizedBox(height: 8),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }
}
