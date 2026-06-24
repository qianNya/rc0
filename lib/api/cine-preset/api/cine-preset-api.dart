import '../../http/api_client.dart';
import '../data/cine-preset-api.dart';

List<CinePresetItem> _parsePresetList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CinePresetItem.fromJson)
      .toList();
}

Future listCinePresets({
  int? scope,
  Function(List<CinePresetItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-presets',
    query: scope != null ? {'scope': '$scope'} : null,
    ok: (data) => ok?.call(_parsePresetList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listMyCinePresets({
  Function(List<CinePresetItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-presets/mine',
    ok: (data) => ok?.call(_parsePresetList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future getCinePreset(
  int id, {
  Function(CinePresetItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-presets/$id',
    ok: (data) => ok?.call(CinePresetItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createCinePreset({
  required CinePresetWriteBody body,
  Function(CinePresetItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/cine-presets',
    body.toJson(),
    ok: (data) => ok?.call(CinePresetItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateCinePreset(
  int id, {
  required CinePresetUpdateBody body,
  Function(CinePresetItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/cine-presets/$id',
    body.toJson(),
    ok: (data) => ok?.call(CinePresetItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteCinePreset(
  int id, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/cine-presets/$id',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}
