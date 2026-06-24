import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/screenplay/api/screenplay-api.dart' as screenplay_api;
import 'package:rc0/api/screenplay/data/screenplay-api.dart' as sp_dto;

void main() {
  test('buildScreenplayTreeQuery requests full depth tree', () {
    final query = screenplay_api.buildScreenplayTreeQuery();
    expect(query['depth'], '3');
    expect(query['act_page_size'], '0');
    expect(query['scene_page_size'], '0');
    expect(query['frame_page_size'], '0');
  });

  test('normalizeScreenplayTreeJson wraps flat act and scene nodes', () {
    final normalized = sp_dto.normalizeScreenplayTreeJson({
      'screenplay': {
        'id': 14,
        'title': '喵喵喵',
        'summary': null,
        'act_count': 1,
      },
      'acts': [
        {
          'id': 1,
          'title': '第一幕',
          'sort': 1,
          'scenes': [
            {
              'id': 2,
              'title': '第一场',
              'sort': 1,
              'frames': [
                {'id': 3, 'title': '画1', 'sort': 1, 'image_url': 'http://x/a.jpg'},
              ],
            },
          ],
        },
      ],
    });

    final resp = sp_dto.GetScreenplayTreeResp.fromJson(normalized);
    expect(resp.screenplay.title, '喵喵喵');
    expect(resp.screenplay.summary, '');
    expect(resp.acts, hasLength(1));
    expect(resp.acts.first.act.title, '第一幕');
    expect(resp.acts.first.scenes, hasLength(1));
    expect(resp.acts.first.scenes.first.scene.title, '第一场');
    expect(resp.acts.first.scenes.first.frames, hasLength(1));
    expect(resp.acts.first.scenes.first.frames.first.imageUrl,
        'http://x/a.jpg');
  });
}
