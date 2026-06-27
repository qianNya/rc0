import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rc0/features/scene/data/scene_seed_catalog.dart';
import 'package:rc0/features/screenplay/data/screenplay_api_mapper.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/screenplay/data/screenplay_scene_binding.dart';
import 'package:rc0/features/screenplay/data/shoot_params_draft.dart';
import 'package:rc0/features/screenplay/data/screenplay_tree_document.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('applyLibrarySceneToSceneDraft fills empty fields', () {
    final entry = SceneSeedCatalog.seeds.first;
    final draft = ScreenplayDraft();
    final scene = SceneDraft();

    applyLibrarySceneToSceneDraft(entry, scene, draft);

    expect(scene.sceneLibraryId, entry.id);
    expect(scene.sceneLibraryTitle, entry.title);
    expect(scene.location, isNotEmpty);
    expect(draft.linkedScenes.any((l) => l.id == entry.id), isTrue);
  });

  test('linked_scenes and scene_library_id roundtrip in tree JSON', () {
    final draft = ScreenplayDraft(
      linkedScenes: [
        const ScreenplaySceneLink(id: 'seed-coast-rocks', title: '海边礁石'),
      ],
      acts: [
        ActDraft(
          scenes: [
            SceneDraft(
              sceneLibraryId: 'seed-coast-rocks',
              sceneLibraryTitle: '海边礁石',
              location: '海岸',
            ),
          ],
        ),
      ],
    );

    final tree = <String, dynamic>{
      'screenplay': <String, dynamic>{
        'title': '测试',
        'shoot_defaults': draft.defaultParams.toJson(),
      },
      'acts': [
        {
          'act': <String, dynamic>{'title': '第一幕'},
          'scenes': [
            {
              'scene': <String, dynamic>{
                'title': '第一场',
                'weather': '',
              },
              'frames': <Map<String, dynamic>>[],
            },
          ],
        },
      ],
    };

    final written =
        ScreenplayApiMapper.applyDraftShootParamsToTree(tree, draft);
    final roundtrip = screenplayDraftFromTreeDocument(
      ScreenplayTreeDocument(
        meta: const ScreenplayLocalMeta(localId: 'local-1'),
        tree: written,
      ),
    );

    expect(roundtrip.linkedScenes, hasLength(1));
    expect(roundtrip.linkedScenes.first.id, 'seed-coast-rocks');
    expect(
      roundtrip.acts.first.scenes.first.sceneLibraryId,
      'seed-coast-rocks',
    );
    expect(
      roundtrip.acts.first.scenes.first.sceneLibraryTitle,
      '海边礁石',
    );
  });
}
