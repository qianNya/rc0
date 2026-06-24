import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';

class EditorInfoField {
  const EditorInfoField({required this.label, required this.value});

  final String label;
  final String value;
}

class EditorReadOnlyInfoCard extends StatelessWidget {
  const EditorReadOnlyInfoCard({
    super.key,
    required this.title,
    required this.fields,
  });

  final String title;
  final List<EditorInfoField> fields;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: 12),
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0)
              const Divider(height: 20, color: AppColors.border),
            Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    fields[i].label,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    fields[i].value,
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
