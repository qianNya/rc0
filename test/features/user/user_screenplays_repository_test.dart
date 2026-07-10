import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/domain/screenplay/screenplay.dart';
import 'package:rc0/features/user/data/user_screenplays_repository.dart';

void main() {
  test('UserScreenplaysRepository starts empty for unknown user', () {
    final repo = UserScreenplaysRepository.instance;
    expect(repo.itemsFor(0), isEmpty);
    expect(repo.loadingFor(0), isFalse);
    expect(repo.hasMoreFor(0), isFalse);
  });

  test('updateItemVisibility patches matching remote screenplay', () {
    final repo = UserScreenplaysRepository.instance;
    const userId = 777001;
    repo.debugSetItems(
      userId,
      [
        const Screenplay(
          id: '14',
          title: '喵喵喵',
          isLocal: false,
          remoteScreenplayId: 14,
          visibility: 0,
        ),
      ],
    );
    repo.updateItemVisibility(userId, 14, 1);
    expect(repo.itemsFor(userId).single.visibility, 1);
    repo.debugSetItems(userId, []);
  });

  test('removeItem drops remote screenplay and decrements total', () {
    final repo = UserScreenplaysRepository.instance;
    const userId = 777002;
    repo.debugSetItems(
      userId,
      [
        const Screenplay(
          id: '14',
          title: 'A',
          isLocal: false,
          remoteScreenplayId: 14,
        ),
        const Screenplay(
          id: '15',
          title: 'B',
          isLocal: false,
          remoteScreenplayId: 15,
        ),
      ],
    );
    repo.removeItem(userId, 14);
    expect(repo.itemsFor(userId).map((s) => s.remoteScreenplayId), [15]);
    repo.debugSetItems(userId, []);
  });
}
