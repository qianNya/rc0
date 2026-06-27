import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../pages/ai_creation_hub_page.dart';
import '../../pages/project_settings_page.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/domain/shoot_params.dart';
import 'script_editor_actions.dart';
import '../../pages/scene_editor_detail_page.dart';
import '../../pages/frame_editor_detail_page.dart';

Future<void> openSceneEditorDetail(
  BuildContext context, {
  required ScriptEditorActions actions,
  required int actIndex,
  required int sceneIndex,
  int initialTabIndex = 0,
  int? initialFrameIndex,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => SceneEditorDetailPage(
        actions: actions,
        actIndex: actIndex,
        sceneIndex: sceneIndex,
        initialTabIndex: initialTabIndex,
        initialFrameIndex: initialFrameIndex,
      ),
    ),
  );
}

Future<void> openFrameEditorDetail(
  BuildContext context, {
  required ScriptEditorActions actions,
  required int actIndex,
  required int sceneIndex,
  required int frameIndex,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => FrameEditorDetailPage(
        actions: actions,
        actIndex: actIndex,
        sceneIndex: sceneIndex,
        frameIndex: frameIndex,
      ),
    ),
  );
}

Future<void> openProjectSettings(
  BuildContext context, {
  required ScreenplayDraft draft,
  required TextEditingController titleController,
  required TextEditingController synopsisController,
  required ValueChanged<ShootParams> onShootParamsChanged,
  required List<String> poolTags,
  required ValueChanged<String> onToggleScreenplayTag,
  required Future<void> Function(String) onAddScreenplayTag,
  bool tagsLoading = false,
  String? tagsError,
  VoidCallback? onRetryTags,
  VoidCallback? onPickCover,
  VoidCallback? onResetCover,
  VoidCallback? onSyncTitle,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => ProjectSettingsPage(
        draft: draft,
        titleController: titleController,
        synopsisController: synopsisController,
        onShootParamsChanged: onShootParamsChanged,
        poolTags: poolTags,
        onToggleScreenplayTag: onToggleScreenplayTag,
        onAddScreenplayTag: onAddScreenplayTag,
        tagsLoading: tagsLoading,
        tagsError: tagsError,
        onRetryTags: onRetryTags,
        onPickCover: onPickCover,
        onResetCover: onResetCover,
        onSyncTitle: onSyncTitle,
      ),
    ),
  );
}

void openAiCreationHub(BuildContext context, {String? editScriptId}) {
  if (editScriptId != null && editScriptId.isNotEmpty) {
    context.push(AppRoutes.createAiHub(editScriptId));
  } else {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(builder: (_) => const AiCreationHubPage()),
    );
  }
}
