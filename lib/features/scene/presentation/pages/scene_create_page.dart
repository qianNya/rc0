import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../widgets/scene_create_sheet.dart';

/// Full-screen fallback for deep links to [/scenes/create].
class SceneCreatePage extends StatelessWidget {
  const SceneCreatePage({
    super.key,
    this.initialDescription,
    this.initialCoverPath,
  });

  final String? initialDescription;
  final String? initialCoverPath;

  @override
  Widget build(BuildContext context) {
    return DesktopStackScaffold(
      title: const Text('创建场景'),
      onBack: () => popOrGoDiscovery(context),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          SceneCreateFormPanel(
            initialDescription: initialDescription,
            initialCoverPath: initialCoverPath,
            onSaved: (id) => context.pop(id),
          ),
        ],
      ),
    );
  }
}
