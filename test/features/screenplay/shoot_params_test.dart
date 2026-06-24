import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/core/data/app_catalog.dart';
import 'package:rc0/features/screenplay/data/screenplay_draft.dart';
import 'package:rc0/features/screenplay/data/shoot_params_draft.dart';
import 'package:rc0/features/screenplay/domain/shoot_params.dart';
import 'package:rc0/features/upload/domain/upload_image_file.dart';

UploadImageFile _image(String name) => UploadImageFile(path: '/tmp/$name', name: name);

ScreenplayDraft _sampleDraft() {
  final draft = ScreenplayDraft(
    defaultParams: const ShootParams(
      device: 'iPhone 15 Pro',
      aspectRatio: '4:3',
      lighting: '自然光',
    ),
  );
  draft.acts.first.scenes.first.frames.add(FrameDraft(image: _image('a.jpg')));
  return draft;
}

void main() {
  group('ShootParams.resolve', () {
    test('override null fields inherit from base', () {
      const base = ShootParams(device: 'A', aspectRatio: '16:9', lighting: '自然光');
      const override = ShootParams(lighting: '逆光');
      final resolved = ShootParams.resolve(base, override);
      expect(resolved.device, 'A');
      expect(resolved.aspectRatio, '16:9');
      expect(resolved.lighting, '逆光');
    });
  });

  group('effectiveParams', () {
    test('scene inherits screenplay defaults', () {
      final draft = _sampleDraft();
      final params = effectiveParamsForScene(draft, 0, 0);
      expect(params.device, 'iPhone 15 Pro');
      expect(params.aspectRatio, '4:3');
      expect(params.lighting, '自然光');
    });

    test('scene override merges partial fields', () {
      final draft = _sampleDraft();
      draft.acts.first.scenes.first.paramOverride =
          const ShootParams(lighting: '柔光');
      final sceneParams = effectiveParamsForScene(draft, 0, 0);
      expect(sceneParams.device, 'iPhone 15 Pro');
      expect(sceneParams.lighting, '柔光');

      final frameParams = effectiveParamsForFrame(draft, 0, 0, 0);
      expect(frameParams.lighting, '柔光');
    });

    test('frame override wins over scene and screenplay', () {
      final draft = _sampleDraft();
      draft.acts.first.scenes.first.paramOverride =
          const ShootParams(aspectRatio: '16:9');
      draft.acts.first.scenes.first.frames.first.paramOverride =
          const ShootParams(device: 'Canon R5');
      final params = effectiveParamsForFrame(draft, 0, 0, 0);
      expect(params.device, 'Canon R5');
      expect(params.aspectRatio, '16:9');
      expect(params.lighting, '自然光');
    });

    test('clearing override restores inheritance', () {
      final draft = _sampleDraft();
      final scene = draft.acts.first.scenes.first;
      scene.paramOverride = const ShootParams(device: 'Sony A7IV');
      scene.paramOverride = null;
      expect(sceneHasParamOverride(scene), isFalse);
      expect(
        effectiveParamsForScene(draft, 0, 0).device,
        AppCatalog.defaultShootParams.device,
      );
    });
  });
}
