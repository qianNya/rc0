import '../../http/api_client.dart';
import '../data/work-api.dart';

Future listWorks({
  int page = 1,
  int pageSize = 20,
  Function(ListWorksResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/works',
    query: {'page': '$page', 'page_size': '$pageSize'},
    ok: (data) => ok?.call(ListWorksResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getWork(
  int workId, {
  Function(WorkItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/works/$workId',
    ok: (data) => ok?.call(WorkItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createWork({
  required WorkWriteBody body,
  Function(WorkItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/works',
    body.toJson(),
    ok: (data) => ok?.call(WorkItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateWork(
  int workId, {
  required WorkWriteBody body,
  Function(WorkItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/works/$workId',
    body.toJson(),
    ok: (data) => ok?.call(WorkItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteWork(
  int workId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/works/$workId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}
