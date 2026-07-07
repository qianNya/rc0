import 'package:flutter_test/flutter_test.dart';
import 'package:rc0_network/rc0_network.dart';

void main() {
  test('ApiEnvelope treats code 0 as success', () {
    final env = ApiEnvelope<int>.fromJson({
      'code': 0,
      'message': 'ok',
      'data': {'x': 1},
    });
    expect(env.isSuccess, isTrue);
    expect(env.message, 'ok');
  });

  test('apiErrorMessage reads message field', () {
    expect(apiErrorMessage({'message': 'bad'}), 'bad');
  });
}
