import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../domain/shoot_params.dart';
import 'screenplay_shoot_params_chips.dart';

class ScreenplayInfoHeader extends StatelessWidget {
  const ScreenplayInfoHeader({
    super.key,
    required this.screenplay,
    this.titleStyle,
    this.shootDefaults,
    this.onShootParamsTap,
    this.showTitle = true,
    this.showHierarchySummary = true,
    this.showShootParams = true,
  });

  final Screenplay screenplay;
  final TextStyle? titleStyle;
  final ShootParams? shootDefaults;
  final VoidCallback? onShootParamsTap;
  final bool showTitle;
  final bool showHierarchySummary;
  final bool showShootParams;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            screenplay.title,
            style: titleStyle ?? AppTextStyles.display.copyWith(fontSize: 22),
          ),
          if (screenplay.isForkCopy ||
              screenplay.effectiveForkSourceId != null) ...[
            const SizedBox(height: 6),
            _InfoForkSourceLink(sourceId: screenplay.effectiveForkSourceId),
          ],
          const SizedBox(height: 8),
        ],
        if (showHierarchySummary) ...[
          Text(
            screenplay.hierarchySummary,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (showShootParams &&
            shootDefaults != null &&
            shootDefaults!.hasAnyValue) ...[
          if (showHierarchySummary) const SizedBox(height: 10),
          ScreenplayShootParamsChips(
            params: shootDefaults!,
            onTap: onShootParamsTap,
            compact: true,
          ),
        ],
        if (screenplay.createdAt != null) ...[
          if (showTitle || showHierarchySummary || showShootParams)
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

class _InfoForkSourceLink extends StatelessWidget {
  const _InfoForkSourceLink({this.sourceId});

  final int? sourceId;

  @override
  Widget build(BuildContext context) {
    final canOpen = sourceId != null && sourceId! > 0;
    final label = canOpen ? '翻拍自 #$sourceId' : '翻拍自已失效模板';
    final style = AppTextStyles.bodySecondary.copyWith(
      fontSize: 13,
      color: canOpen ? AppColors.accent : null,
      decoration: canOpen ? TextDecoration.underline : null,
      decorationColor: AppColors.accent,
    );
    if (!canOpen) {
      return Text(label, style: style);
    }
    return GestureDetector(
      onTap: () => context.push(AppRoutes.script('$sourceId')),
      child: Text(label, style: style),
    );
  }
}
