import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/glass/glass.dart';
import 'screenplay_visibility_sheet.dart';

/// Result of the publish options dialog (visibility + kind).
class PublishOptions {
  const PublishOptions({
    required this.visibility,
    required this.kind,
  });

  /// 0 private · 1 public
  final int visibility;

  /// 1 personal work · 2 template
  final int kind;
}

/// Dialog for choosing visibility and publish kind before publish.
class PublishVisibilityDialog extends StatefulWidget {
  const PublishVisibilityDialog({super.key});

  static Future<PublishOptions?> show(BuildContext context) {
    return showDialog<PublishOptions>(
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
  int _kind = Screenplay.kindPersonal;

  void _onKindChanged(int kind) {
    setState(() {
      _kind = kind;
      if (kind == Screenplay.kindTemplate) {
        _visibility = 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTemplate = _kind == Screenplay.kindTemplate;
    return GlassDialog(
      title: const Text('发布剧本'),
      footer: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                PublishOptions(visibility: _visibility, kind: _kind),
              ),
              child: const Text('开始发布'),
            ),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('发布类型', style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppDimensions.spacingSm),
          GlassSegmentedControl(
            segments: const ['发布为作品', '发布为模板'],
            selectedIndex: isTemplate ? 1 : 0,
            onChanged: (i) => _onKindChanged(
              i == 1 ? Screenplay.kindTemplate : Screenplay.kindPersonal,
            ),
            margin: EdgeInsets.zero,
          ),
          if (isTemplate) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '模板将公开可见，并出现在模板市场',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingMd),
          ScreenplayVisibilityOptions(
            value: _visibility,
            onChanged: isTemplate
                ? null
                : (v) => setState(() => _visibility = v),
            privateEnabled: !isTemplate,
          ),
        ],
      ),
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
