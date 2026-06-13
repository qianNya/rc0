import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import 'rc0_widgets.dart';

class TagEditor extends StatelessWidget {
  const TagEditor({
    super.key,
    required this.suggestedTags,
    required this.selectedTags,
    required this.onToggle,
    required this.onAdd,
  });

  final List<String> suggestedTags;
  final Set<String> selectedTags;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAdd;

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '输入标签名称'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    if (tag != null && tag.isNotEmpty) {
      onAdd(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTags = {
      ...suggestedTags,
      ...selectedTags,
    }.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('标签', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in allTags)
              TagChip(
                label: tag,
                selected: selectedTags.contains(tag),
                onTap: () => onToggle(tag),
              ),
            ActionChip(
              label: const Text('+ 添加'),
              onPressed: () => _showAddDialog(context),
            ),
          ],
        ),
      ],
    );
  }
}
