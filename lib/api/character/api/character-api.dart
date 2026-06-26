import '../../http/api_client.dart';
import '../data/character-api.dart';

Future listCharacters({
  int page = 1,
  int pageSize = 20,
  int? workId,
  String? q,
  Function(ListCharactersResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
  };
  if (workId != null) query['work_id'] = '$workId';
  if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();

  await apiGet(
    '/characters',
    query: query,
    ok: (data) => ok?.call(ListCharactersResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listWorkCharacters(
  int workId, {
  int page = 1,
  int pageSize = 20,
  String? q,
  Function(ListCharactersResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  final query = <String, String>{
    'page': '$page',
    'page_size': '$pageSize',
  };
  if (q != null && q.trim().isNotEmpty) query['q'] = q.trim();

  await apiGet(
    '/works/$workId/characters',
    query: query,
    ok: (data) => ok?.call(ListCharactersResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getCharacter(
  int characterId, {
  Function(CharacterItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId',
    ok: (data) => ok?.call(CharacterItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createCharacter({
  required CharacterWriteBody body,
  Function(CharacterItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/characters',
    body.toJson(),
    ok: (data) => ok?.call(CharacterItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createWorkCharacter(
  int workId, {
  required CharacterWriteBody body,
  Function(CharacterItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/works/$workId/characters',
    body.toJson(),
    ok: (data) => ok?.call(CharacterItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateCharacter(
  int characterId, {
  required CharacterWriteBody body,
  Function(CharacterItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/characters/$characterId',
    body.toJson(),
    ok: (data) => ok?.call(CharacterItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteCharacter(
  int characterId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/characters/$characterId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}
