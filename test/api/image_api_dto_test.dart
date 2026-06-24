import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/image/data/image-api.dart';

void main() {
  test('GalleryImageItem reads http url from files array', () {
    const json = {
      'id': 42,
      'title': 'test',
      'description': '',
      'files': [
        {
          'file_role': 1,
          'url': 'http://192.168.3.42:9090/rc0/abc.jpg',
        },
      ],
    };

    final item = GalleryImageItem.fromJson(json);
    expect(item.imageUrl, 'http://192.168.3.42:9090/rc0/abc.jpg');
    expect(item.thumbnailUrl, 'http://192.168.3.42:9090/rc0/abc.jpg');
  });

  test('ImageDetailResp prefers flat image_url over files', () {
    final resp = ImageDetailResp.fromJson({
      'id': 1,
      'title': 't',
      'image_url': 'https://cdn.example.com/a.jpg',
      'files': [
        {'file_role': 1, 'url': 'http://minio.local/b.jpg'},
      ],
    });

    expect(resp.imageUrl, 'https://cdn.example.com/a.jpg');
  });

  test('GalleryImageItem parses tag names and ids', () {
    final item = GalleryImageItem.fromJson({
      'id': 7,
      'title': 'portrait',
      'tags': [
        '4K',
        {'id': 2, 'name': '插画', 'slug': 'illustration'},
      ],
    });

    expect(item.tags, ['4K', '插画']);
    expect(item.tagIds, [2]);
  });

  test('ImageTagItem reads count aliases', () {
    final tag = ImageTagItem.fromJson({
      'id': 3,
      'name': '摄影',
      'slug': 'photo',
      'namespace': 'general',
      'count': 12,
    });

    expect(tag.name, '摄影');
    expect(tag.imageCount, 12);
  });

  test('ListImageTagsResp reads wrapped items list', () {
    final resp = ListImageTagsResp.fromJson({
      'items': [
        {'id': 1, 'name': '全部风格', 'slug': 'all', 'namespace': 'general'},
      ],
    });

    expect(resp.list, hasLength(1));
    expect(resp.list.first.slug, 'all');
  });
}
