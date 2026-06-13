import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class ScreenplayInfoHeader extends StatelessWidget {
  const ScreenplayInfoHeader({
    super.key,
    required this.screenplay,
    this.titleStyle,
  });

  final Screenplay screenplay;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          screenplay.title,
          style: titleStyle ?? AppTextStyles.display.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          screenplay.hierarchySummary,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (screenplay.createdAt != null) ...[
          const SizedBox(height: 6),
          Text(
            '发布于 ${_formatDate(screenplay.createdAt!)}',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
        ],
        if (screenplay.tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in screenplay.tags)
                TagChip(label: tag, selected: true),
            ],
          ),
        ],
        if (screenplay.synopsis.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(screenplay.synopsis, style: AppTextStyles.body),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
