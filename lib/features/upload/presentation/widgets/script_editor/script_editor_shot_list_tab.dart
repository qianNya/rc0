import 'package:flutter/material.dart';

import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../frame_editor/shot_list_card.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';

class ScriptEditorShotListTab extends StatelessWidget {
  const ScriptEditorShotListTab({
    super.key,
    required this.draft,
    required this.actions,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;

  @override
  Widget build(BuildContext context) {
    final refs = draftAllFrameRefs(draft);

    if (refs.isEmpty) {
      return Center(
        child: Text(
          '暂无分镜画面，请在大纲中添加场次并上传画面',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: refs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ref = refs[index];
        return ShotListCard(
          shotLabel: ref.shotLabel,
          frame: ref.frame,
          cineParams: ref.frame.cineParams,
          subtitle: '${ref.actTitle} · ${ref.sceneTitle}',
          onTap: () => openFrameEditorDetail(
            context,
            actions: actions,
            actIndex: ref.actIndex,
            sceneIndex: ref.sceneIndex,
            frameIndex: ref.frameIndex,
          ),
        );
      },
    );
  }
}
