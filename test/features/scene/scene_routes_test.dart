import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/app/router/routes.dart';

void main() {
  test('scene route path helpers', () {
    expect(AppRoutes.sceneDetailPath('seed-coast-rocks'), '/scenes/seed-coast-rocks');
    expect(AppRoutes.sceneEditPath('scene-1'), '/scenes/scene-1/edit');
    expect(AppRoutes.scenes, '/scenes');
    expect(AppRoutes.sceneAi, '/scenes/ai');
    expect(AppRoutes.sceneCreate, '/scenes/create');
    expect(AppRoutes.myScenes, '/my-scenes');
  });
}
