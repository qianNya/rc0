import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';

class ProjectStatusHeader extends StatelessWidget {
  const ProjectStatusHeader({
    super.key,
    required this.draft,
    this.statusLabel = '创作中',
  });

  final ScreenplayDraft draft;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final title = draft.title.trim().isEmpty ? '未命名剧本' : draft.title.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.display.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            '$statusLabel · ${draftHierarchySummary(draft)}',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
