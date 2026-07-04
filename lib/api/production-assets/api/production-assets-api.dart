import '../../http/api_client.dart';
import '../data/production-assets-api.dart';

List<ProductionAssetCategoryItem> _parseCategoryList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(ProductionAssetCategoryItem.fromJson)
      .toList();
}

List<ProductionAssetItemDto> _parseItemList(dynamic data) {
  if (data is! List) return [];
  return data
      .whereType<Map<String, dynamic>>()
      .map(ProductionAssetItemDto.fromJson)
      .toList();
}

Future listProductionAssetCategories({
  Function(List<ProductionAssetCategoryItem>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/production-assets/categories',
    ok: (data) => ok?.call(_parseCategoryList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createProductionAssetCategory({
  required ProductionAssetCategoryWriteBody body,
  Function(ProductionAssetCategoryItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/production-assets/categories',
    body.toJson(),
    ok: (data) => ok?.call(ProductionAssetCategoryItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateProductionAssetCategory(
  int id, {
  required ProductionAssetCategoryUpdateBody body,
  Function(ProductionAssetCategoryItem)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/production-assets/categories/$id',
    body.toJson(),
    ok: (data) => ok?.call(ProductionAssetCategoryItem.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteProductionAssetCategory(
  int id, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/production-assets/categories/$id',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}

Future listProductionAssetItems({
  String? categoryRef,
  Function(List<ProductionAssetItemDto>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    '/production-assets/items',
    query: categoryRef != null && categoryRef.isNotEmpty
        ? {'category_ref': categoryRef}
        : null,
    ok: (data) => ok?.call(_parseItemList(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future createProductionAssetItem({
  required ProductionAssetItemWriteBody body,
  Function(ProductionAssetItemDto)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    '/production-assets/items',
    body.toJson(),
    ok: (data) => ok?.call(ProductionAssetItemDto.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future updateProductionAssetItem(
  int id, {
  required ProductionAssetItemUpdateBody body,
  Function(ProductionAssetItemDto)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPut(
    '/production-assets/items/$id',
    body.toJson(),
    ok: (data) => ok?.call(ProductionAssetItemDto.fromJson(data)),
    fail: fail,
    eventually: eventually,
  );
}

Future deleteProductionAssetItem(
  int id, {
  Function(Map<String, dynamic>)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiDelete(
    '/production-assets/items/$id',
    ok: ok,
    fail: fail,
    eventually: eventually,
  );
}
