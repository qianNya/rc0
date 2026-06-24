import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/network/api_response_interceptor.dart';

void main() {
  group('ApiResponseInterceptor.intercept', () {
    test('HTTP 200 + code 0 returns success with data', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":0,"data":{"id":1}}',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, {'id': 1});
      expect(result.shouldPresentGlobally, isFalse);
    });

    test('HTTP 200 + code 0 with non-map data returns empty map', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":0,"data":[]}',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('envelope code 401 is unauthorized with global presentation', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":401,"msg":"unauthorized"}',
      );

      expect(result.isSuccess, isFalse);
      expect(result.category, ApiErrorCategory.unauthorized);
      expect(result.message, '登录已过期，请先登录');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('HTTP 401 is unauthorized', () {
      final result = ApiResponseInterceptor.intercept(401, '');

      expect(result.category, ApiErrorCategory.unauthorized);
      expect(result.message, '登录已过期，请先登录');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('HTTP 503 returns maintenance message', () {
      final result = ApiResponseInterceptor.intercept(503, '');

      expect(result.category, ApiErrorCategory.server);
      expect(result.message, '系统维护中，请稍后再试');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('envelope code 503 returns maintenance message', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":503,"msg":"scheduled maintenance"}',
      );

      expect(result.category, ApiErrorCategory.server);
      expect(result.message, '系统维护中，请稍后再试');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('envelope maintenance text returns maintenance message', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":1,"msg":"系统维护中，预计 30 分钟"}',
      );

      expect(result.category, ApiErrorCategory.server);
      expect(result.message, '系统维护中，请稍后再试');
    });

    test('HTTP 500 with non-JSON body is server error', () {
      final result = ApiResponseInterceptor.intercept(500, 'Internal Server Error');

      expect(result.category, ApiErrorCategory.server);
      expect(result.message, '服务器异常，请稍后重试');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('HTTP 500 with JSON envelope is server error', () {
      final result = ApiResponseInterceptor.intercept(
        500,
        '{"code":1,"msg":"db error"}',
      );

      expect(result.category, ApiErrorCategory.server);
      expect(result.message, '服务器异常，请稍后重试');
      expect(result.shouldPresentGlobally, isTrue);
    });

    test('HTTP 200 + business code uses envelope message', () {
      final result = ApiResponseInterceptor.intercept(
        200,
        '{"code":1,"msg":"用户名或密码错误"}',
      );

      expect(result.isSuccess, isFalse);
      expect(result.category, ApiErrorCategory.business);
      expect(result.message, '用户名或密码错误');
      expect(result.shouldPresentGlobally, isFalse);
    });

    test('HTTP 404 returns business not-found message', () {
      final result = ApiResponseInterceptor.intercept(
        404,
        '{"code":1,"msg":"not found"}',
      );

      expect(result.category, ApiErrorCategory.business);
      expect(result.message, '请求的资源不存在');
      expect(result.shouldPresentGlobally, isFalse);
    });

    test('HTTP 403 returns business forbidden message', () {
      final result = ApiResponseInterceptor.intercept(
        403,
        '{"code":1,"msg":"forbidden"}',
      );

      expect(result.category, ApiErrorCategory.business);
      expect(result.message, '无权访问此资源');
      expect(result.shouldPresentGlobally, isFalse);
    });

    test('HTTP 429 returns rate-limit message', () {
      final result = ApiResponseInterceptor.intercept(429, '');

      expect(result.category, ApiErrorCategory.business);
      expect(result.message, '请求过于频繁，请稍后再试');
      expect(result.shouldPresentGlobally, isFalse);
    });

    test('non-JSON bad response', () {
      final result = ApiResponseInterceptor.intercept(200, 'not json');

      expect(result.category, ApiErrorCategory.badResponse);
      expect(result.message, '服务响应异常，请稍后重试');
      expect(result.shouldPresentGlobally, isFalse);
    });
  });

  group('ApiResponseInterceptor.network', () {
    test('network errors present globally', () {
      final result = ApiResponseInterceptor.network('网络连接失败，请检查网络');

      expect(result.category, ApiErrorCategory.network);
      expect(result.message, '网络连接失败，请检查网络');
      expect(result.shouldPresentGlobally, isTrue);
    });
  });
}
