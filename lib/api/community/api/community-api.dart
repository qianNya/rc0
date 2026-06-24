import '../../http/api_client.dart';
import '../data/community-api.dart';

Future toggleLike(
  int screenplayId, {
  Function(ToggleEngagementResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/likes/$screenplayId',
    const {},
    ok: (data) => ok?.call(ToggleEngagementResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future toggleFavorite(
  int screenplayId, {
  Function(ToggleEngagementResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/favorites/$screenplayId',
    const {},
    ok: (data) => ok?.call(ToggleEngagementResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listScreenplayTags({
  String namespace = 'default',
  Function(ListScreenplayTagsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/tags',
    query: {'namespace': namespace},
    ok: (data) => ok?.call(ListScreenplayTagsResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createScreenplayTag({
  required String name,
  String namespace = 'default',
  String? slug,
  Function(ScreenplayTagItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final body = <String, dynamic>{
    'namespace': namespace,
    'name': name,
    'slug': slug ?? _slugifyTag(name),
  };
  await apiPost(
    '/tags',
    body,
    ok: (data) => ok?.call(ScreenplayTagItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future tagScreenplay(
  int screenplayId, {
  required int tagId,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/tags/$screenplayId',
    {'tag_id': tagId},
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future untagScreenplay(
  int screenplayId,
  int tagId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/tags/$screenplayId/$tagId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

String _slugifyTag(String name) {
  final trimmed = name.trim().toLowerCase();
  if (trimmed.isEmpty) return 'tag';
  return trimmed.replaceAll(RegExp(r'\s+'), '-');
}
