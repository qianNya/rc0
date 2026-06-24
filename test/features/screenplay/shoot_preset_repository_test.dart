import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/data/preset_catalog.dart';
import 'package:rc0/features/screenplay/data/shoot_preset_repository.dart';
import 'package:rc0/features/screenplay/domain/shoot_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ShootPresetRepository.instance.load();
  });

  test('allPresets includes built-in offline defaults', () {
    final presets = ShootPresetRepository.instance.allPresets;
    expect(presets.length, greaterThanOrEqualTo(5));
    expect(
      presets.any((p) => p.label == '手机日常' && p.isBuiltIn),
      isTrue,
    );
  });

  test('create stores local preset when offline', () async {
    final before = ShootPresetRepository.instance.userPresets.length;
    final result = await ShootPresetRepository.instance.create(
      label: '测试预设',
      params: const ShootParams(
        device: 'Sony A7IV',
        aspectRatio: '16:9',
        lighting: '逆光',
      ),
    );

    expect(result.error, isNull);
    expect(result.preset, isNotNull);
    expect(
      ShootPresetRepository.instance.userPresets.length,
      before + 1,
    );
    expect(
      ShootPresetRepository.instance.findById(result.preset!.id)?.label,
      '测试预设',
    );
  });

  test('builtInShootPresets matches catalog seed labels', () {
    final labels = PresetCatalog.builtInShootPresets.map((p) => p.label).toList();
    expect(labels, contains('手机日常'));
    expect(labels, contains('电影宽幅'));
    expect(labels, contains('竖屏短视频'));
  });
}
