import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../../shared/widgets/rc0_app_bar.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../screenplay/domain/shoot_params.dart';
import 'script_editor_actions.dart';
import 'script_editor_shot_list_tab.dart';
import 'script_editor_timeline_tab.dart';

Future<void> openSceneEditorDetail(
  BuildContext context, {
  required ScriptEditorActions actions,
  required int actIndex,
  required int sceneIndex,
  int initialTabIndex = 0,
  int? initialFrameIndex,
}) {
  const scriptId = 'draft';
  return context.push(
    AppRoutes.studioEditScenePath(scriptId, '$sceneIndex'),
    extra: <String, dynamic>{
      'actions': actions,
      'actIndex': actIndex,
      'sceneIndex': sceneIndex,
      'initialTabIndex': initialTabIndex,
      'initialFrameIndex': initialFrameIndex,
    },
  );
}

Future<void> openFrameEditorDetail(
  BuildContext context, {
  required ScriptEditorActions actions,
  required int actIndex,
  required int sceneIndex,
  required int frameIndex,
}) {
  const scriptId = 'draft';
  return context.push(
    AppRoutes.studioEditFramePath(scriptId, '$sceneIndex', '$frameIndex'),
    extra: <String, dynamic>{
      'actions': actions,
      'actIndex': actIndex,
      'sceneIndex': sceneIndex,
      'frameIndex': frameIndex,
    },
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
  return context.push(
    AppRoutes.studioSettings('draft'),
    extra: <String, dynamic>{
      'draft': draft,
      'titleController': titleController,
      'synopsisController': synopsisController,
      'onShootParamsChanged': onShootParamsChanged,
      'poolTags': poolTags,
      'onToggleScreenplayTag': onToggleScreenplayTag,
      'onAddScreenplayTag': onAddScreenplayTag,
      'tagsLoading': tagsLoading,
      'tagsError': tagsError,
      'onRetryTags': onRetryTags,
      'onPickCover': onPickCover,
      'onResetCover': onResetCover,
      'onSyncTitle': onSyncTitle,
    },
  );
}

Future<void> openSceneTimeline(
  BuildContext context, {
  required ScreenplayDraft draft,
  required ScriptEditorActions actions,
  required String sceneTitle,
  int? filterActIndex,
  int? filterSceneIndex,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (ctx) => DesktopStackScaffold(
        title: Text('$sceneTitle · 时间线'),
        onBack: () => Navigator.of(ctx).pop(),
        body: ScriptEditorTimelineTab(
          draft: draft,
          actions: actions,
          filterActIndex: filterActIndex,
          filterSceneIndex: filterSceneIndex,
        ),
      ),
    ),
  );
}

Future<void> openShotList(
  BuildContext context, {
  required ScreenplayDraft draft,
  required ScriptEditorActions actions,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: Rc0AppBar(title: const Text('分镜列表')),
        body: ScriptEditorShotListTab(
          draft: draft,
          actions: actions,
        ),
      ),
    ),
  );
}

void openAiCreationHub(BuildContext context, {String? editScriptId}) {
  if (editScriptId != null && editScriptId.isNotEmpty) {
    context.push(AppRoutes.createAiHub(editScriptId));
  } else {
    context.push(AppRoutes.createAiHubPath);
  }
}
