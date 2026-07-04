import '../../../api/production-assets/data/production-assets-api.dart';
import '../domain/asset_category_ref.dart';
import '../domain/user_asset_category.dart';
import '../domain/user_asset_item.dart';

String localCategoryIdFromRemote(int remoteId) => 'user-cat-$remoteId';

String localItemIdFromRemote(int remoteId) => 'user-asset-$remoteId';

String categoryIdFromApiRef(String categoryRef) {
  if (AssetCategoryRef.isBuiltinId(categoryRef)) return categoryRef;
  if (categoryRef.startsWith('user:')) {
    final remoteId = int.tryParse(categoryRef.substring('user:'.length));
    if (remoteId != null) return localCategoryIdFromRemote(remoteId);
  }
  return categoryRef;
}

String categoryRefForApi({
  required String localCategoryId,
  UserAssetCategory? userCategory,
}) {
  if (AssetCategoryRef.isBuiltinId(localCategoryId)) {
    return localCategoryId;
  }
  final remoteId = userCategory?.remoteId;
  if (remoteId != null) return 'user:$remoteId';
  return localCategoryId;
}

UserAssetCategory categoryFromApi(ProductionAssetCategoryItem item) {
  return UserAssetCategory(
    id: localCategoryIdFromRemote(item.id),
    label: item.label,
    iconName: item.iconName,
    sort: item.sort,
    remoteId: item.id,
    createdAt: item.createAt,
    updatedAt: item.updateAt,
  );
}

UserAssetItem itemFromApi(ProductionAssetItemDto item) {
  return UserAssetItem(
    id: localItemIdFromRemote(item.id),
    categoryId: categoryIdFromApiRef(item.categoryRef),
    name: item.name,
    brand: item.brand,
    model: item.model,
    notes: item.notes,
    remoteId: item.id,
    createdAt: item.createAt,
    updatedAt: item.updateAt,
  );
}

ProductionAssetCategoryWriteBody categoryToWriteBody(UserAssetCategory category) {
  return ProductionAssetCategoryWriteBody(
    label: category.label,
    iconName: category.iconName,
    sort: category.sort,
  );
}

ProductionAssetCategoryUpdateBody categoryToUpdateBody(
  UserAssetCategory category,
) {
  return ProductionAssetCategoryUpdateBody(
    label: category.label,
    iconName: category.iconName,
    sort: category.sort,
  );
}

ProductionAssetItemWriteBody itemToWriteBody(
  UserAssetItem item,
  UserAssetCategory? userCategory,
) {
  return ProductionAssetItemWriteBody(
    categoryRef: categoryRefForApi(
      localCategoryId: item.categoryId,
      userCategory: userCategory,
    ),
    name: item.name,
    brand: item.brand,
    model: item.model,
    notes: item.notes,
  );
}

ProductionAssetItemUpdateBody itemToUpdateBody(
  UserAssetItem item,
  UserAssetCategory? userCategory,
) {
  return ProductionAssetItemUpdateBody(
    categoryRef: categoryRefForApi(
      localCategoryId: item.categoryId,
      userCategory: userCategory,
    ),
    name: item.name,
    brand: item.brand,
    model: item.model,
    notes: item.notes,
  );
}

UserAssetCategory? findUserCategoryByLocalId(
  List<UserAssetCategory> categories,
  String localCategoryId,
) {
  for (final category in categories) {
    if (category.id == localCategoryId) return category;
  }
  return null;
}
