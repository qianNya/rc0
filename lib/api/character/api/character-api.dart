import '../../http/api_client.dart';
import '../data/character-api.dart';

Future listCharacters({
  int page = 1,
  int pageSize = 20,
  int? workId,
  String? q,
  int? tagId,
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
  if (tagId != null) query['tag_id'] = '$tagId';

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

Future listCharacterScreenplays(
  int characterId, {
  int page = 1,
  int pageSize = 20,
  Function(ListCharacterScreenplaysResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId/screenplays',
    query: {
      'page': '$page',
      'page_size': '$pageSize',
    },
    ok: (data) => ok?.call(ListCharacterScreenplaysResp.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future linkImageCharacter(
  int imageId, {
  required int characterId,
  int relationType = 0,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/images/$imageId/characters',
    {
      'character_id': characterId,
      'relation_type': relationType,
    },
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listCostumes(
  int characterId, {
  Function(List<CostumeItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId/costumes',
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, CostumeItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future createCostume(
  int characterId, {
  required CostumeWriteBody body,
  Function(CostumeItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/characters/$characterId/costumes',
    body.toJson(),
    ok: (data) => ok?.call(CostumeItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getCostume(
  int characterId,
  int costumeId, {
  Function(CostumeItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId/costumes/$costumeId',
    ok: (data) => ok?.call(CostumeItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateCostume(
  int characterId,
  int costumeId, {
  required CostumeWriteBody body,
  Function(CostumeItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/characters/$characterId/costumes/$costumeId',
    body.toJson(),
    ok: (data) => ok?.call(CostumeItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteCostume(
  int characterId,
  int costumeId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/characters/$characterId/costumes/$costumeId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future setDefaultCostume(
  int characterId,
  int costumeId, {
  Function(CostumeItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/characters/$characterId/costumes/$costumeId/set-default',
    const {},
    ok: (data) => ok?.call(CostumeItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listCharacterProps(
  int characterId, {
  Function(List<PropItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId/props',
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, PropItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future createCharacterProp(
  int characterId, {
  required PropWriteBody body,
  Function(PropItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/characters/$characterId/props',
    body.toJson(),
    ok: (data) => ok?.call(PropItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listCostumeProps(
  int costumeId, {
  Function(List<PropItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/costumes/$costumeId/props',
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, PropItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future createCostumeProp(
  int costumeId, {
  required PropWriteBody body,
  Function(PropItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/costumes/$costumeId/props',
    body.toJson(),
    ok: (data) => ok?.call(PropItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateCharacterProp(
  int propId, {
  required PropWriteBody body,
  Function(PropItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/character-props/$propId',
    body.toJson(),
    ok: (data) => ok?.call(PropItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteCharacterProp(
  int propId, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/character-props/$propId',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listSceneAffinities(
  int characterId, {
  Function(List<SceneAffinityItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/characters/$characterId/scene-affinities',
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, SceneAffinityItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future replaceSceneAffinities(
  int characterId, {
  required List<SceneAffinityWriteItem> items,
  Function(List<SceneAffinityItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/characters/$characterId/scene-affinities',
    {
      'items': items.map((e) => e.toJson()).toList(),
    },
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, SceneAffinityItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future listScreenplayCast(
  int screenplayId, {
  Function(List<CastItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/screenplays/$screenplayId/cast',
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, CastItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}

Future replaceScreenplayCast(
  int screenplayId, {
  required List<CastWriteItem> items,
  Function(List<CastItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/screenplays/$screenplayId/cast',
    {
      'items': items.map((e) => e.toJson()).toList(),
    },
    ok: (data) => ok?.call(
      parseCharacterListPayload(data, CastItem.fromJson),
    ),
    fail: fail,
    eventually: eventually,
  );
}
