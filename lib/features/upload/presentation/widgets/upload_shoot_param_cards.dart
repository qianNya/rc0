import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/preset_catalog.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../../../screenplay/presentation/widgets/screenplay_shoot_params_chips.dart';
import '../utils/shoot_preset_navigation.dart';

typedef ShootParamsChanged = void Function(ShootParams params);

/// Selectable preset cards for device / aspect ratio / lighting.
class ShootParamPresetCards extends StatelessWidget {
  const ShootParamPresetCards({
    super.key,
    required this.params,
    required this.onChanged,
    this.inheritedHint,
    this.compact = false,
    this.readOnly = false,
  });

  final ShootParams params;
  final ShootParamsChanged onChanged;
  final String? inheritedHint;
  final bool compact;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final inherited = inheritedHint != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inheritedHint != null) ...[
          Text(inheritedHint!, style: AppTextStyles.bodySecondary.copyWith(fontSize: 12)),
          const SizedBox(height: 8),
        ],
        _ParamRow(
          label: '设备',
          options: PresetCatalog.devicePresets,
          selected: params.device,
          compact: compact,
          inherited: inherited,
          readOnly: readOnly,
          onSelected: (value) => onChanged(params.copyWith(device: value)),
        ),
        SizedBox(height: compact ? 10 : 14),
        _ParamRow(
          label: '画幅',
          options: PresetCatalog.aspectRatioPresets,
          selected: params.aspectRatio,
          compact: compact,
          inherited: inherited,
          readOnly: readOnly,
          onSelected: (value) => onChanged(params.copyWith(aspectRatio: value)),
        ),
        SizedBox(height: compact ? 10 : 14),
        _ParamRow(
          label: '打光',
          options: PresetCatalog.lightingPresets,
          selected: params.lighting,
          compact: compact,
          inherited: inherited,
          readOnly: readOnly,
          onSelected: (value) => onChanged(params.copyWith(lighting: value)),
        ),
      ],
    );
  }
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    required this.compact,
    required this.inherited,
    required this.readOnly,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;
  final bool compact;
  final bool inherited;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: compact ? 12 : 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            final borderColor = isSelected
                ? AppColors.accent
                : (inherited ? AppColors.border : AppColors.border);
            final bgColor = isSelected
                ? AppColors.accent.withValues(alpha: 0.08)
                : (inherited && !isSelected
                    ? AppColors.surface
                    : AppColors.surface);
            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: InkWell(
                onTap: readOnly ? null : () => onSelected(option),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 12,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : borderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: AppTextStyles.label.copyWith(
                      fontSize: compact ? 12 : 13,
                      color: isSelected
                          ? AppColors.accent
                          : (inherited
                              ? AppColors.textSecondary
                              : AppColors.textPrimary),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Collapsible shoot-param override block for scene / frame editors.
class ShootParamOverrideSection extends StatelessWidget {
  const ShootParamOverrideSection({
    super.key,
    required this.effectiveParams,
    required this.paramOverride,
    required this.inheritLabel,
    required this.onOverrideChanged,
    this.scope = 'scene',
    this.actIndex,
    this.sceneIndex,
    this.frameIndex,
  });

  final ShootParams effectiveParams;
  final ShootParams? paramOverride;
  final String inheritLabel;
  final ValueChanged<ShootParams?> onOverrideChanged;
  final String scope;
  final int? actIndex;
  final int? sceneIndex;
  final int? frameIndex;

  bool get _hasOverride =>
      paramOverride != null && paramOverride!.hasAnyValue;

  Future<void> _openPicker(BuildContext context) async {
    final params = await openShootPresetPicker(
      context,
      scope: scope,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    );
    if (params == null) return;
    onOverrideChanged(params);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('参数', style: AppTextStyles.label),
            const Spacer(),
            if (_hasOverride)
              TextButton(
                onPressed: () => onOverrideChanged(null),
                child: const Text('恢复默认'),
              ),
            TextButton(
              onPressed: () => _openPicker(context),
              child: Text(_hasOverride ? '更换' : '选择预设'),
            ),
          ],
        ),
        ScreenplayShootParamsChips(
          params: effectiveParams,
          inheritedHint: _hasOverride ? null : inheritLabel,
          compact: true,
          onTap: () => _openPicker(context),
        ),
      ],
    );
  }
}
