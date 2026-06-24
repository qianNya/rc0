import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/shoot_params.dart';

class ScreenplayShootParamsChips extends StatelessWidget {
  const ScreenplayShootParamsChips({
    super.key,
    required this.params,
    this.inheritedHint,
    this.onTap,
    this.compact = false,
  });

  final ShootParams params;
  final String? inheritedHint;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = <({String label, String? value})>[
      (label: '设备', value: params.device),
      (label: '画幅', value: params.aspectRatio),
      (label: '打光', value: params.lighting),
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inheritedHint != null) ...[
          Text(
            inheritedHint!,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 6),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip in chips)
              _ShootParamChip(
                label: chip.label,
                value: chip.value,
                compact: compact,
              ),
          ],
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              Icon(
                Icons.chevron_right,
                size: compact ? 18 : 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShootParamChip extends StatelessWidget {
  const _ShootParamChip({
    required this.label,
    required this.value,
    required this.compact,
  });

  final String label;
  final String? value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final display = (value != null && value!.isNotEmpty) ? value! : '—';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: compact ? 11 : 12,
              ),
            ),
            TextSpan(
              text: display,
              style: AppTextStyles.label.copyWith(fontSize: compact ? 12 : 13),
            ),
          ],
        ),
      ),
    );
  }
}
