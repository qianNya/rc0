import '../../http/api_client.dart';
import '../data/feed-api.dart';

Future listFeed({
  int page = 1,
  int pageSize = 20,
  String sort = 'latest',
  String? q,
  int? tagId,
  int? kind,
  Function(ListFeedResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
    'sort': sort,
  };
  final trimmedQ = q?.trim();
  if (trimmedQ != null && trimmedQ.isNotEmpty) query['q'] = trimmedQ;
  if (tagId != null) query['tag_id'] = '$tagId';
  if (kind != null) query['kind'] = '$kind';

  await apiGet(
    '/feed',
    query: query,
    ok: (data) => ok?.call(ListFeedResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future search({
  required String q,
  String type = 'screenplay',
  int page = 1,
  int pageSize = 20,
  Function(SearchResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/search',
    query: {
      'q': q.trim(),
      'type': type,
      'page': '$page',
      'page_size': '$pageSize',
    },
    ok: (data) => ok?.call(SearchResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
