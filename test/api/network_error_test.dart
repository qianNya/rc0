import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/network/network_error.dart';

void main() {
  group('friendlyNetworkError', () {
    test('formats SocketException in Chinese', () {
      expect(
        friendlyNetworkError(const SocketException('connection refused')),
        '网络连接失败，请检查网络',
      );
    });

    test('formats empty SocketException in Chinese', () {
      expect(
        friendlyNetworkError(const SocketException('')),
        '网络连接失败，请检查网络',
      );
    });

    test('formats HttpException with message', () {
      expect(
        friendlyNetworkError(const HttpException('bad response')),
        'bad response',
      );
    });

    test('formats empty HttpException in Chinese', () {
      expect(
        friendlyNetworkError(const HttpException('')),
        '网络异常，请稍后重试',
      );
    });

    test('falls back to generic Chinese for other errors', () {
      expect(
        friendlyNetworkError(Exception('unexpected')),
        '网络异常，请稍后重试',
      );
    });
  });
}
