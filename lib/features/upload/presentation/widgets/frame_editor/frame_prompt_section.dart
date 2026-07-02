import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';

class FramePromptSection extends StatelessWidget {
  const FramePromptSection({
    super.key,
    required this.positivePrompt,
    required this.negativePrompt,
    required this.onPositiveChanged,
    required this.onNegativeChanged,
  });

  final String positivePrompt;
  final String negativePrompt;
  final ValueChanged<String> onPositiveChanged;
  final ValueChanged<String> onNegativeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI 渲染提示词', style: AppTextStyles.label),
        const SizedBox(height: 4),
        Text(
          '设备与打光请使用「摄影预设」；此处仅用于 AI 生图 Prompt。',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: positivePrompt,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '正向提示词',
            hintText: '描述希望生成的画面内容…',
            alignLabelWithHint: true,
          ),
          onChanged: onPositiveChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: negativePrompt,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '反向提示词',
            hintText: '描述需要排除的元素…',
            alignLabelWithHint: true,
          ),
          onChanged: onNegativeChanged,
        ),
      ],
    );
  }
}
