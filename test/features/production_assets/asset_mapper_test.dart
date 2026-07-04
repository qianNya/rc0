import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/production-assets/data/production-assets-api.dart';
import 'package:rc0/features/production_assets/data/asset_mapper.dart';
import 'package:rc0/features/production_assets/domain/asset_category_ref.dart';
import 'package:rc0/features/production_assets/domain/user_asset_category.dart';
import 'package:rc0/features/production_assets/domain/user_asset_item.dart';

void main() {
  test('categoryIdFromApiRef maps builtin and user refs', () {
    expect(
      categoryIdFromApiRef(AssetCategoryRef.builtinId('lighting')),
      AssetCategoryRef.builtinId('lighting'),
    );
    expect(categoryIdFromApiRef('user:42'), 'user-cat-42');
  });

  test('categoryRefForApi maps local ids to API refs', () {
    expect(
      categoryRefForApi(
        localCategoryId: AssetCategoryRef.builtinId('lighting'),
      ),
      AssetCategoryRef.builtinId('lighting'),
    );

    final userCategory = UserAssetCategory(
      id: 'user-cat-7',
      label: '轨道',
      remoteId: 7,
    );
    expect(
      categoryRefForApi(
        localCategoryId: 'user-cat-7',
        userCategory: userCategory,
      ),
      'user:7',
    );
  });

  test('categoryFromApi and itemFromApi preserve remote ids', () {
    final category = categoryFromApi(
      ProductionAssetCategoryItem(id: 3, label: '灯具配件', sort: 1),
    );
    expect(category.id, 'user-cat-3');
    expect(category.remoteId, 3);
    expect(category.label, '灯具配件');

    final item = itemFromApi(
      ProductionAssetItemDto(
        id: 9,
        categoryRef: 'builtin:lighting',
        name: 'SkyPanel',
        brand: 'ARRI',
      ),
    );
    expect(item.id, 'user-asset-9');
    expect(item.remoteId, 9);
    expect(item.categoryId, AssetCategoryRef.builtinId('lighting'));
    expect(item.name, 'SkyPanel');
  });

  test('item write bodies include category_ref', () {
    final item = UserAssetItem(
      id: 'user-asset-1',
      categoryId: AssetCategoryRef.builtinId('lighting'),
      name: 'Test',
    );
    final body = itemToWriteBody(item, null);
    expect(body.categoryRef, AssetCategoryRef.builtinId('lighting'));
    expect(body.name, 'Test');
  });
}
