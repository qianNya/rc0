import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/domain/screenplay/script_frame.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/screenplay/domain/cine_params.dart';
import 'package:rc0/features/upload/domain/upload_image_file.dart';
import 'package:rc0/features/upload/presentation/widgets/editor/scene_frame_list_view.dart';
import 'package:rc0/features/upload/presentation/widgets/script_editor/script_editor_actions.dart';
import 'package:rc0/features/studio/presentation/studio_editor_shell_bridge.dart';
import 'package:rc0/features/upload/presentation/widgets/editor/editor_quick_action_row.dart';
import 'package:rc0/features/upload/presentation/widgets/script_editor/script_editor_outline_tab.dart';
import 'package:rc0/features/upload/presentation/widgets/script_editor/script_editor_frames_tab.dart';
import 'package:rc0/features/upload/presentation/widgets/script_editor/script_editor_storyboard_tab.dart';
import 'package:rc0/shared/widgets/shell_insets.dart';

const _shellClearance = 88.0;

ScriptFrame _frame(int index) {
  return ScriptFrame(
    id: 'f-$index',
    orderIndex: index,
    imagePath: '',
    caption: index.isEven ? '镜头说明 $index' : '',
  );
}

ScreenplayDraft _draftWithFrames(int count) {
  final draft = ScreenplayDraft();
  draft.acts.add(ActDraft());
  final scene = SceneDraft();
  for (var i = 0; i < count; i++) {
    scene.frames.add(
      FrameDraft(
        image: UploadImageFile(path: '/tmp/f$i.jpg', name: 'f$i.jpg'),
        caption: i.isEven ? '镜头说明 $i' : '',
        actionNote: i.isEven ? '动作说明 $i' : '',
        cineParams: CineParams(durationSec: 3 + i),
      ),
    );
  }
  draft.acts.first.scenes.add(scene);
  return draft;
}

ScriptEditorActions _noopActions(ScreenplayDraft draft) {
  return ScriptEditorActions(
    draft: draft,
    onChanged: () {},
    poolTags: const [],
    onPickFrames: (_) {},
    onRemoveFrame: (_, _, _) async {},
    onCaptionChanged: (_, _, _, _) {},
    onActionNoteChanged: (_, _, _, _) {},
    onCineParamsChanged: (_, _, _, _) {},
    onPositivePromptChanged: (_, _, _, _) {},
    onNegativePromptChanged: (_, _, _, _) {},
    onSceneOverrideChanged: (_, _, _) {},
    onFrameOverrideChanged: (_, _, _, _) {},
    onToggleSceneTag: (_, _, _) {},
    onToggleFrameTag: (_, _, _, _) {},
    onMoveFrame: (_, _, _, _) {},
    onMoveScene: (_, _, _) {},
    canRemoveScene: (_, _) => true,
    onRemoveScene: (_, _) async {},
  );
}

