import '../../../api/scene/data/scene-api.dart';
import '../domain/scene_entry.dart';

String sceneIdFromDto(num id) => id.toInt().toString();

int? sceneIdToApi(String id) => int.tryParse(id);

SceneEntry sceneEntryFromDto(SceneItem dto) {
  return SceneEntry(
    id: sceneIdFromDto(dto.id),
    title: dto.title,
    coverUrl: dto.coverUrl,
    description: dto.description,
    category: dto.category,
    tags: List<String>.from(dto.tags),
    themes: List<String>.from(dto.themes),
    imageUrls: List<String>.from(dto.imageUrls),
    location: dto.location,
    city: dto.city,
    latitude: dto.latitude,
    longitude: dto.longitude,
    shootingTips: Map<String, String>.from(dto.shootingTips),
    favoriteCount: dto.favoriteCount.toInt(),
    useCount: dto.useCount.toInt(),
    viewCount: dto.viewCount.toInt(),
    rating: dto.rating.toDouble(),
    sort: dto.sort.toInt(),
    createdAt: dto.createdAt ?? DateTime.now(),
    updatedAt: dto.updatedAt ?? DateTime.now(),
    isSeed: dto.isSeed,
  );
}

SceneWriteBody sceneWriteBodyFromEntry(
  SceneEntry entry, {
  String? coverUrl,
}) {
  return SceneWriteBody(
    title: entry.title,
    coverUrl: coverUrl ?? entry.coverUrl,
    description: entry.description,
    category: entry.category,
    tags: entry.tags,
    themes: entry.themes,
    imageUrls: entry.imageUrls,
    location: entry.location,
    city: entry.city,
    latitude: entry.latitude,
    longitude: entry.longitude,
    shootingTips: entry.shootingTips,
    sort: entry.sort,
  );
}

String? apiSortForTab(String tab) {
  switch (tab) {
    case '热门':
      return 'hot';
    case '最新':
      return 'latest';
    default:
      return null;
  }
}

bool sceneHasLocation(SceneEntry entry) =>
    entry.latitude != null && entry.longitude != null;
