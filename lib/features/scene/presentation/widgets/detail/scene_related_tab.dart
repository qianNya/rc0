import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../data/scene_repository.dart';
import '../scene_grid_card.dart';

class SceneRelatedTab extends StatelessWidget {
  const SceneRelatedTab({super.key, required this.sceneId});

  final String sceneId;

  @override
  Widget build(BuildContext context) {
    final related = SceneRepository.instance.relatedScenes(sceneId);
    if (related.isEmpty) {
      return Center(
        child: Text('暂无相关场景', style: AppTextStyles.bodySecondary),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in related)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SceneGridCard(
              entry: entry,
              onTap: () => context.push(AppRoutes.sceneDetailPath(entry.id)),
            ),
          ),
      ],
    );
  }
}
