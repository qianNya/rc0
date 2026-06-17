import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/http/api_auth_error.dart';
import 'package:rc0/api/http/api_headers.dart';

void main() {
  group('apiErrorMessage', () {
    test('reads msg from backend envelope', () {
      expect(
        apiErrorMessage({'code': 401, 'msg': 'unauthorized'}),
        'unauthorized',
      );
    });

    test('falls back to desc for legacy responses', () {
      expect(
        apiErrorMessage({'code': 1, 'desc': 'legacy error'}),
        'legacy error',
      );
    });

    test('returns fallback when msg is missing', () {
      expect(
        apiErrorMessage({'code': 401}),
        'request failed',
      );
    });
  });

  group('isUnauthorizedError', () {
    test('detects unauthorized and unauthenticated', () {
      expect(isUnauthorizedError('unauthorized'), isTrue);
      expect(isUnauthorizedError('unauthenticated'), isTrue);
      expect(isUnauthorizedError('invalid token'), isTrue);
    });

    test('does not treat generic request failed as login required', () {
      expect(isUnauthorizedError('request failed'), isFalse);
    });
  });

  group('authorizationHeader', () {
    test('adds Bearer prefix when missing', () {
      expect(authorizationHeader('abc'), 'Bearer abc');
    });

    test('keeps existing Bearer prefix', () {
      expect(authorizationHeader('Bearer abc'), 'Bearer abc');
    });
  });
}
