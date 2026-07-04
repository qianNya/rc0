import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/production_assets/data/asset_catalog.dart';
import 'package:rc0/features/production_assets/data/asset_repository.dart';
import 'package:rc0/features/production_assets/domain/asset_category_ref.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AssetRepository.instance.resetForTest();
    await AssetRepository.instance.load();
  });

  test('builtin domains include camera and lighting', () {
    final slugs = AssetCatalog.builtinDomains.map((d) => d.slug).toSet();
    expect(slugs, containsAll(['camera', 'lighting', 'scene']));
  });

  test('user category and item CRUD', () async {
    final repo = AssetRepository.instance;

    final category = await repo.createUserCategory(label: '轨道');
    expect(category.label, '轨道');
    expect(repo.userCategories, hasLength(1));

    final lightingId = AssetCategoryRef.builtinId('lighting');
    final item = await repo.createItem(
      categoryId: lightingId,
      name: 'SkyPanel S60-C',
      brand: 'ARRI',
      model: 'S60-C',
    );
    expect(item.name, 'SkyPanel S60-C');
    expect(repo.itemsForCategory(lightingId), hasLength(1));

    final error = await repo.updateUserCategory(
      id: category.id,
      label: '轨道系统',
    );
    expect(error, isNull);
    expect(repo.findUserCategory(category.id)?.label, '轨道系统');

    final deleteItemError = await repo.deleteItem(item.id);
    expect(deleteItemError, isNull);
    expect(repo.itemsForCategory(lightingId), isEmpty);

    final deleteCategoryError = await repo.deleteUserCategory(category.id);
    expect(deleteCategoryError, isNull);
    expect(repo.userCategories, isEmpty);
  });
}
