import '../../../core/domain/screenplay/screenplay.dart';

class ScreenplayDeleteOptions {
  const ScreenplayDeleteOptions({this.deleteRemote = false});

  final bool deleteRemote;
}

class ScreenplayDeleteConfirmation {
  const ScreenplayDeleteConfirmation({
    required this.confirmed,
    this.deleteRemote = false,
  });

  final bool confirmed;
  final bool deleteRemote;
}

/// Whether the screenplay can offer a cloud-delete checkbox.
bool screenplayCanDeleteRemote(Screenplay script) {
  if (script.isForkCopy) return false;
  return script.remoteScreenplayId != null;
}

/// Whether any script in the list can sync-delete remote.
bool anyScreenplayCanDeleteRemote(Iterable<Screenplay> scripts) =>
    scripts.any(screenplayCanDeleteRemote);

bool isRemoteNotFoundError(String? message) {
  if (message == null || message.isEmpty) return false;
  final lower = message.toLowerCase();
  return lower.contains('404') ||
      lower.contains('not found') ||
      lower.contains('不存在');
}

String localIdForScreenplay(
  Screenplay script,
  String? Function(String id) findById,
  Screenplay? Function(int remoteId) findByRemoteId,
) {
  if (findById(script.id) != null) return script.id;
  final remoteId = script.remoteScreenplayId;
  if (remoteId != null) {
    final local = findByRemoteId(remoteId);
    if (local != null) return local.id;
  }
  return script.id;
}
