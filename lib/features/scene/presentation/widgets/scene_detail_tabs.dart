import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../character/presentation/widgets/detail/character_scripts_tab.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../data/scene_repository.dart';
import '../../domain/scene_entry.dart';
import '../../domain/scene_utils.dart';
import 'scene_grid_card.dart';

class SceneInspirationTab extends StatelessWidget {
  const SceneInspirationTab({
    super.key,
    required this.entry,
    this.localCover,
    this.referenceUrls = const [],
  });

  final SceneEntry entry;
  final String? localCover;
  final List<String> referenceUrls;

  @override
  Widget build(BuildContext context) {
    final urls = <String>[
      if (localCover != null && localCover!.isNotEmpty) localCover!,
      if (entry.coverUrl.isNotEmpty) entry.coverUrl,
      ...referenceUrls,
      ...entry.imageUrls,
    ];

    if (urls.isEmpty) {
      return Center(
        child: Text('暂无参考图', style: AppTextStyles.bodySecondary),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: urls.length,
      itemBuilder: (context, index) {
        final path = urls[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: path.isNotEmpty
              ? Rc0Image(path: path, fit: BoxFit.cover)
              : const PlaceholderImage(aspectRatio: 3 / 4, borderRadius: 12),
        );
      },
    );
  }
}

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
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
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

class SceneScriptsTab extends StatelessWidget {
  const SceneScriptsTab({super.key, required this.sceneId});

  final String sceneId;

  @override
  Widget build(BuildContext context) {
    final repo = ScreenplayLocalRepository.instance;
    final ids = screenplaysForScene(sceneId);
    final screenplays = ids
        .map((id) => repo.documentById(id)?.toScreenplay())
        .whereType<Screenplay>()
        .toList(growable: false);

    if (screenplays.isEmpty) {
      return Center(
        child: Text('暂无关联剧本', style: AppTextStyles.bodySecondary),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: screenplays.length,
      itemBuilder: (context, index) {
        final screenplay = screenplays[index];
        return CharacterScriptListTile(
          screenplay: screenplay,
          onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
        );
      },
    );
  }
}

class SceneShootingTipsTab extends StatelessWidget {
  const SceneShootingTipsTab({super.key, required this.entry});

  final SceneEntry entry;

  @override
  Widget build(BuildContext context) {
    final tips = entry.shootingTips;
    if (tips.isEmpty) {
      return Center(
        child: Text('暂无拍摄建议', style: AppTextStyles.bodySecondary),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        for (final entry in tips.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(entry.value, style: AppTextStyles.body),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Text(
            '构图示意占位',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      ],
    );
  }
}

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
