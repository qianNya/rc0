import '../../scene/data/scene_repository.dart';
import '../../scene/domain/scene_entry.dart';
import '../../scene/domain/scene_utils.dart';
import 'screenplay_draft.dart';

void applyLibrarySceneToSceneDraft(
  SceneEntry entry,
  SceneDraft scene,
  ScreenplayDraft draft,
) {
  scene.sceneLibraryId = entry.id;
  scene.sceneLibraryTitle = entry.title;

  if (scene.location.trim().isEmpty) {
    scene.location =
        entry.location.trim().isNotEmpty ? entry.location : entry.title;
  }
  if (scene.description.trim().isEmpty && entry.description.isNotEmpty) {
    scene.description = entry.description;
  }

  scene.tags.addAll(entry.tags);
  scene.tags.addAll(entry.themes);

  final time = parseTimeOfDayFromTips(entry.shootingTips);
  if (time != null && scene.timeOfDay.trim().isEmpty) {
    scene.timeOfDay = time;
  }
  final weather = parseWeatherFromTips(entry.shootingTips);
  if (weather != null && scene.weather.trim().isEmpty) {
    scene.weather = weather;
  }

  ensureDraftSceneLinked(draft, id: entry.id, title: entry.title);
  SceneRepository.instance.incrementUseCount(entry.id);
}
