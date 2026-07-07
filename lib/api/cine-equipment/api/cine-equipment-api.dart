import '../../http/api_client.dart';
import '../data/cine-equipment-api.dart';

List<CineEquipmentBrandItem> _parseBrandList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CineEquipmentBrandItem.fromJson)
      .toList();
}

List<CineCameraBodyItem> _parseBodyList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CineCameraBodyItem.fromJson)
      .toList();
}

List<CineLensItem> _parseLensList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CineLensItem.fromJson)
      .toList();
}

List<CineCameraSetupItem> _parseSetupList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CineCameraSetupItem.fromJson)
      .toList();
}

List<CineEquipmentFavoriteItem> _parseFavoriteList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(CineEquipmentFavoriteItem.fromJson)
      .toList();
}

Future listCineEquipmentBrands({
  String? category,
  String? kind,
  Function(List<CineEquipmentBrandItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/brands',
    query: {
      if (category != null && category.isNotEmpty) 'category': category,
      if (kind != null && kind.isNotEmpty) 'kind': kind,
    },
    ok: (data) => ok?.call(_parseBrandList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listCineCameraBodies({
  String? category,
  String? brand,
  Function(List<CineCameraBodyItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/bodies',
    query: {
      if (category != null && category.isNotEmpty) 'category': category,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
    },
    ok: (data) => ok?.call(_parseBodyList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listCineLenses({
  String? category,
  String? brand,
  Function(List<CineLensItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/lenses',
    query: {
      if (category != null && category.isNotEmpty) 'category': category,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
    },
    ok: (data) => ok?.call(_parseLensList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listCineCameraSetups({
  int? scope,
  Function(List<CineCameraSetupItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/setups',
    query: scope != null ? {'scope': '$scope'} : null,
    ok: (data) => ok?.call(_parseSetupList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future listMyCineCameraSetups({
  Function(List<CineCameraSetupItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/setups/mine',
    ok: (data) => ok?.call(_parseSetupList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createCineCameraSetup({
  required CineCameraSetupWriteBody body,
  Function(CineCameraSetupItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/cine-equipment/setups',
    body.toJson(),
    ok: (data) => ok?.call(CineCameraSetupItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateCineCameraSetup(
  int id, {
  required CineCameraSetupUpdateBody body,
  Function(CineCameraSetupItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/cine-equipment/setups/$id',
    body.toJson(),
    ok: (data) => ok?.call(CineCameraSetupItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteCineCameraSetup(
  int id, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/cine-equipment/setups/$id',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listCineEquipmentFavorites({
  Function(List<CineEquipmentFavoriteItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/favorites',
    ok: (data) => ok?.call(_parseFavoriteList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future toggleCineEquipmentFavorite({
  required CineEquipmentFavoriteToggleBody body,
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/cine-equipment/favorites/toggle',
    body.toJson(),
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future getGearCabinetLayout({
  Function(GearCabinetLayoutItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/cine-equipment/layout',
    ok: (data) => ok?.call(GearCabinetLayoutItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future saveGearCabinetLayout({
  required GearCabinetLayoutSaveBody body,
  Function(GearCabinetLayoutItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/cine-equipment/layout',
    body.toJson(),
    ok: (data) => ok?.call(GearCabinetLayoutItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}
