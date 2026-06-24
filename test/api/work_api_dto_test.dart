import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/work/data/work-api.dart';

void main() {
  test('WorkItem parses work fields', () {
    final work = WorkItem.fromJson({
      'id': 9,
      'title': '某动漫作品',
      'work_type': 2,
      'release_year': 2024,
      'summary': '简介',
    });

    expect(work.title, '某动漫作品');
    expect(work.workType, 2);
    expect(work.releaseYear, 2024);
    expect(work.summary, '简介');
  });

  test('ListWorksResp reads items list', () {
    final resp = ListWorksResp.fromJson({
      'items': [
        {
          'id': 1,
          'title': 'A',
          'work_type': 2,
          'release_year': 2020,
          'summary': '',
        },
      ],
      'total': 1,
      'page': 1,
      'page_size': 20,
    });

    expect(resp.list, hasLength(1));
    expect(resp.total, 1);
    expect(resp.list.first.title, 'A');
  });

  test('WorkWriteBody serializes create/update payload', () {
    const body = WorkWriteBody(
      title: '新 IP',
      workType: 3,
      releaseYear: 2025,
      summary: '游戏 IP',
    );

    expect(body.toJson(), {
      'title': '新 IP',
      'work_type': 3,
      'release_year': 2025,
      'summary': '游戏 IP',
    });
  });
}
