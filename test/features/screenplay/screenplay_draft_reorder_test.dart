import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/upload/domain/upload_image_file.dart';

UploadImageFile _image(String name) =>
    UploadImageFile(path: '/tmp/$name', name: name);

void main() {
  group('reorderDraftList', () {
    test('moves item forward', () {
      final list = ['a', 'b', 'c'];
      reorderDraftList(list, 0, 1);
      expect(list, ['b', 'a', 'c']);
    });

    test('moves item backward', () {
      final list = ['a', 'b', 'c'];
      reorderDraftList(list, 2, 0);
      expect(list, ['c', 'a', 'b']);
    });

    test('no-op when oldIndex equals newIndex', () {
      final list = ['a', 'b', 'c'];
      reorderDraftList(list, 1, 1);
      expect(list, ['a', 'b', 'c']);
    });
  });

  group('reorderDraftActs', () {
    test('reorders acts', () {
      final draft = ScreenplayDraft(
        acts: [
          ActDraft(title: 'act-0'),
          ActDraft(title: 'act-1'),
        ],
      );
      reorderDraftActs(draft, 1, 0);
      expect(draft.acts.map((a) => a.title).toList(), ['act-1', 'act-0']);
    });
  });

  group('reorderDraftScenes', () {
    test('reorders scenes within act', () {
      final draft = ScreenplayDraft(
        acts: [
          ActDraft(
            scenes: [
              SceneDraft(title: 'scene-0'),
              SceneDraft(title: 'scene-1'),
            ],
          ),
        ],
      );
      reorderDraftScenes(draft, 0, 0, 1);
      expect(
        draft.acts[0].scenes.map((s) => s.title).toList(),
        ['scene-1', 'scene-0'],
      );
    });
  });

  group('moveDraftScene', () {
    test('moves scene to another act', () {
      final draft = ScreenplayDraft(
        acts: [
          ActDraft(
            scenes: [
              SceneDraft(title: 'scene-a'),
              SceneDraft(title: 'scene-b'),
            ],
          ),
          ActDraft(
            scenes: [SceneDraft(title: 'scene-c')],
          ),
        ],
      );
      final moving = draft.acts[0].scenes[0];
      moveDraftScene(
        draft,
        scene: moving,
        fromActIndex: 0,
        toActIndex: 1,
        toInsertIndex: 1,
      );
      expect(
        draft.acts[0].scenes.map((s) => s.title).toList(),
        ['scene-b'],
      );
      expect(
        draft.acts[1].scenes.map((s) => s.title).toList(),
        ['scene-c', 'scene-a'],
      );
    });

    test('reorders scenes within act via move', () {
      final draft = ScreenplayDraft(
        acts: [
          ActDraft(
            scenes: [
              SceneDraft(title: 'scene-0'),
              SceneDraft(title: 'scene-1'),
            ],
          ),
        ],
      );
      moveDraftScene(
        draft,
        scene: draft.acts[0].scenes[0],
        fromActIndex: 0,
        toActIndex: 0,
        toInsertIndex: 2,
      );
      expect(
        draft.acts[0].scenes.map((s) => s.title).toList(),
        ['scene-1', 'scene-0'],
      );
    });
  });

  group('moveDraftFrame', () {
    test('moves frame to another scene', () {
      final draft = ScreenplayDraft(
        acts: [
          ActDraft(
            scenes: [
              SceneDraft(
                title: 'scene-a',
                frames: [
                  FrameDraft(image: _image('a.jpg'), caption: 'a'),
                  FrameDraft(image: _image('b.jpg'), caption: 'b'),
                ],
              ),
              SceneDraft(
                title: 'scene-b',
                frames: [
                  FrameDraft(image: _image('c.jpg'), caption: 'c'),
                ],
              ),
            ],
          ),
        ],
      );
      final fromScene = draft.acts[0].scenes[0];
      final frame = fromScene.frames[0];
      moveDraftFrame(
        draft,
        frame: frame,
        fromActIndex: 0,
        fromScene: fromScene,
        toActIndex: 0,
        toScene: draft.acts[0].scenes[1],
        toInsertIndex: 1,
      );
      expect(
        draft.acts[0].scenes[0].frames.map((f) => f.caption).toList(),
        ['b'],
      );
      expect(
        draft.acts[0].scenes[1].frames.map((f) => f.caption).toList(),
        ['c', 'a'],
      );
    });
  });
}
