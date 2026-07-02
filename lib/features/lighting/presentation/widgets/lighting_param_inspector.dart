import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../domain/light_source.dart';

class LightingParamInspector extends StatelessWidget {
  const LightingParamInspector({
    super.key,
    required this.light,
    required this.onChanged,
  });

  final LightSource light;
  final ValueChanged<LightSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('灯光参数', style: AppTextStyles.label),
          Text(
            light.role.label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          DropdownButtonFormField<LightType>(
            value: light.type,
            decoration: const InputDecoration(labelText: '类型'),
            items: [
              for (final t in LightType.values)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) {
              if (v != null) onChanged(light.copyWith(type: v));
            },
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          _SliderRow(
            label: '强度',
            value: light.intensity.toDouble(),
            min: 0,
            max: 100,
            suffix: '${light.intensity}%',
            onChanged: (v) => onChanged(light.copyWith(intensity: v.round())),
          ),
          _SliderRow(
            label: '色温',
            value: light.colorTempK.toDouble(),
            min: 2700,
            max: 10000,
            suffix: '${light.colorTempK}K',
            onChanged: (v) => onChanged(light.copyWith(colorTempK: v.round())),
          ),
          _SliderRow(
            label: '角度',
            value: light.azimuthDeg,
            min: -180,
            max: 180,
            suffix: '${light.azimuthDeg.round()}°',
            onChanged: (v) => onChanged(light.copyWith(azimuthDeg: v)),
          ),
          _SliderRow(
            label: '高度',
            value: light.elevationDeg,
            min: -30,
            max: 90,
            suffix: '${light.elevationDeg.round()}°',
            onChanged: (v) => onChanged(light.copyWith(elevationDeg: v)),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text('光质', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 6),
          SegmentedButton<LightQuality>(
            segments: [
              for (final q in LightQuality.values)
                ButtonSegment(value: q, label: Text(q.label)),
            ],
            selected: {light.quality},
            onSelectionChanged: (set) {
              if (set.isNotEmpty) onChanged(light.copyWith(quality: set.first));
            },
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String suffix;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(label, style: AppTextStyles.bodySecondary),
              const Spacer(),
              Text(suffix, style: AppTextStyles.caption),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
