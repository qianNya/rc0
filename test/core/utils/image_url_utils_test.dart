import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/utils/image_url_utils.dart';

void main() {
  test('sanitizeLegacyImageUrl repairs malformed minio port', () {
    const raw =
        'http://your-host:9090idea/rc0/69676a7a1efafc865dcb48c2316303bd.jpg';
    final fixed = sanitizeLegacyImageUrl(raw);
    expect(fixed, isNotNull);
    expect(
      fixed,
      'http://112.74.176.124:9090/rc0/69676a7a1efafc865dcb48c2316303bd.jpg',
    );
    expect(isValidNetworkImageUrl(fixed!), isTrue);
  });

  test('isValidNetworkImageUrl rejects invalid port', () {
    expect(
      isValidNetworkImageUrl(
        'http://your-host:9090idea/rc0/test.jpg',
      ),
      isFalse,
    );
  });
}
