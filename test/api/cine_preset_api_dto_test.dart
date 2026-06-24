import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/api/cine-preset/data/cine-preset-api.dart';
import 'package:rc0/features/screenplay/data/shoot_preset_mapper.dart';
import 'package:rc0/features/screenplay/domain/shoot_params.dart';

void main() {
  test('CinePresetItem maps scope to isBuiltIn', () {
    final builtin = CinePresetItem.fromJson({
      'id': 1,
      'category_id': 2,
      'scope': 0,
      'name': '手机日常',
      'description': 'iPhone 15 Pro · 4:3 · 自然光',
      'params': {
        'device': 'iPhone 15 Pro',
        'aspect_ratio': '4:3',
        'lighting': '自然光',
      },
      'is_default': 1,
      'creator': 0,
    });

    expect(builtin.isBuiltIn, isTrue);

    final user = CinePresetItem.fromJson({
      'id': 9,
      'category_id': 2,
      'scope': 1,
      'name': '我的夜景',
      'description': '',
      'params': {
        'device': 'Sony A7IV',
        'aspect_ratio': '16:9',
        'lighting': '逆光',
      },
      'is_default': 0,
      'creator': 42,
    });

    expect(user.isBuiltIn, isFalse);
  });

  test('shootPresetFromApi maps params and remote id', () {
    final item = CinePresetItem.fromJson({
      'id': 5,
      'category_id': 1,
      'scope': 1,
      'name': '街头纪实',
      'description': '富士 X-T5 · 16:9 · 侧光',
      'params': {
        'device': '富士 X-T5',
        'aspect_ratio': '16:9',
        'lighting': '侧光',
      },
      'is_default': 0,
      'creator': 7,
    });

    final preset = shootPresetFromApi(item);
    expect(preset.id, 'preset-5');
    expect(preset.remoteId, 5);
    expect(preset.isBuiltIn, isFalse);
    expect(preset.params.device, '富士 X-T5');
    expect(preset.params.aspectRatio, '16:9');
    expect(preset.params.lighting, '侧光');
  });

  test('shootParamsToApiJson uses snake_case keys', () {
    final json = shootParamsToApiJson(
      const ShootParams(
        device: 'Canon R5',
        aspectRatio: '4:3',
        lighting: '柔光',
      ),
    );

    expect(json['device'], 'Canon R5');
    expect(json['aspect_ratio'], '4:3');
    expect(json['lighting'], '柔光');
  });
}
