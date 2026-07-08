import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';

String communityAspectRatioLabel(Screenplay screenplay) {
  for (final preset in AppCatalog.aspectRatioPresets) {
    if (screenplay.allTags.contains(preset)) return preset;
  }
  return '4:3';
}

String communityStructureLabel(Screenplay screenplay) {
  final acts = screenplay.actCount;
  final scenes = screenplay.sceneCount;
  if (acts <= 0 && scenes <= 0) return 'Template';
  if (acts > 0 && scenes > 0) return '$acts Acts · $scenes Scenes';
  if (acts > 0) return '$acts Acts';
  return '$scenes Scenes';
}
