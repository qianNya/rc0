import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../domain/light_source.dart';
import '../../domain/lighting_scheme.dart';

class LightingLightListPanel extends StatelessWidget {
  const LightingLightListPanel({
    super.key,
    required this.scheme,
    required this.selectedIndex,
    required this.onSelected,
    required this.onToggleEnabled,
  });

  final LightingScheme scheme;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('灯光列表', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            scheme.title,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          for (var i = 0; i < scheme.lights.length; i++) ...[
            _LightRow(
              light: scheme.lights[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
              onToggle: () => onToggleEnabled(i),
            ),
            if (i < scheme.lights.length - 1)
              const SizedBox(height: AppDimensions.spacingXs),
          ],
        ],
      ),
    );
  }
}

class _LightRow extends StatelessWidget {
  const _LightRow({
    required this.light,
    required this.selected,
    required this.onTap,
    required this.onToggle,
  });

  final LightSource light;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      light.role.label,
                      style: AppTextStyles.body.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    Text(
                      '${light.intensity}% · ${light.colorTempK}K',
                      style: AppTextStyles.bodySecondary
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onToggle,
                icon: Icon(
                  light.enabled
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
