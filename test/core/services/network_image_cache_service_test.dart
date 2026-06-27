import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/services/network_image_cache_service.dart';

void main() {
  test('cacheFileName is stable for the same url', () {
    const url = 'https://cdn.example.com/frame.webp';
    final cache = NetworkImageCacheService.instance;
    expect(cache.cacheFileName(url), cache.cacheFileName(url));
    expect(cache.cacheFileName(url), endsWith('.webp'));
  });
}
