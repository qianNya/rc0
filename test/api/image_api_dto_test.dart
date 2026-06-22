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
}
