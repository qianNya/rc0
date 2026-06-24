import '../../../core/domain/screenplay/screenplay.dart';
import 'screenplay_remote_repository.dart';

/// Resolves screenplay briefs for ID-only list endpoints (likes, favorites).
Future<Map<int, Screenplay>> enrichScreenplayIds(Iterable<int> ids) async {
  final repo = ScreenplayRemoteRepository.instance;
  final unique = ids.toSet().toList();
  final result = <int, Screenplay>{};
  const batchSize = 5;

  for (var i = 0; i < unique.length; i += batchSize) {
    final batch = unique.skip(i).take(batchSize);
    await Future.wait(
      batch.map((id) async {
        final detail = await repo.fetchScreenplayDetail(id);
        if (detail.screenplay != null) {
          result[id] = detail.screenplay!;
        }
      }),
    );
  }

  return result;
}
