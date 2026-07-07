import '../../http/api_client.dart';
import '../data/media-vault-api.dart';

List<T> _parseList<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = data['items'] ?? data['list'] ?? [];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList(growable: false);
}

Future listMediaVaultAlbums({
  Function(List<MediaVaultAlbumItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/media-vault/albums',
    ok: (data) => ok?.call(_parseList(data, MediaVaultAlbumItem.fromJson)),
    fail: fail,
    eventually: eventually,
  );
}

Future createMediaVaultAlbum({
  required MediaVaultCreateAlbumBody body,
  Function(MediaVaultAlbumItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/media-vault/albums',
    body.toJson(),
    ok: (data) => ok?.call(MediaVaultAlbumItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteMediaVaultAlbum({
  required int albumId,
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/media-vault/albums/$albumId',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future addMediaVaultAlbumImage({
  required int albumId,
  required int imageId,
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/media-vault/albums/$albumId/images',
    {'image_id': imageId},
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future listMediaVaultImageStates({
  Function(List<MediaVaultImageStateItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/media-vault/image-states',
    ok: (data) =>
        ok?.call(_parseList(data, MediaVaultImageStateItem.fromJson)),
    fail: fail,
    eventually: eventually,
  );
}

Future listMediaVaultAlbumMemberships({
  Function(List<MediaVaultAlbumMembershipItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/media-vault/album-memberships',
    ok: (data) => ok?.call(
      _parseList(data, MediaVaultAlbumMembershipItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future patchMediaVaultImageState({
  required int imageId,
  required MediaVaultPatchImageStateBody body,
  Function(MediaVaultImageStateItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPatch(
    '/media-vault/images/$imageId/state',
    body.toJson(),
    ok: (data) => ok?.call(MediaVaultImageStateItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteMediaVaultImage({
  required int imageId,
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/media-vault/images/$imageId',
    ok: (_) => ok?.call(),
    fail: fail,
    eventually: eventually,
  );
}

Future getMediaVaultMetrics({
  Function(MediaVaultMetricsItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/media-vault/metrics',
    ok: (data) => ok?.call(MediaVaultMetricsItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
