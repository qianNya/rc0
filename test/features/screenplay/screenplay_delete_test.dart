import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/domain/screenplay/screenplay.dart';
import 'package:rc0/features/screenplay/data/screenplay_delete_options.dart';

void main() {
  group('isRemoteNotFoundError', () {
    test('detects 404 and not found messages', () {
      expect(isRemoteNotFoundError('404 not found'), isTrue);
      expect(isRemoteNotFoundError('请求的资源不存在'), isTrue);
      expect(isRemoteNotFoundError('not found'), isTrue);
      expect(isRemoteNotFoundError('无权访问'), isFalse);
      expect(isRemoteNotFoundError(null), isFalse);
    });
  });

  group('screenplayCanDeleteRemote', () {
    test('returns false for fork copies', () {
      const script = Screenplay(
        id: 'local-1',
        title: 'Fork',
        isLocal: true,
        remoteScreenplayId: 16,
        forkedFromLocalId: 'origin',
      );
      expect(screenplayCanDeleteRemote(script), isFalse);
    });

    test('returns true when remote id exists and not fork', () {
      const script = Screenplay(
        id: 'local-1',
        title: 'Published',
        isLocal: true,
        remoteScreenplayId: 16,
      );
      expect(screenplayCanDeleteRemote(script), isTrue);
    });

    test('returns false for local-only draft', () {
      const script = Screenplay(
        id: 'local-1',
        title: 'Draft',
        isLocal: true,
      );
      expect(screenplayCanDeleteRemote(script), isFalse);
    });
  });

  group('anyScreenplayCanDeleteRemote', () {
    test('returns true when any script can delete remote', () {
      const scripts = [
        Screenplay(id: 'a', title: 'A', isLocal: true),
        Screenplay(
          id: 'b',
          title: 'B',
          isLocal: true,
          remoteScreenplayId: 1,
        ),
      ];
      expect(anyScreenplayCanDeleteRemote(scripts), isTrue);
    });
  });

  group('localIdForScreenplay', () {
    test('resolves by remote id when direct id misses', () {
      const remoteScript = Screenplay(
        id: '16',
        title: 'Remote view',
        remoteScreenplayId: 16,
      );
      const localScript = Screenplay(
        id: 'script-local',
        title: 'Local',
        isLocal: true,
        remoteScreenplayId: 16,
      );

      final localId = localIdForScreenplay(
        remoteScript,
        (id) => id == '16' ? null : null,
        (remoteId) => remoteId == 16 ? localScript : null,
      );

      expect(localId, 'script-local');
    });
  });
}
