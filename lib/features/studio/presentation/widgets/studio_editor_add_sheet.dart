import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';

void showStudioEditorAddSheet(
  BuildContext context, {
  required VoidCallback onAddAct,
  required VoidCallback onAddScene,
}) {
  showGlassSheet<void>(
    context,
    useRootNavigator: true,
    padding: kGlassSheetMenuPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '添加结构',
            style: AppTextStyles.label.copyWith(fontSize: 13),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.add_box_outlined),
          title: const Text('添加幕'),
          subtitle: const Text('在剧本末尾新增一幕'),
          onTap: () {
            Navigator.pop(context);
            onAddAct();
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_location_alt_outlined),
          title: const Text('添加场'),
          subtitle: const Text('在最后一幕中新增一场'),
          onTap: () {
            Navigator.pop(context);
            onAddScene();
          },
        ),
      ],
    ),
  );
}