Widget _hubOutlineTab(ScreenplayDraft draft) {
  return ScriptEditorOutlineTab(
    draft: draft,
    actions: _noopActions(draft),
    onAddAct: () {},
    onAddScene: (_) {},
    onRemoveAct: (_) async {},
    canRemoveAct: (_) => true,
    onReorderActs: (_, _) {},
    onMoveScene: (_, _, _) {},
    structureEditor: const SizedBox.shrink(),
    hubLayout: true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(StudioEditorShellBridge.instance.clear);

  Future<void> pumpStoryboard(
    WidgetTester tester, {
    required double width,
    required Widget child,
    bool withShellInsets = false,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final body = SizedBox(
      width: width,
      height: 700,
      child: child,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: withShellInsets
            ? ShellInsets(
                bottomClearance: _shellClearance,
                child: Scaffold(body: body),
              )
            : Scaffold(body: body),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> expectNoOverflow(
    WidgetTester tester, {
    required double width,
    required Widget child,
    bool withShellInsets = false,
  }) async {
    await pumpStoryboard(
      tester,
      width: width,
      child: child,
      withShellInsets: withShellInsets,
    );
    expect(tester.takeException(), isNull);
  }

  group('EditorStoryboardPanel', () {
    testWidgets('does not overflow at 320px with bottom bar', (tester) async {
      final frames = List.generate(6, _frame);
      final draft = _draftWithFrames(6);
      await expectNoOverflow(
        tester,
        width: 320,
        child: EditorStoryboardPanel(
          title: '全部场次（6画）',
          frames: frames,
          galleryPaths: List.filled(frames.length, ''),
          galleryCaptions: frames.map((f) => f.caption).toList(),
          shotLabels: List.generate(frames.length, (i) => '1-1-${i + 1}'),
          frameSources: draft.acts.first.scenes.first.frames,
          onBatchEdit: () {},
          onAddFrame: () {},
          showBottomBar: true,
        ),
      );
    });

    testWidgets('shows frame footer below thumbnail', (tester) async {
      final draft = _draftWithFrames(2);
      final frames = List.generate(2, _frame);
      final frameSources = draft.acts.first.scenes.first.frames;
      await pumpStoryboard(
        tester,
        width: 390,
        child: Column(
          children: [
            Expanded(
              child: EditorStoryboardPanel(
                title: '第1场（2画）',
                frames: frames,
                galleryPaths: List.filled(frames.length, ''),
                galleryCaptions: frames.map((f) => f.caption).toList(),
                shotLabels: const ['1-1-1', '1-1-2'],
                frameSources: frameSources,
              ),
            ),
          ],
        ),
      );

      expect(find.textContaining('1-1-1'), findsWidgets);
      expect(find.textContaining('镜头说明 0'), findsOneWidget);
      expect(find.textContaining('未命名画面'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final width in [390.0, 600.0]) {
      testWidgets('does not overflow at ${width.toInt()}px with shell insets',
          (tester) async {
        final frames = List.generate(8, _frame);
        final draft = _draftWithFrames(8);
        final frameSources = draft.acts.first.scenes.first.frames;
        await expectNoOverflow(
          tester,
          width: width,
          withShellInsets: true,
          child: EditorStoryboardPanel(
            title: '全部场次（8画）',
            frames: frames,
            galleryPaths: List.filled(frames.length, ''),
            galleryCaptions: frames.map((f) => f.caption).toList(),
            shotLabels: List.generate(frames.length, (i) => '1-1-${i + 1}'),
            frameSources: frameSources,
            shellBottomPadding: _shellClearance,
          ),
        );
      });
    }
  });

  group('ScriptEditorStoryboardTab hub layout', () {
    for (final width in [320.0, 390.0, 600.0]) {
      testWidgets('does not overflow at ${width.toInt()}px', (tester) async {
        final draft = _draftWithFrames(8);
        await expectNoOverflow(
          tester,
          width: width,
          withShellInsets: true,
          child: Column(
            children: [
              Expanded(
                child: ScriptEditorStoryboardTab(
                  draft: draft,
                  actions: _noopActions(draft),
                  embeddedInHub: true,
                ),
              ),
            ],
          ),
        );
      });
    }
  });

  group('ScriptEditorFramesTab hub layout', () {
    for (final width in [320.0, 390.0, 600.0]) {
      testWidgets('does not overflow at ${width.toInt()}px', (tester) async {
        final draft = _draftWithFrames(8);
        await expectNoOverflow(
          tester,
          width: width,
          withShellInsets: true,
          child: Column(
            children: [
              Expanded(
                child: ScriptEditorFramesTab(
                  draft: draft,
                  actions: _noopActions(draft),
                  embeddedInHub: true,
                ),
              ),
            ],
          ),
        );
      });
    }
  });

  group('ScriptEditorOutlineTab hub frames mode', () {
    for (final width in [390.0, 600.0]) {
      testWidgets('does not overflow at ${width.toInt()}px', (tester) async {
        final draft = _draftWithFrames(8);
        await pumpStoryboard(
          tester,
          width: width,
          withShellInsets: true,
          child: _hubOutlineTab(draft),
        );
        StudioEditorShellBridge.instance.setHubMode(EditorHubMode.frames);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
