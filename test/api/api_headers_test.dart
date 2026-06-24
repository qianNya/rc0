import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/network/api_auth.dart';
import 'package:rc0/core/network/api_headers.dart';

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
      expect(isUnauthorizedError('登录已过期，请先登录'), isTrue);
      expect(isUnauthorizedError('请先登录'), isTrue);
    });

    test('does not treat generic request failed as login required', () {
      expect(isUnauthorizedError('request failed'), isFalse);
    });
  });

  group('isMaintenanceError', () {
    test('detects maintenance wording', () {
      expect(isMaintenanceError('系统维护中，请稍后再试'), isTrue);
      expect(isMaintenanceError('scheduled maintenance'), isTrue);
      expect(isMaintenanceError('服务器异常，请稍后重试'), isFalse);
    });
  });

  group('isNetworkError', () {
    test('detects network wording', () {
      expect(isNetworkError('网络连接失败，请检查网络'), isTrue);
      expect(isNetworkError('登录已过期，请先登录'), isFalse);
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
