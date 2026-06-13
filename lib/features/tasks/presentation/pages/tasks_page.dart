import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.task_alt_outlined,
                  size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              const Text('任务中心', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                '桌面端专属功能，移动端可从「我的」访问相关入口',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
