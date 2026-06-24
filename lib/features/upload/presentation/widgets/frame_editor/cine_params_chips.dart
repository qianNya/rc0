import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/domain/cine_params.dart';

class CineParamsChips extends StatelessWidget {
  const CineParamsChips({
    super.key,
    required this.params,
    this.compact = false,
    this.showDuration = true,
  });

  final CineParams params;
  final bool compact;
  final bool showDuration;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String? value})>[
      (icon: Icons.photo_size_select_small_outlined, value: params.shotType),
      (icon: Icons.videocam_outlined, value: params.cameraAngle),
      (icon: Icons.swap_horiz, value: params.movement),
      (icon: Icons.camera_outlined, value: params.lensMm),
    ];

    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 4 : 6,
      children: [
        if (showDuration)
          _Chip(
            icon: Icons.timer_outlined,
            label: '${params.durationSec}秒',
            compact: compact,
          ),
        for (final item in items)
          if (item.value != null && item.value!.isNotEmpty)
            _Chip(icon: item.icon, label: item.value!, compact: compact),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
