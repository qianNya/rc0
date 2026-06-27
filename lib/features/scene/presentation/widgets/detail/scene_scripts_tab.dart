import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/domain/screenplay/screenplay.dart';
import '../../../../character/presentation/widgets/detail/character_scripts_tab.dart';
import '../../../../screenplay/data/screenplay_local_repository.dart';
import '../../../domain/scene_utils.dart';

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
      padding: const EdgeInsets.all(16),
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
