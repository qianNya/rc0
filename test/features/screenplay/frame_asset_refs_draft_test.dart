import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/screenplay/data/frame_asset_refs_draft.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/upload/domain/upload_image_file.dart';

Map<String, dynamic> _treeWithFrame(Map<String, dynamic> frameMap) {
  return {
    'screenplay': {'title': 'Test'},
    'acts': [
      {
        'act': {'title': 'Act 1'},
        'scenes': [
          {
            'scene': {'title': 'Scene 1'},
            'frames': [frameMap],
          },
        ],
      },
    ],
  };
}

ScreenplayDraft _draftWithFrame() {
  final draft = ScreenplayDraft();
  draft.acts.first.scenes.first.frames.add(
    FrameDraft(
      image: UploadImageFile(path: '/main.png', name: 'main.png'),
    ),
  );
  return draft;
}

void main() {
  group('applyDraftReferenceImagesToTree', () {
    test('writes reference_local_paths from draft', () {
      final draft = _draftWithFrame();
      final frame = draft.acts.first.scenes.first.frames.first;
      final ref = UploadImageFile(path: '/tmp/ref-a.png', name: 'ref-a.png');
      frame.referenceImages.add(ref);

      final tree = applyDraftReferenceImagesToTree(
        _treeWithFrame({'title': 'F1'}),
        draft,
        persistedPaths: {ref: '/app/frames/ref-a.png'},
      );

      final frameMap = (((tree['acts'] as List).first as Map)['scenes']
          as List)
          .first['frames'][0] as Map<String, dynamic>;
      expect(frameMap['reference_local_paths'], ['/app/frames/ref-a.png']);
    });

    test('clears reference paths when draft has none', () {
      final tree = _treeWithFrame({
        'title': 'F1',
        'reference_local_paths': ['/old.png'],
      });
      final draft = _draftWithFrame();

      final updated = applyDraftReferenceImagesToTree(tree, draft);
      final frameMap = (((updated['acts'] as List).first as Map)['scenes']
          as List)
          .first['frames'][0] as Map<String, dynamic>;
      expect(frameMap.containsKey('reference_local_paths'), isFalse);
    });
  });

  group('applyReferenceImagesFromFrameMap', () {
    test('restores reference images into draft', () {
      final frameDraft = FrameDraft(
        image: UploadImageFile(path: '/main.png', name: 'main.png'),
      );
      applyReferenceImagesFromFrameMap(frameDraft, {
        'reference_local_paths': ['/app/ref-1.png', '/app/ref-2.png'],
      });

      expect(frameDraft.referenceImages, hasLength(2));
      expect(frameDraft.referenceImages.first.path, '/app/ref-1.png');
      expect(frameDraft.referenceImages.first.name, 'ref-1.png');
    });
  });

  group('referenceImageRef', () {
    test('uses stable publish ref key', () {
      expect(referenceImageRef(0, 1, 2, 3), 'frame-0-1-2-ref-3');
    });
  });
}
