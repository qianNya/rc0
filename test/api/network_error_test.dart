import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/network/network_error.dart';

void main() {
  group('friendlyNetworkError', () {
    test('formats SocketException with message', () {
      expect(
        friendlyNetworkError(const SocketException('connection refused')),
        'network error: connection refused',
      );
    });

    test('formats empty SocketException', () {
      expect(
        friendlyNetworkError(const SocketException('')),
        'network error',
      );
    });

    test('formats HttpException', () {
      expect(
        friendlyNetworkError(const HttpException('bad response')),
        'bad response',
      );
    });

    test('falls back to toString for other errors', () {
      expect(
        friendlyNetworkError(Exception('unexpected')),
        'Exception: unexpected',
      );
    });
  });
}
