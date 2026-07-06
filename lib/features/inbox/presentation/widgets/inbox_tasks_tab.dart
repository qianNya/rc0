import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/glass/glass.dart';

class InboxTasksTab extends StatelessWidget {
  const InboxTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXl),
        child: GlassEmptyState(
          icon: Icons.task_alt_outlined,
          title: '任务中心',
          subtitle: '生成任务、同步与审核状态将显示在这里',
        ),
      ),
    );
  }
}
