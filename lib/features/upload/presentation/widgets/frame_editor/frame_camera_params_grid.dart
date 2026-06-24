import 'package:flutter/material.dart';

import '../../../../../core/data/app_catalog.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/domain/cine_params.dart';
import '../editor/editor_param_select_row.dart';

class FrameCameraParamsGrid extends StatelessWidget {
  const FrameCameraParamsGrid({
    super.key,
    required this.params,
    required this.onChanged,
    this.useSelectRows = false,
  });

  final CineParams params;
  final ValueChanged<CineParams> onChanged;
  final bool useSelectRows;

  @override
  Widget build(BuildContext context) {
    if (useSelectRows) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('镜头参数', style: AppTextStyles.label),
          const SizedBox(height: 12),
          EditorParamSelectRow(
            label: '景别',
            value: params.shotType,
            options: AppCatalog.shotTypePresets,
            onChanged: (v) => onChanged(params.copyWith(shotType: v)),
          ),
          const SizedBox(height: 10),
          EditorParamSelectRow(
            label: '机位',
            value: params.cameraAngle,
            options: AppCatalog.cameraAnglePresets,
            onChanged: (v) => onChanged(params.copyWith(cameraAngle: v)),
          ),
          const SizedBox(height: 10),
          EditorParamSelectRow(
            label: '运镜',
            value: params.movement,
            options: AppCatalog.movementPresets,
            onChanged: (v) => onChanged(params.copyWith(movement: v)),
          ),
          const SizedBox(height: 10),
          EditorParamSelectRow(
            label: '焦段',
            value: params.lensMm,
            options: AppCatalog.lensMmPresets,
            onChanged: (v) => onChanged(params.copyWith(lensMm: v)),
          ),
          const SizedBox(height: 10),
          EditorParamSelectRow(
            label: '构图',
            value: params.composition,
            options: AppCatalog.compositionPresets,
            onChanged: (v) => onChanged(params.copyWith(composition: v)),
          ),
          const SizedBox(height: 10),
          EditorDurationSelectRow(
            value: params.durationSec,
            options: AppCatalog.durationSecPresets,
            onChanged: (v) => onChanged(params.copyWith(durationSec: v)),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('镜头参数', style: AppTextStyles.label),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.8,
          children: [
            _ParamDropdown(
              label: '景别',
              value: params.shotType,
              items: AppCatalog.shotTypePresets,
              onChanged: (v) => onChanged(params.copyWith(shotType: v)),
            ),
            _ParamDropdown(
              label: '机位',
              value: params.cameraAngle,
              items: AppCatalog.cameraAnglePresets,
              onChanged: (v) => onChanged(params.copyWith(cameraAngle: v)),
            ),
            _ParamDropdown(
              label: '运镜',
              value: params.movement,
              items: AppCatalog.movementPresets,
              onChanged: (v) => onChanged(params.copyWith(movement: v)),
            ),
            _ParamDropdown(
              label: '焦段',
              value: params.lensMm,
              items: AppCatalog.lensMmPresets,
              onChanged: (v) => onChanged(params.copyWith(lensMm: v)),
            ),
            _ParamDropdown(
              label: '构图',
              value: params.composition,
              items: AppCatalog.compositionPresets,
              onChanged: (v) => onChanged(params.copyWith(composition: v)),
            ),
            _DurationDropdown(
              value: params.durationSec,
              onChanged: (v) => onChanged(params.copyWith(durationSec: v)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ParamDropdown extends StatelessWidget {
  const _ParamDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value != null && value!.isNotEmpty ? value : null,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('未设置')),
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: onChanged,
    );
  }
}

class _DurationDropdown extends StatelessWidget {
  const _DurationDropdown({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: '时长',
        isDense: true,
      ),
      items: [
        for (final sec in AppCatalog.durationSecPresets)
          DropdownMenuItem(value: sec, child: Text('$sec秒')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
