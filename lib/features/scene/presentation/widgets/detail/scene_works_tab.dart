import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';

class SceneWorksTab extends StatelessWidget {
  const SceneWorksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '暂无使用作品',
        style: AppTextStyles.bodySecondary,
      ),
    );
  }
}
