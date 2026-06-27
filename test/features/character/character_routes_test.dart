import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/app/router/routes.dart';

void main() {
  test('character detail path helper', () {
    expect(AppRoutes.characterDetailPath(42), '/character/42');
    expect(AppRoutes.characterEditPath(7), '/character/7/edit');
    expect(AppRoutes.character, '/character');
    expect(AppRoutes.characterAi, '/character/ai');
    expect(AppRoutes.myCharacters, '/my-characters');
  });

  test('charactersForWork builds query path', () {
    expect(AppRoutes.charactersForWork(9), '/character?work_id=9');
  });
}
