import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft_tags.dart';
import 'package:rc0/features/upload/domain/upload_image_file.dart';

UploadImageFile _image(String name) =>
    UploadImageFile(path: '/tmp/$name', name: name);

void main() {
  group('draftTagPool', () {
    test('unions tags from all levels', () {
      final draft = ScreenplayDraft(
        tags: {'站姿'},
        acts: [
          ActDraft(
            tags: {'夜景'},
            scenes: [
              SceneDraft(
                tags: {'室内'},
                frames: [
                  FrameDraft(
                    image: _image('a.jpg'),
                    tags: {'逆光'},
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      expect(draftTagPool(draft), {'站姿', '夜景', '室内', '逆光'});
    });
  });

  group('toggleDraftNodeTag', () {
    test('toggles membership', () {
      final node = {'站姿'};
      toggleDraftNodeTag(node, '夜景');
      expect(node, {'站姿', '夜景'});
      toggleDraftNodeTag(node, '站姿');
      expect(node, {'夜景'});
    });
  });

  group('addTagToDraftPool', () {
    test('adds trimmed tag to screenplay draft', () {
      final draft = ScreenplayDraft(tags: {});
      addTagToDraftPool(draft, '  站姿  ');
      expect(draft.tags, {'站姿'});
    });
  });

  group('mergeTagSuggestions', () {
    test('merges pool and remote suggestions', () {
      expect(
        mergeTagSuggestions(
          pool: {'站姿'},
          remoteSuggestions: ['夜景', '站姿'],
        ),
        ['夜景', '站姿'],
      );
    });
  });
}
