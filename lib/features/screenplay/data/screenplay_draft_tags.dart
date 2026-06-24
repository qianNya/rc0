import 'screenplay_draft.dart';

Set<String> parseDraftTagList(dynamic raw) {
  if (raw is! List) return {};
  return raw
      .map((e) => e.toString().trim())
      .where((e) => e.isNotEmpty)
      .toSet();
}

/// Union of screenplay + act + scene + frame tag sets.
Set<String> draftTagPool(ScreenplayDraft draft) {
  final pool = <String>{...draft.tags};
  for (final act in draft.acts) {
    pool.addAll(act.tags);
    for (final scene in act.scenes) {
      pool.addAll(scene.tags);
      for (final frame in scene.frames) {
        pool.addAll(frame.tags);
      }
    }
  }
  return pool;
}

List<String> draftTagPoolSorted(ScreenplayDraft draft) {
  final list = draftTagPool(draft).toList()..sort();
  return list;
}

void toggleDraftNodeTag(Set<String> nodeTags, String tag) {
  if (nodeTags.contains(tag)) {
    nodeTags.remove(tag);
  } else {
    nodeTags.add(tag);
  }
}

void addTagToDraftPool(ScreenplayDraft draft, String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return;
  draft.tags.add(trimmed);
}

List<String> mergeTagSuggestions({
  required Set<String> pool,
  required List<String> remoteSuggestions,
}) {
  return {...pool, ...remoteSuggestions}.toList()..sort();
}
