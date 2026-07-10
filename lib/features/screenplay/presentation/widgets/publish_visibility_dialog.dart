import 'package:flutter/material.dart';

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
    return showGlassDialog<PublishOptions>(
      context,
      barrierDismissible: true,
      child: const PublishVisibilityDialog(),
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
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: GlassButton(
                label: '取消',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: GlassButton(
                label: '开始发布',
                filled: true,
                onPressed: () => Navigator.of(context).pop(
                  PublishOptions(visibility: _visibility, kind: _kind),
                ),
              ),
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

/// Progress body shown inside [showGlassProgressSheet].
class PublishProgressContent extends StatelessWidget {
  const PublishProgressContent({
    super.key,
    required this.stage,
    required this.done,
    required this.total,
  });

  final String stage;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? done / total : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          total > 0 ? '$stage $done/$total' : stage,
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.tabFloatingRadius),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: total > 0 ? progress : null,
          ),
        ),
      ],
    );
  }
}

/// Shows a glass progress sheet for publish / sync operations.
Future<void> showPublishProgressSheet(
  BuildContext context, {
  required ValueNotifier<(String stage, int done, int total)> progress,
}) {
  return showGlassProgressSheet<void>(
    context,
    title: '正在发布',
    isDismissible: false,
    child: ValueListenableBuilder(
      valueListenable: progress,
      builder: (context, value, _) => PublishProgressContent(
        stage: value.$1,
        done: value.$2,
        total: value.$3,
      ),
    ),
  );
}

/// @deprecated Use [showPublishProgressSheet] instead.
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

  @override
  Widget build(BuildContext context) {
    return PublishProgressContent(stage: stage, done: done, total: total);
  }
}
