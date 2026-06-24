import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/screenplay/data/screenplay_remote_repository.dart';
import 'package:rc0/features/user/data/user_screenplays_repository.dart';

void main() {
  test('ScreenplayRemoteRepository hasMore is false when empty', () {
    final repo = ScreenplayRemoteRepository.instance;
    expect(repo.hasMore, isFalse);
    expect(repo.screenplays, isEmpty);
  });

  test('UserScreenplaysRepository hasMoreFor is false for unknown user', () {
    final repo = UserScreenplaysRepository.instance;
    expect(repo.hasMoreFor(999999), isFalse);
    expect(repo.itemsFor(999999), isEmpty);
  });
}
