import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/glass/glass_sheet.dart';

class EditorParamSelectRow extends StatelessWidget {
  const EditorParamSelectRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.displayValue,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String? value)? displayValue;

  String get _displayText {
    if (displayValue != null) return displayValue!(value);
    if (value == null || value!.isEmpty) return '未设置';
    return value!;
  }

  static const _unsetMarker = '__unset__';

  Future<void> _showPicker(BuildContext context) async {
    final picked = await showGlassSheet<String>(
      context,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: Text(label, style: AppTextStyles.title),
            ),
            ListTile(
              title: const Text('未设置'),
              trailing: value == null || value!.isEmpty
                  ? const Icon(Icons.check, color: AppColors.accent)
                  : null,
              onTap: () => Navigator.pop(context, _unsetMarker),
            ),
            for (final option in options)
              ListTile(
                title: Text(option),
                trailing: value == option
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
    );
    if (!context.mounted || picked == null) return;
    onChanged(picked == _unsetMarker ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: () => _showPicker(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextStyles.bodySecondary),
              ),
              Text(_displayText, style: AppTextStyles.label),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditorDurationSelectRow extends StatelessWidget {
  const EditorDurationSelectRow({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return EditorParamSelectRow(
      label: '时长',
      value: '$value',
      options: options.map((e) => '$e').toList(),
      displayValue: (v) => v == null ? '未设置' : '$v秒',
      onChanged: (picked) {
        if (picked != null) onChanged(int.parse(picked));
      },
    );
  }
}
