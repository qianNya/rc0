import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/lighting_scheme.dart';

class LightingPresetSection extends StatelessWidget {
  const LightingPresetSection({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    required this.schemes,
    required this.selectedId,
    required this.onSchemeSelected,
    this.horizontal = false,
  });

  final LightingPresetCategory category;
  final ValueChanged<LightingPresetCategory> onCategoryChanged;
  final List<LightingScheme> schemes;
  final String selectedId;
  final ValueChanged<LightingScheme> onSchemeSelected;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final cat in LightingPresetCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.label),
                    selected: category == cat,
                    onSelected: (_) => onCategoryChanged(cat),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        if (horizontal)
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: schemes.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (context, index) {
                final scheme = schemes[index];
                return SizedBox(
                  width: 160,
                  child: _PresetCard(
                    scheme: scheme,
                    selected: scheme.id == selectedId,
                    onTap: () => onSchemeSelected(scheme),
                  ),
                );
              },
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppDimensions.spacingSm,
              crossAxisSpacing: AppDimensions.spacingSm,
              childAspectRatio: 1.35,
            ),
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];
              return _PresetCard(
                scheme: scheme,
                selected: scheme.id == selectedId,
                onTap: () => onSchemeSelected(scheme),
              );
            },
          ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.scheme,
    required this.selected,
    required this.onTap,
  });

  final LightingScheme scheme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.dividerColor.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ],
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheme.category.label,
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              Text(
                scheme.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
